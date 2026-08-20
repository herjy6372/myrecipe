import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/error_message.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/login_screen.dart';
import '../../recipe_detail/presentation/recipe_detail_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  Future<void> _removeFavorite(BuildContext context, WidgetRef ref, String uid, String recipeId) async {
    try {
      await ref.read(favoritesRepositoryProvider).removeFavorite(uid, recipeId);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateView(message: friendlyErrorMessage(error)),
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 56),
                  const SizedBox(height: 12),
                  const Text('로그인하고 즐겨찾기를 저장해보세요.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text('로그인'),
                  ),
                ],
              ),
            );
          }

          final favorites = ref.watch(favoritesStreamProvider);
          return favorites.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorStateView(
              message: friendlyErrorMessage(error),
              onRetry: () => ref.invalidate(favoritesStreamProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const EmptyStateView(
                  icon: Icons.favorite_border,
                  message: '아직 즐겨찾기한 레시피가 없어요.',
                );
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Theme.of(context).colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onErrorContainer),
                    ),
                    onDismissed: (_) => _removeFavorite(context, ref, user.uid, item.id),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.thumbnailUrl.isEmpty
                            ? const SizedBox(
                                width: 48,
                                height: 48,
                                child: Icon(Icons.restaurant),
                              )
                            : Image.network(
                                item.thumbnailUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                      ),
                      title: Text(item.name),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeId: item.id)),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
