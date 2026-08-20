import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/error_message.dart';
import '../../../core/widgets/state_views.dart';
import '../../recipe_detail/presentation/recipe_detail_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../domain/category_labels.dart';
import 'recipe_search_providers.dart';

class RecipeSearchScreen extends ConsumerStatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  ConsumerState<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends ConsumerState<RecipeSearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final currentQuery = ref.watch(searchQueryProvider).trim();
    final hasSearched = selectedCategory != null || currentQuery.isNotEmpty;
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';
    final resultsAsync = ref.watch(localizedSearchResultsProvider(isKorean));
    final translatedQueryAsync = ref.watch(translatedQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('레시피 검색'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '요리 이름으로 검색 (예: chicken, 치킨)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                ref.read(selectedCategoryProvider.notifier).state = null;
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          if (selectedCategory == null && currentQuery.isNotEmpty)
            translatedQueryAsync.maybeWhen(
              data: (translated) {
                if (translated.isEmpty ||
                    translated.toLowerCase() == currentQuery.toLowerCase()) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '"$currentQuery" → "$translated"로 검색',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: categoriesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (categories) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final selected = category == selectedCategory;
                  return ChoiceChip(
                    label: Text(categoryLabel(category, useKorean: isKorean)),
                    selected: selected,
                    onSelected: (isSelected) {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                      ref.read(selectedCategoryProvider.notifier).state =
                          isSelected ? category : null;
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorStateView(
                message: friendlyErrorMessage(error),
                onRetry: () {
                  ref.invalidate(searchResultsProvider);
                  ref.invalidate(localizedSearchResultsProvider(isKorean));
                },
              ),
              data: (results) {
                if (results.isEmpty) {
                  return hasSearched
                      ? const EmptyStateView(
                          icon: Icons.search_off,
                          message: '검색 결과가 없어요.\n다른 검색어나 카테고리를 시도해보세요.',
                        )
                      : const EmptyStateView(
                          icon: Icons.restaurant_menu,
                          message: '검색어를 입력하거나 카테고리를 선택해보세요.',
                        );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  // 태블릿 가로모드처럼 화면이 넓어지면 열 개수가 자동으로 늘어난다.
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(recipeId: item.id),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: item.thumbnailUrl.isEmpty
                                  ? Container(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                    )
                                  : Image.network(
                                      item.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                child: const Icon(
                                                  Icons.broken_image_outlined,
                                                ),
                                              ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
