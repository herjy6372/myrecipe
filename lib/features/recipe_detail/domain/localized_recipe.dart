import '../../recipe_search/domain/recipe.dart';

/// 로케일에 맞춰 화면에 보여줄 텍스트만 담는다. 즐겨찾기 등 저장용 데이터는
/// 항상 원본(영어) [Recipe]를 기준으로 하고, 이건 표시 전용이다.
class LocalizedRecipe {
  const LocalizedRecipe({
    required this.name,
    required this.categoryLabel,
    required this.areaLabel,
    required this.instructions,
    required this.ingredients,
    required this.thumbnailUrl,
    this.youtubeUrl,
  });

  final String name;
  final String categoryLabel;
  final String areaLabel;
  final String instructions;
  final List<RecipeIngredient> ingredients;
  final String thumbnailUrl;
  final String? youtubeUrl;

  factory LocalizedRecipe.original(Recipe recipe) {
    return LocalizedRecipe(
      name: recipe.name,
      categoryLabel: recipe.category,
      areaLabel: recipe.area,
      instructions: recipe.instructions,
      ingredients: recipe.ingredients,
      thumbnailUrl: recipe.thumbnailUrl,
      youtubeUrl: recipe.youtubeUrl,
    );
  }
}
