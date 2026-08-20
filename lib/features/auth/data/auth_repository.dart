import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// authStateChanges()는 로그인/로그아웃에만 반응하고 프로필 변경(이름/사진)은
  /// 알려주지 않는다. userChanges()는 updateDisplayName 같은 프로필 갱신에도
  /// 새로 값을 흘려보내므로 이걸 화면 상태의 기준으로 쓴다.
  Stream<User?> authStateChanges() => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
    await _auth.currentUser?.reload();
  }

  /// 사용자가 구글 계정 선택 화면에서 취소하면 false를 반환한다.
  /// (취소는 에러가 아니라 로그인을 진행하지 않기로 한 정상적인 선택이다.)
  Future<bool> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
    return true;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    // 로그아웃 후에도 Firestore 오프라인 캐시에 이전 사용자의 프로필/즐겨찾기가
    // 남아있으면 같은 기기의 다음 사용자나 파일시스템 접근으로 노출될 수 있으므로 지운다.
    await FirebaseFirestore.instance.terminate();
    await FirebaseFirestore.instance.clearPersistence();
  }
}
