# 🍳 나의 레시피 (My Recipe) — TheMealDB 기반 레시피 검색 앱
> **개발 기간:** 2026.08 ~ 진행중 (개인 프로젝트, 1인 개발)
> **배포 링크:** Google Play Store 비공개 테스트 중
> **앱 버전:** 1.0.1 (2)

---

## 💡 1. 프로젝트 소개

**"나의 레시피"** 는 전 세계 요리 레시피를 검색하고 즐겨찾기로 관리하는 **개인 포트폴리오용 Flutter 앱**입니다.

TheMealDB 공개 API를 활용해 요리명·재료명 검색은 물론, 카테고리와 지역(국가)별 필터로 레시피를 둘러볼 수 있고, 한글 검색어와 조리법은 자동으로 번역돼 영어 기반 API 데이터를 한국어 사용자도 무리 없이 볼 수 있게 설계했습니다. Google 로그인 시에는 Firebase/Firestore로 프로필과 즐겨찾기를 기기 간에 동기화합니다.

기획부터 설계, 개발, Google Play Console 비공개 테스트 등록(콘텐츠 등급, 데이터 보안, 스토어 등록정보 등 전 항목)까지 전 과정을 혼자 진행한 프로젝트입니다.

---

## 🛠 2. 사용 기술 및 개발 환경 (Tech Stack)

| 분류 | 기술 |
|------|------|
| **언어** | Dart |
| **프레임워크** | Flutter |
| **상태 관리** | Riverpod (StateProvider / FutureProvider) |
| **네트워킹** | Dio |
| **로컬 캐시** | Hive (TTL 기반 오프라인 캐시) |
| **인증** | Firebase Auth, Google Sign-In |
| **데이터베이스** | Cloud Firestore |
| **외부 API** | TheMealDB(레시피), MyMemory Translation API(번역) |
| **앱 정보** | package_info_plus, device_info_plus |
| **배포 (Android)** | Google Play Store (AAB, Release Signing) |
| **버전 관리** | Git |
| **개발 환경** | macOS, VS Code |

---

## 🌟 3. 핵심 기능 및 구현 내용

### 🔑 기술적 의사결정 및 구현 포인트

- **카테고리 · 지역 · 텍스트 검색 3단 배타적 필터**
  - `selectedCategoryProvider` / `selectedAreaProvider` / `searchQueryProvider` 세 상태 중 하나를 고르면 나머지 둘을 자동으로 초기화하도록 설계해, 서로 충돌하는 검색 조건이 동시에 활성화되지 않도록 함
  - `searchResultsProvider`가 카테고리 → 지역 → 텍스트검색 순으로 우선순위를 방어적으로 재확인하는 이중 안전장치 포함

- **Repository + TtlCache 기반 오프라인 우선 설계**
  - `MealDbApi`(순수 API 클라이언트) → `RecipeRepository`(Hive TTL 캐시 결합) → Riverpod Provider → UI로 계층을 분리해, API 클라이언트는 캐싱을, Repository는 UI를 몰라도 되게 구성
  - 검색/카테고리/지역/상세/번역 결과를 각각 캐싱해 같은 조건 재검색 시 API 호출을 최소화

- **한↔영 자동 번역 파이프라인**
  - 한글이 포함된 검색어만 감지해 MyMemory API로 영어 변환 후 TheMealDB에 검색, 결과 이름과 조리법도 필요 시 한국어로 재번역
  - 무료 API의 건당 500자 제한에 맞춰 문장 단위로 청크를 나누고, 4개씩 배치 처리해 rate limit을 회피

- **Firebase 프로필 사진 저장 방식**
  - Firebase Auth의 `photoURL`은 2048자 길이 제한이 있어 커스텀 사진을 담을 수 없어서, 클라이언트에서 256×256 JPEG로 리사이즈한 뒤 base64로 인코딩해 Firestore 문서에 별도 저장

- **계정 정보 UI 일원화**
  - 로그인 상태의 프로필(사진/이름/이메일/생년월일/휴대폰번호)은 마이페이지에서만 관리하도록 정리하고, 설정 화면은 언어·약관·기기정보 같은 앱 전역 설정만 담당하도록 역할을 분리

---

## 🪵 4. 아키텍처 및 시스템 구조

