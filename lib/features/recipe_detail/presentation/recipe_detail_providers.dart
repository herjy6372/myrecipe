import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recipe_search/domain/category_labels.dart';
import '../../recipe_search/domain/recipe.dart';
import '../../recipe_search/presentation/recipe_search_providers.dart';
import '../domain/localized_recipe.dart';

/// 기기 로케일이 한국어일 때만 이름/카테고리/재료/조리법을 번역해서 보여준다.
final localizedRecipeProvider = FutureProvider.autoDispose
    .family<LocalizedRecipe, ({String id, bool korean})>((ref, args) async {
      final recipe = await ref.watch(recipeDetailProvider(args.id).future);
      if (!args.korean) return LocalizedRecipe.original(recipe);

      final translator = ref.watch(translationServiceProvider);
      // 이름/지역과 조리법(문장 단위 청크)을 먼저 병렬로 처리하고,
      // 재료는 한꺼번에 다 쏘지 않고 나눠서 번역해 rate limit 위험을 줄인다.
      final results = await Future.wait([
        translator.translateToKorean(recipe.name),
        translator.translateToKorean(recipe.area),
        translator.translateLongTextToKorean(recipe.instructions),
      ]);
      final ingredientNames = await translator.translateAllToKorean(
        recipe.ingredients.map((ingredient) => ingredient.name).toList(),
      );

      return LocalizedRecipe(
        name: results[0],
        categoryLabel: categoryLabel(recipe.category, useKorean: true),
        areaLabel: results[1],
        instructions: results[2],
        ingredients: [
          for (var i = 0; i < recipe.ingredients.length; i++)
            RecipeIngredient(name: ingredientNames[i], measure: recipe.ingredients[i].measure),
        ],
        thumbnailUrl: recipe.thumbnailUrl,
        youtubeUrl: recipe.youtubeUrl,
      );
    });
