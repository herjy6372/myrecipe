import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/error_message.dart';
import '../../../core/responsive.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/login_screen.dart';
import '../../favorites/presentation/favorites_providers.dart';
import '../../recipe_search/presentation/recipe_search_providers.dart';
import '../domain/localized_recipe.dart';
import 'recipe_detail_providers.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref, bool isFavorite) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요해요.')));
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    final repo = ref.read(favoritesRepositoryProvider);
    try {
      if (isFavorite) {
        await repo.removeFavorite(uid, recipeId);
      } else {
        // 즐겨찾기는 항상 원본(영어) 레시피 이름을 저장해 데이터 원본을 일관되게 유지한다.
        final recipe = await ref.read(recipeDetailProvider(recipeId).future);
        await repo.addFavorite(uid, recipe.toSummary());
      }
      ref.invalidate(isFavoriteProvider(recipeId));
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';
    final recipeAsync = ref.watch(localizedRecipeProvider((id: recipeId, korean: isKorean)));
    final isFavoriteAsync = ref.watch(isFavoriteProvider(recipeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('레시피 상세'),
        actions: [
          IconButton(
            icon: Icon(isFavoriteAsync.valueOrNull == true ? Icons.favorite : Icons.favorite_border),
            onPressed: () => _toggleFavorite(context, ref, isFavoriteAsync.valueOrNull ?? false),
          ),
        ],
      ),
      body: recipeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateView(
          message: friendlyErrorMessage(error),
          onRetry: () => ref.invalidate(localizedRecipeProvider((id: recipeId, korean: isKorean))),
        ),
        data: (recipe) => isWideLayout(context) ? _WideDetailBody(recipe: recipe) : _NarrowDetailBody(recipe: recipe),
      ),
    );
  }
}

Widget _thumbnail(BuildContext context, LocalizedRecipe recipe, {required double height}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: recipe.thumbnailUrl.isEmpty
          ? Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)
          : Image.network(
              recipe.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
    ),
  );
}

List<Widget> _detailTexts(BuildContext context, LocalizedRecipe recipe) {
  return [
    Text(recipe.name, style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 4),
    Text('${recipe.categoryLabel} · ${recipe.areaLabel}', style: Theme.of(context).textTheme.bodyMedium),
    const SizedBox(height: 20),
    Text('재료', style: Theme.of(context).textTheme.titleMedium),
    const SizedBox(height: 8),
    ...recipe.ingredients.map(
      (ingredient) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(ingredient.name)),
            Text(ingredient.measure, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ),
    const SizedBox(height: 20),
    Text('조리법', style: Theme.of(context).textTheme.titleMedium),
    const SizedBox(height: 8),
    Text(recipe.instructions),
  ];
}

/// 휴대폰처럼 좁은 화면: 사진을 위에, 내용을 아래로 세로 스크롤.
class _NarrowDetailBody extends StatelessWidget {
  const _NarrowDetailBody({required this.recipe});

  final LocalizedRecipe recipe;

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 720,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _thumbnail(context, recipe, height: 240),
          const SizedBox(height: 16),
          ..._detailTexts(context, recipe),
        ],
      ),
    );
  }
}

/// 태블릿 가로모드처럼 넓은 화면: 사진은 왼쪽에 고정하고 내용만 오른쪽에서 스크롤.
class _WideDetailBody extends StatelessWidget {
  const _WideDetailBody({required this.recipe});

  final LocalizedRecipe recipe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 340, child: _thumbnail(context, recipe, height: 340)),
          const SizedBox(width: 32),
          Expanded(
            child: ListView(children: _detailTexts(context, recipe)),
          ),
        ],
      ),
    );
  }
}
