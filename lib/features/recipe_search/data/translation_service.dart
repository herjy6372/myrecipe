import 'package:dio/dio.dart';

import '../../../core/cache/ttl_cache.dart';

/// TheMealDB는 영어만 다루므로, MyMemory의 무료 번역 API(키 불필요)로
/// 검색어(한→영)와 레시피 상세 내용(영→한)을 오간다. 실패하면 원문을 그대로 쓴다.
class TranslationService {
  TranslationService({required this.dio, required this.cache});

  static final _hangulRegex = RegExp(r'[가-힣]');

  /// MyMemory 익명 요청은 건당 약 500자 제한이 있어, 긴 텍스트는 이 길이로 잘라 보낸다.
  static const _maxChunkLength = 450;

  /// 동시에 너무 많은 요청을 한꺼번에 보내면 무료 API가 rate limit에 걸리기 쉬워서,
  /// 재료 목록 같은 다건 번역은 이 개수만큼씩 순차적으로 묶어서 보낸다.
  static const _batchSize = 4;

  final Dio dio;
  final TtlCache cache;

  bool containsKorean(String text) => _hangulRegex.hasMatch(text);

  Future<String> translateToEnglish(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !containsKorean(trimmed)) return trimmed;
    return _translate(trimmed, langpair: 'ko|en', cacheKey: _cacheKey('translate_en', trimmed));
  }

  Future<String> translateToKorean(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    return _translate(trimmed, langpair: 'en|ko', cacheKey: _cacheKey('translate_ko', trimmed));
  }

  /// 재료 이름, 검색 결과 이름처럼 여러 개를 한 번에 번역할 때 쓴다.
  /// 한꺼번에 다 쏘지 않고 [_batchSize]개씩 나눠 보내 rate limit을 피한다.
  Future<List<String>> translateAllToKorean(List<String> texts) async {
    final results = <String>[];
    for (var i = 0; i < texts.length; i += _batchSize) {
      final batch = texts.skip(i).take(_batchSize);
      results.addAll(await Future.wait(batch.map(translateToKorean)));
    }
    return results;
  }

  /// 조리법처럼 긴 텍스트는 문장 단위로 잘라 나눠 번역한 뒤 다시 이어붙인다.
  Future<String> translateLongTextToKorean(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;

    final cacheKey = _cacheKey('translate_ko_long', trimmed);
    final cached = cache.read(cacheKey);
    if (cached is String) return cached;

    final chunks = _splitIntoChunks(trimmed);
    final translatedChunks = await translateAllToKorean(chunks);
    final result = translatedChunks.join();
    await cache.write(cacheKey, result);
    return result;
  }

  /// Hive box 키는 최대 255자까지만 허용된다. 조리법 원문처럼 긴 텍스트를 키에
  /// 그대로 쓰면 HiveError가 나서, 길이+해시로 축약한 짧은 키를 대신 만든다.
  /// Object.hashCode는 Dart/Flutter 버전 간 안정성이 보장되지 않아(캐시가 조용히
  /// 무효화되거나 최악의 경우 다른 텍스트끼리 충돌할 수 있어) 직접 만든 안정적인
  /// 해시(FNV-1a)를 쓴다.
  String _cacheKey(String prefix, String text) {
    if (text.length <= 150) return '$prefix:$text';
    return '$prefix:${text.length}_${_stableHash(text)}';
  }

  /// FNV-1a 32비트 해시. 표준 알고리즘이라 Dart 런타임 버전이 바뀌어도 항상 같은
  /// 입력에 같은 값을 낸다.
  int _stableHash(String text) {
    var hash = 0x811c9dc5;
    for (final unit in text.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  List<String> _splitIntoChunks(String text) {
    final sentences = text.split(RegExp(r'(?<=[.!?\n])\s*'));
    final chunks = <String>[];
    var current = StringBuffer();
    for (final sentence in sentences) {
      if (sentence.isEmpty) continue;
      if (current.length + sentence.length > _maxChunkLength && current.isNotEmpty) {
        chunks.add(current.toString());
        current = StringBuffer();
      }
      current.write(sentence);
      current.write(' ');
    }
    if (current.isNotEmpty) chunks.add(current.toString());
    return chunks;
  }

  Future<String> _translate(String text, {required String langpair, required String cacheKey}) async {
    final cached = cache.read(cacheKey);
    if (cached is String) return cached;

    try {
      final response = await dio.get(
        'https://api.mymemory.translated.net/get',
        queryParameters: {'q': text, 'langpair': langpair},
      );
      final translated = (response.data['responseData']?['translatedText'] as String?)?.trim();
      if (translated == null || translated.isEmpty) return text;
      // 무료 할당량을 다 쓰면 MyMemory가 200 OK에 경고 문구를 "번역 결과"로 담아 보낸다.
      // 이런 응답은 캐시하지 말고 원문으로 대체해서, 할당량이 회복되면 다시 시도되게 한다.
      if (translated.toUpperCase().contains('MYMEMORY') || translated.length > text.length * 4 + 80) {
        return text;
      }
      await cache.write(cacheKey, translated);
      return translated;
    } catch (_) {
      return text;
    }
  }
}
