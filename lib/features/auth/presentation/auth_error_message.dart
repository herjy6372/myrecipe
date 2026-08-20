import 'package:firebase_auth/firebase_auth.dart';

String friendlyAuthErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return '이메일 형식이 올바르지 않아요.';
    case 'user-disabled':
      return '비활성화된 계정이에요.';
    case 'user-not-found':
      return '가입되지 않은 이메일이에요.';
    case 'wrong-password':
    case 'invalid-credential':
      return '이메일 또는 비밀번호가 올바르지 않아요.';
    case 'email-already-in-use':
      return '이미 가입된 이메일이에요.';
    case 'weak-password':
      return '비밀번호가 너무 짧아요. 6자 이상 입력해주세요.';
    case 'network-request-failed':
      return '네트워크 연결을 확인해주세요.';
    case 'too-many-requests':
      return '요청이 너무 많아요. 잠시 후 다시 시도해주세요.';
    default:
      return '로그인에 실패했어요. (${error.code})';
  }
}
