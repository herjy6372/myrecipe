import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/user_profile.dart';

/// Firebase Auth의 photoURL은 실제 호스팅 URL만 받고 길이 제한(2048자)이 있어
/// base64로 인코딩한 커스텀 프로필 사진을 담을 수 없다. 그래서 사진과
/// 생년월일/휴대폰번호처럼 Auth가 다루지 않는 정보는 Firestore 문서에 따로 저장한다.
class UserProfileRepository {
  UserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _profileRef(String uid) => _firestore.collection('users').doc(uid);

  Stream<UserProfile> watchProfile(String uid) {
    return _profileRef(uid).snapshots().map((doc) => UserProfile.fromMap(doc.data()));
  }

  Future<void> setPhoto(String uid, String base64Jpeg) {
    return _profileRef(uid).set({'photoBase64': base64Jpeg}, SetOptions(merge: true));
  }

  Future<void> clearPhoto(String uid) {
    return _profileRef(uid).set({'photoBase64': FieldValue.delete()}, SetOptions(merge: true));
  }

  Future<void> setBirthDate(String uid, DateTime birthDate) {
    return _profileRef(uid).set({'birthDate': Timestamp.fromDate(birthDate)}, SetOptions(merge: true));
  }

  Future<void> setPhoneNumber(String uid, String phoneNumber) {
    return _profileRef(uid).set({'phoneNumber': phoneNumber}, SetOptions(merge: true));
  }
}