```
lib/
├── main.dart / app.dart          # 앱 진입점, HomeShell(검색/즐겨찾기/마이페이지 탭)
├── core/
│   ├── cache/
│   │   ├── hive_boxes.dart       # Hive box 정의
│   │   └── ttl_cache.dart        # TTL 기반 캐시 래퍼
│   ├── network/
│   │   ├── dio_client.dart       # Dio 인스턴스, 디버그 빌드 전용 로깅
│   │   └── error_message.dart    # 에러 → 사용자 친화 메시지 변환
│   └── widgets/state_views.dart  # 공용 로딩/에러/빈 상태 위젯
└── features/
    ├── auth/
    │   ├── data/                 # auth_repository.dart, user_profile_repository.dart
    │   ├── domain/user_profile.dart
    │   └── presentation/         # login_screen.dart, my_page_screen.dart
    ├── recipe_search/
    │   ├── data/                 # meal_db_api.dart, recipe_repository.dart, translation_service.dart
    │   ├── domain/                # recipe.dart, category_labels.dart, area_labels.dart
    │   └── presentation/         # recipe_search_screen.dart, recipe_search_providers.dart
    ├── recipe_detail/            # LocalizedRecipe로 번역 결과 래핑
    ├── favorites/                # Firestore users/{uid}/favorites 서브컬렉션
    └── settings/                 # 설정 화면, 계정 정보 다이얼로그 공용 로직
```

- **데이터 흐름:** MealDbApi(HTTP) → RecipeRepository(캐시 결합) → Riverpod Provider(watch 체인) → UI 자동 반영
- **인증 상태 전파:** `authStateProvider`를 즐겨찾기·프로필 Provider가 함께 watch해, 로그인/로그아웃/사용자 전환 시 관련 화면이 자동으로 다시 구독됨
- **Firestore 스코프:** `users/{uid}` 문서와 하위 `favorites` 서브컬렉션 모두 소유자만 읽기/쓰기 가능하도록 보안 규칙으로 제한

---

## 🔥 5. 트러블슈팅 (Troubleshooting) — ★가장 중요★

### ① Firestore 규칙에 필드 검증이 없던 문제

#### ❌ 문제 상황
`users/{uid}` 문서는 소유자 스코프(`request.auth.uid == uid`)는 되어 있었지만, 쓰기 필드에 대한 화이트리스트나 크기 제한이 전혀 없었습니다. 즉, 변조된 클라이언트가 인증만 되어 있으면 자기 문서에 임의 필드나 최대 1MB까지 데이터를 채워 넣을 수 있는 구조였습니다.

#### 🔍 원인 및 해결
`allow read, write: if request.auth.uid == uid` 한 줄로만 되어 있던 규칙을, `request.resource.data.keys().hasOnly([...])`로 허용 필드(`photoBase64`, `birthDate`, `phoneNumber`)를 제한하고 각 필드의 타입·크기(사진 200KB, 전화번호 30자 등)를 검증하도록 재작성한 뒤 `firebase deploy --only firestore:rules`로 실제 프로젝트에 배포했습니다.

---

### ② release 빌드가 debug 키로 조용히 폴백되던 문제

#### ❌ 문제 상황
`android/key.properties`가 없는 환경에서 release 빌드를 하면, 빌드가 실패하는 대신 아무 경고 없이 `debug` 서명으로 조용히 폴백하도록 구성돼 있었습니다. 이 상태로 배포하면 공개적으로 알려진 debug 키로 서명된 release APK가 나갈 위험이 있었습니다.

#### 🔍 원인 및 해결
`build.gradle.kts`의 `signingConfig` 분기를, `key.properties`가 없으면 `-PallowDebugSigning` 옵션을 명시하지 않는 한 `GradleException`으로 빌드 자체를 실패시키도록 변경해 "조용한 실패"를 "시끄러운 실패"로 바꿨습니다.

---

### ③ 구글 로그인 취소가 로그인 성공으로 처리되던 버그

#### ❌ 문제 상황
`signInWithGoogle()`은 사용자가 계정 선택 화면에서 취소해도 예외 없이 정상 반환되는데, 로그인 화면의 실행 로직은 이 케이스를 구분하지 못하고 무조건 `Navigator.pop()`을 호출해 로그인 화면을 닫아버렸습니다. 사용자 입장에서는 취소했는데 로그인된 것처럼 화면이 넘어가는 버그였습니다.

#### 🔍 원인 및 해결
`signInWithGoogle()`이 `Future<bool>`을 반환하도록 바꿔 취소 시 `false`, 성공 시 `true`를 리턴하게 하고, 화면에서는 `true`일 때만 화면을 닫도록 수정했습니다.

---

### ④ TheMealDB에 '한식(Korean)' 데이터가 존재하지 않는 문제

#### ❌ 문제 상황
검색 탭에 지역(국가)별 필터를 추가하면서 한식/양식/중식 같은 필터를 기대했지만, TheMealDB의 지역 목록 API(`list.php?a=list`)를 실제로 확인해보니 American, British, Chinese, French, Italian, Japanese 등 28개 지역만 존재하고 Korean(한식) 데이터 자체가 API에 없다는 것을 발견했습니다.

