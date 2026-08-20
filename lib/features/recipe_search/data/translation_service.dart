import 'package:dio/dio.dart';

import '../../../core/cache/ttl_cache.dart';

/// TheMealDB는 영어 검색어만 이해하므로, 한글 검색어는 MyMemory의 무료 번역
/// API(키 불필요)로 영어로 바꾼 뒤 검색한다. 실패하면 원문 그대로 검색을 시도한다.
class TranslationService {
  TranslationService({required this.dio, required this.cache});

  static final _hangulRegex = RegExp(r'[가-힣]');

  final Dio dio;
  final TtlCache cache;

  bool containsKorean(String text) => _hangulRegex.hasMatch(text);

  Future<String> translateToEnglish(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !containsKorean(trimmed)) return trimmed;

    final key = 'translate:$trimmed';
    final cached = cache.read(key);
    if (cached is String) return cached;

    try {
      final response = await dio.get(
        'https://api.mymemory.translated.net/get',
        queryParameters: {'q': trimmed, 'langpair': 'ko|en'},
      );
      final translated = (response.data['responseData']?['translatedText'] as String?)?.trim();
      if (translated == null || translated.isEmpty) return trimmed;
      await cache.write(key, translated);
      return translated;
    } catch (_) {
      return trimmed;
    }
  }
}
