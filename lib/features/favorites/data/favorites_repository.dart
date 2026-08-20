import 'package:cloud_firestore/cloud_firestore.dart';

import '../../recipe_search/domain/recipe.dart';

/// 즐겨찾기는 Hive가 아닌 Firestore가 원본. 로그인한 사용자별로 격리된 컬렉션에 저장.
class FavoritesRepository {
  FavoritesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _favoritesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  Stream<List<RecipeSummary>> watchFavorites(String uid) {
    return _favoritesRef(uid).orderBy('addedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => RecipeSummary(
                    id: doc.id,
                    name: doc.data()['name'] as String? ?? '',
                    thumbnailUrl: doc.data()['thumbnailUrl'] as String? ?? '',
                  ))
              .toList(),
        );
  }

  Future<bool> isFavorite(String uid, String recipeId) async {
    final doc = await _favoritesRef(uid).doc(recipeId).get();
    return doc.exists;
  }

  Future<void> addFavorite(String uid, RecipeSummary recipe) {
    return _favoritesRef(uid).doc(recipe.id).set({
      'name': recipe.name,
      'thumbnailUrl': recipe.thumbnailUrl,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String uid, String recipeId) {
    return _favoritesRef(uid).doc(recipeId).delete();
  }
}
