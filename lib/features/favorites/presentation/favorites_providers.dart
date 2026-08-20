import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../recipe_search/domain/recipe.dart';
import '../data/favorites_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(firestoreProvider));
});

final favoritesStreamProvider = StreamProvider<List<RecipeSummary>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  // Stream.empty()는 값을 하나도 내보내지 않고 바로 닫혀서 AsyncLoading 상태에 영원히
  // 머무른다(스피너가 멈추지 않음). 로그인 안 된 상태를 빈 목록으로 명확히 표현한다.
  if (uid == null) return Stream.value(const <RecipeSummary>[]);
  return ref.watch(favoritesRepositoryProvider).watchFavorites(uid);
});

final isFavoriteProvider = FutureProvider.autoDispose.family<bool, String>((ref, recipeId) async {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return false;
  return ref.watch(favoritesRepositoryProvider).isFavorite(uid, recipeId);
});
