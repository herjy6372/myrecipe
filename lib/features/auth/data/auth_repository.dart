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

  Future<void> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password, {required String displayName}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await credential.user?.updateDisplayName(displayName);
  }

  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
    await _auth.currentUser?.reload();
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
