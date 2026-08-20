import 'package:dio/dio.dart';

/// TheMealDB (https://www.themealdb.com/api.php) 무료 API 클라이언트.
/// 키가 필요 없는 테스트 엔드포인트(v1/1)를 사용.
class MealDbApi {
  MealDbApi(this._dio);

  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  final Dio _dio;

  Future<List<Map<String, dynamic>>> searchByName(String query) async {
    final response = await _dio.get('$_baseUrl/search.php', queryParameters: {'s': query});
    return _extractMeals(response);
  }

  Future<Map<String, dynamic>?> lookupById(String id) async {
    final response = await _dio.get('$_baseUrl/lookup.php', queryParameters: {'i': id});
    final meals = _extractMeals(response);
    return meals.isEmpty ? null : meals.first;
  }

  Future<List<Map<String, dynamic>>> filterByCategory(String category) async {
    final response = await _dio.get('$_baseUrl/filter.php', queryParameters: {'c': category});
    return _extractMeals(response);
  }

  Future<List<String>> listCategories() async {
    final response = await _dio.get('$_baseUrl/list.php', queryParameters: {'c': 'list'});
    final meals = _extractMeals(response);
    return meals.map((m) => m['strCategory'] as String?).whereType<String>().toList();
  }

  Future<List<Map<String, dynamic>>> filterByArea(String area) async {
    final response = await _dio.get('$_baseUrl/filter.php', queryParameters: {'a': area});
    return _extractMeals(response);
  }

  Future<List<String>> listAreas() async {
    final response = await _dio.get('$_baseUrl/list.php', queryParameters: {'a': 'list'});
    final meals = _extractMeals(response);
    return meals.map((m) => m['strArea'] as String?).whereType<String>().toList();
  }

  List<Map<String, dynamic>> _extractMeals(Response response) {
    final meals = response.data['meals'] as List<dynamic>?;
    if (meals == null) return [];
    return meals.cast<Map<String, dynamic>>();
  }
}
