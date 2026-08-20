import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/cache/hive_boxes.dart';
import '../../../core/cache/ttl_cache.dart';
import '../../../core/network/dio_client.dart';
import '../data/meal_db_api.dart';
import '../data/recipe_repository.dart';
import '../data/translation_service.dart';
import '../domain/recipe.dart';

final dioProvider = Provider<Dio>((ref) => createDioClient());

final mealDbApiProvider = Provider<MealDbApi>((ref) => MealDbApi(ref.watch(dioProvider)));

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final cache = TtlCache(Hive.box(HiveBoxes.searchCache));
  return RecipeRepository(api: ref.watch(mealDbApiProvider), cache: cache);
});

final translationServiceProvider = Provider<TranslationService>((ref) {
  final cache = TtlCache(Hive.box(HiveBoxes.searchCache), ttl: const Duration(days: 30));
  return TranslationService(dio: ref.watch(dioProvider), cache: cache);
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final categoriesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(recipeRepositoryProvider).categories();
});

/// 한글 검색어면 영어로 번역한 검색어를, 아니면 원문을 그대로 반환한다.
final translatedQueryProvider = FutureProvider.autoDispose<String>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return '';
  return ref.watch(translationServiceProvider).translateToEnglish(query);
});

final searchResultsProvider = FutureProvider.autoDispose<List<RecipeSummary>>((ref) async {
  final repo = ref.watch(recipeRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  if (category != null) {
    return repo.filterByCategory(category);
  }
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return const [];
  final searchTerm = await ref.watch(translatedQueryProvider.future);
  return repo.search(searchTerm);
});

final recipeDetailProvider = FutureProvider.autoDispose.family<Recipe, String>((ref, id) {
  return ref.watch(recipeRepositoryProvider).getDetail(id);
});
