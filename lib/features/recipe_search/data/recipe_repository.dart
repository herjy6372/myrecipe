import '../../../core/cache/ttl_cache.dart';
import '../domain/recipe.dart';
import 'meal_db_api.dart';

/// API 호출 결과를 Hive에 캐싱하는 오프라인 우선 레포지토리.
class RecipeRepository {
  RecipeRepository({required this.api, required this.cache});

  final MealDbApi api;
  final TtlCache cache;

  Future<List<RecipeSummary>> search(String query) async {
    final key = 'search:$query';
    final cached = cache.read(key);
    if (cached is List) {
      return cached.map((e) => RecipeSummary.fromJson(e as Map)).toList();
    }
    final meals = await api.searchByName(query);
    await cache.write(key, meals);
    return meals.map(RecipeSummary.fromJson).toList();
  }

  Future<List<RecipeSummary>> filterByCategory(String category) async {
    final key = 'category:$category';
    final cached = cache.read(key);
    if (cached is List) {
      return cached.map((e) => RecipeSummary.fromJson(e as Map)).toList();
    }
    final meals = await api.filterByCategory(category);
    await cache.write(key, meals);
    return meals.map(RecipeSummary.fromJson).toList();
  }

  Future<Recipe> getDetail(String id) async {
    final key = 'detail:$id';
    final cached = cache.read(key);
    if (cached is Map) {
      return Recipe.fromJson(cached);
    }
    final meal = await api.lookupById(id);
    if (meal == null) {
      throw StateError('레시피를 찾을 수 없습니다: $id');
    }
    await cache.write(key, meal);
    return Recipe.fromJson(meal);
  }

  Future<List<String>> categories() async {
    const key = 'categories';
    final cached = cache.read(key);
    if (cached is List) {
      return cached.cast<String>();
    }
    final categories = await api.listCategories();
    await cache.write(key, categories);
    return categories;
  }

  Future<List<RecipeSummary>> filterByArea(String area) async {
    final key = 'area:$area';
    final cached = cache.read(key);
    if (cached is List) {
      return cached.map((e) => RecipeSummary.fromJson(e as Map)).toList();
    }
    final meals = await api.filterByArea(area);
    await cache.write(key, meals);
    return meals.map(RecipeSummary.fromJson).toList();
  }

  Future<List<String>> areas() async {
    const key = 'areas';
    final cached = cache.read(key);
    if (cached is List) {
      return cached.cast<String>();
    }
    final areas = await api.listAreas();
    await cache.write(key, areas);
    return areas;
  }
}