#### 🔍 원인 및 해결
없는 데이터를 억지로 만들어 넣기보다, 실제 지원되는 28개 지역에 한글 라벨(`area_labels.dart`)만 매핑해 제공하고, 한식 데이터가 API 자체에 없다는 점을 사용자에게 명확히 안내하는 방향으로 결정했습니다.

---

### ⑤ 그 외 정적 점검에서 함께 발견해 고친 안정성 이슈

- **로그아웃 후 Firestore 캐시 잔존:** `signOut()`이 Auth/Google 로그아웃만 하고 Firestore 오프라인 퍼시스턴스는 그대로 둬서, 이전 사용자의 프로필·즐겨찾기가 기기에 남아있던 문제 → `terminate()` + `clearPersistence()` 추가
- **프로필 사진 손상 시 앱 크래시:** Firestore의 `photoBase64` 값이 손상돼 있으면 `base64Decode`가 예외를 던져 마이페이지 전체가 크래시되던 위험 → try/catch로 감싸 실패 시 기본 아바타로 대체
- **즐겨찾기 무한 로딩:** 로그아웃 상태에서 즐겨찾기 스트림이 `Stream.empty()`라 값을 하나도 안 내보내고 닫혀서 로딩 스피너가 멈추지 않던 버그 → `Stream.value(const [])`로 교체
- **카테고리/지역 목록 로딩 실패 시 복구 불가:** 네트워크 오류 시 두 칩 목록이 재시도 수단 없이 조용히 사라지던 문제 → 인라인 재시도 버튼 추가
- **번역 캐시 키 불안정:** 긴 텍스트의 캐시 키를 `String.hashCode`로 만들었는데, 이는 Dart 런타임 버전 간 안정성이 보장되지 않아 캐시가 조용히 무효화될 수 있는 구조 → 자체 구현한 안정적인 FNV-1a 해시로 교체

---

## 📈 6. 성과 및 회고

- Riverpod 기반 3단 배타적 필터(카테고리/지역/검색어) 상태 설계와 Repository + TtlCache 계층 분리를 통해, 별도 아키텍처 프레임워크 없이도 캐시-네트워크-UI 책임을 깔끔하게 나누는 구조를 경험했습니다.
- 무료 공개 API(TheMealDB, MyMemory) 두 개를 조합해 오프라인 캐싱과 자동 번역까지 갖춘 검색 경험을 완성했습니다.
- 기능 구현 이후 스스로 보안·버그 전수 점검을 진행하면서, Firestore 규칙 검증 부재나 릴리스 서명 폴백처럼 실제 배포 시 심각한 문제가 될 수 있었던 부분을 사전에 발견하고 고치는 과정을 경험했습니다.
- Google Play Console 비공개 테스트 등록의 전 과정(콘텐츠 등급 IARC 설문, 데이터 안전, 타겟층, 광고/정부앱/금융기능/건강 선언, 스토어 등록정보, 앱 카테고리·연락처)을 처음부터 끝까지 직접 진행했습니다.
- 향후 계획: 프로덕션 트랙 전환을 위한 테스터 12명/14일 요건 충족, 레시피 상세 화면에 재료 체크리스트·조리 타이머 같은 편의 기능 추가를 검토 중입니다.

---

## 📕 7. 버전 업데이트 내역

### v1.0.0 — 첫 출시 (비공개 테스트 제출)
- TheMealDB 기반 요리명 검색, 카테고리 필터, 레시피 상세(재료/조리법)
- 즐겨찾기(Firestore 연동), Google 로그인, 마이페이지(프로필 사진/이름/생년월일/휴대폰번호)
- 한↔영 자동 번역(검색어, 결과 이름, 조리법), Hive 기반 오프라인 캐싱
- 다크모드, 한국어/영어 다국어 지원
- Android 릴리스 서명(Keystore) 설정, 개인정보 처리방침·이용약관 페이지(GitHub Pages) 배포
- Google Play Console 비공개 테스트 등록: 콘텐츠 등급·데이터 보안·타겟층·스토어 등록정보 등 전 항목 완료 후 검토 제출

### v1.0.1 — 지역 필터 추가 및 보안/버그 전면 점검
- 검색 탭에 지역(국가)별 필터 추가 (28개 지역, 한글 라벨 매핑)
- 설정 화면의 계정 정보(생년월일/휴대폰번호) 중복 제거, 마이페이지로 일원화
- Firestore 보안 규칙에 필드 화이트리스트·크기 제한 추가 및 배포
- release 빌드 debug 서명 자동 폴백 제거(빌드 실패로 전환)
- 로그인 취소 버그, 로그아웃 후 Firestore 캐시 잔존, 프로필 사진 손상 시 크래시, 즐겨찾기 무한 로딩, 카테고리/지역 로딩 실패 시 복구 불가 등 안정성 버그 수정
- 번역 캐시 키 안정성 개선(자체 FNV-1a 해시), 미사용 이메일 로그인 코드 제거
