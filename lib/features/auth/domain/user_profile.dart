import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore `users/{uid}` 문서에 저장되는, Firebase Auth가 다루지 않는
/// 추가 프로필 정보(사진, 생년월일, 휴대폰번호).
class UserProfile {
  const UserProfile({this.photoBase64, this.birthDate, this.phoneNumber});

  final String? photoBase64;
  final DateTime? birthDate;
  final String? phoneNumber;

  static const empty = UserProfile();

  factory UserProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;
    final birthTimestamp = map['birthDate'] as Timestamp?;
    return UserProfile(
      photoBase64: map['photoBase64'] as String?,
      birthDate: birthTimestamp?.toDate(),
      phoneNumber: map['phoneNumber'] as String?,
    );
  }
}
