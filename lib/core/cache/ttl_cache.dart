import 'package:hive/hive.dart';

/// 만료 시간이 있는 단순 캐시 래퍼. TheMealDB 응답을 Hive box에 저장/조회할 때 사용.
class TtlCache {
  TtlCache(this._box, {this.ttl = const Duration(hours: 1)});

  final Box _box;
  final Duration ttl;

  dynamic read(String key) {
    final entry = _box.get(key);
    if (entry is! Map) return null;
    final cachedAt = entry['cachedAt'] as int?;
    if (cachedAt == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    if (age > ttl.inMilliseconds) return null;
    return entry['data'];
  }

  Future<void> write(String key, dynamic data) {
    return _box.put(key, {
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    });
  }
}
