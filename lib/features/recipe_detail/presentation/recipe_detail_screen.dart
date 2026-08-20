import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/error_message.dart';
import '../../../core/responsive.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/login_screen.dart';
import '../../favorites/presentation/favorites_providers.dart';
import '../../recipe_search/presentation/recipe_search_providers.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    bool isFavorite,
  ) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요해요.')));
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    final repo = ref.read(favoritesRepositoryProvider);
    try {
      if (isFavorite) {
        await repo.removeFavorite(uid, recipeId);
      } else {
        final recipe = await ref.read(recipeDetailProvider(recipeId).future);
        await repo.addFavorite(uid, recipe.toSummary());
      }
      ref.invalidate(isFavoriteProvider(recipeId));
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeDetailProvider(recipeId));
    final isFavoriteAsync = ref.watch(isFavoriteProvider(recipeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('레시피 상세'),
        actions: [
          IconButton(
            icon: Icon(
              isFavoriteAsync.valueOrNull == true
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            onPressed: () => _toggleFavorite(
              context,
              ref,
              isFavoriteAsync.valueOrNull ?? false,
            ),
          ),
        ],
      ),
      body: recipeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateView(
          message: friendlyErrorMessage(error),
          onRetry: () => ref.invalidate(recipeDetailProvider(recipeId)),
        ),
        data: (recipe) {
          return ResponsiveCenter(
            maxWidth: 720,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (recipe.thumbnailUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${recipe.category} · ${recipe.area}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text('재료', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...recipe.ingredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text(ingredient.name)),
                        Text(
                          ingredient.measure,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('조리법', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(recipe.instructions),
              ],
            ),
          );
        },
      ),
    );
  }
}
