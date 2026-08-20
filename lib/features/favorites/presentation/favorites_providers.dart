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
  if (uid == null) return const Stream.empty();
  return ref.watch(favoritesRepositoryProvider).watchFavorites(uid);
});

final isFavoriteProvider = FutureProvider.autoDispose.family<bool, String>((ref, recipeId) async {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return false;
  return ref.watch(favoritesRepositoryProvider).isFavorite(uid, recipeId);
});
