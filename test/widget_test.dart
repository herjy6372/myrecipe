// Firebase가 필요한 화면(즐겨찾기/마이페이지)이 앱 루트에 포함되어 있어,
// 앱 전체를 pump하는 위젯 테스트는 firebase_auth_mocks 등으로 Firebase를 목업한 뒤 추가한다.
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder', () {
    expect(1 + 1, 2);
  });
}
