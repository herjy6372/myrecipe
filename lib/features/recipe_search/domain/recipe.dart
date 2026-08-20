class RecipeIngredient {
  const RecipeIngredient({required this.name, required this.measure});

  final String name;
  final String measure;
}

/// 검색/즐겨찾기 목록에 필요한 최소 정보. TheMealDB의 search.php, filter.php 응답 모두에서 추출 가능.
class RecipeSummary {
  const RecipeSummary({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
  });

  final String id;
  final String name;
  final String thumbnailUrl;

  factory RecipeSummary.fromJson(Map<dynamic, dynamic> json) {
    return RecipeSummary(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String? ?? '',
      thumbnailUrl: json['strMealThumb'] as String? ?? '',
    );
  }
}

/// 상세 화면에 필요한 전체 레시피 정보. lookup.php 응답 전용.
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnailUrl,
    required this.ingredients,
    this.youtubeUrl,
  });

  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnailUrl;
  final String? youtubeUrl;
  final List<RecipeIngredient> ingredients;

  RecipeSummary toSummary() => RecipeSummary(id: id, name: name, thumbnailUrl: thumbnailUrl);

  factory Recipe.fromJson(Map<dynamic, dynamic> json) {
    final ingredients = <RecipeIngredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = (json['strIngredient$i'] as String?)?.trim();
      final measure = (json['strMeasure$i'] as String?)?.trim();
      if (name != null && name.isNotEmpty) {
        ingredients.add(RecipeIngredient(name: name, measure: measure ?? ''));
      }
    }
    final youtube = json['strYoutube'] as String?;
    return Recipe(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String? ?? '',
      category: json['strCategory'] as String? ?? '',
      area: json['strArea'] as String? ?? '',
      instructions: json['strInstructions'] as String? ?? '',
      thumbnailUrl: json['strMealThumb'] as String? ?? '',
      youtubeUrl: (youtube == null || youtube.isEmpty) ? null : youtube,
      ingredients: ingredients,
    );
  }
}
