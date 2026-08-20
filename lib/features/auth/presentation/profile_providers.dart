import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_profile_repository.dart';
import '../domain/user_profile.dart';
import 'auth_providers.dart';

final userProfileFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(ref.watch(userProfileFirestoreProvider));
});

/// Firestore에만 있는 추가 프로필(사진, 생년월일, 휴대폰번호). 구글 로그인
/// 사용자는 보통 User.photoURL이 이미 있으므로 화면에서 이걸 우선 쓴다.
final userProfileProvider = StreamProvider.autoDispose<UserProfile>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(UserProfile.empty);
  return ref.watch(userProfileRepositoryProvider).watchProfile(uid);
});
