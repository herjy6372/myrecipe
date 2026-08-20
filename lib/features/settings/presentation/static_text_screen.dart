import 'package:flutter/material.dart';

import '../../../core/responsive.dart';

class StaticTextScreen extends StatelessWidget {
  const StaticTextScreen({required this.title, required this.content, super.key});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ResponsiveCenter(
        maxWidth: 720,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}

const privacyPolicyText = '''
나의 레시피(My Recipe) 개인정보 처리방침

이 앱은 개인 포트폴리오 목적으로 만든 비상업 앱입니다.

1. 수집하는 정보
- 구글 계정 정보 (이메일, 이름, 프로필 사진) — Firebase Authentication을 통한 로그인 시
- 생년월일, 휴대폰번호, 커스텀 프로필 사진 (사용자가 앱 내에서 직접 입력한 경우에만)
- 즐겨찾기한 레시피 목록

2. 정보 저장 위치
모든 정보는 Google Firebase(Firestore, Authentication)에 저장되며, 보안 규칙에 따라
본인 계정으로 로그인한 사용자만 자신의 데이터에 접근할 수 있습니다.

3. 외부 서비스 이용
- 레시피 데이터: TheMealDB (공개 레시피 API)
- 한글 검색어/레시피 번역: MyMemory Translation API
검색어나 레시피 텍스트가 번역을 위해 위 서비스로 전송될 수 있습니다.

4. 제3자 제공
수집한 개인정보를 광고나 마케팅 목적으로 제3자에게 판매하거나 제공하지 않습니다.

5. 정보 삭제
앱 내 로그아웃 후 계정 삭제를 원하시면 아래 문의처로 연락해주시면 처리해드립니다.

6. 문의
앱 관련 문의: herjy6372@gmail.com
''';

const termsOfServiceText = '''
나의 레시피(My Recipe) 이용약관

1. 목적
이 약관은 본 앱(이하 "서비스")의 이용과 관련하여 필요한 사항을 정합니다.
본 서비스는 개인 포트폴리오 목적으로 제작되었으며 상업적 서비스가 아닙니다.

2. 서비스 제공
서비스는 TheMealDB의 공개 레시피 데이터를 활용하며, 데이터의 정확성이나
지속적인 제공을 보장하지 않습니다.

3. 계정
서비스 이용을 위해 구글 계정으로 로그인해야 하며, 즐겨찾기·프로필 등
계정 관련 데이터는 로그인된 계정에 귀속됩니다.

4. 이용자의 의무
이용자는 본 서비스를 이용하며 타인의 권리를 침해하거나 관련 법령을
위반하는 행위를 해서는 안 됩니다.

5. 면책
본 서비스는 "있는 그대로" 제공되며, 서비스 이용으로 발생하는 손해에 대해
개발자는 법이 허용하는 범위 내에서 책임을 지지 않습니다.

6. 약관 변경
서비스 개선을 위해 본 약관은 사전 고지 없이 변경될 수 있습니다.
''';
