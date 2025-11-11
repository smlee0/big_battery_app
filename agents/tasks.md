# 프로젝트 실행 준비 태스크

## 1. 플러터 환경 점검
- `flutter --version`으로 로컬 SDK가 3.x 이상인지 확인하고, 경고가 있으면 `flutter upgrade` 실행.
- `flutter doctor`를 돌려 Android/iOS toolchain, Chrome, VS Code/Android Studio 플러그인이 모두 준비됐는지 점검한다. 누락 항목은 doctor가 제시하는 명령으로 보완한다.

## 2. 의존성 동기화
- 프로젝트 루트(`/mnt/c/smlee/02.Project/app/big_battery_app`)에서 `flutter pub get`을 실행해 `pubspec.yaml`에 정의된 패키지를 설치한다.
- 설치 후 `pubspec.lock` 변화가 없는지 확인하고, 신규 패키지를 추가해야 한다면 `flutter pub add <package>`로 관리한다.

## 3. 코드 품질 체크
- `flutter analyze`로 기본 린트를 통과하는지 확인한다. 경고가 나오면 즉시 수정하고 commit 전에 다시 실행한다.
- 서식 불일치가 있으면 `dart format lib test`로 정렬한다.

## 4. 기본 테스트
- `flutter test`로 기존 위젯 테스트가 통과하는지 확인한다. 실패 시 로그를 정리하고 원인을 agents 디렉터리에 기록한다.

## 5. 로컬 실행
- Chrome 에뮬레이터가 기본이라면 `flutter run -d chrome`으로 실행해 홈 스크린이 뜨는지 확인한다.
- 물리/가상 디바이스에서 테스트하려면 `flutter devices`로 ID를 확인한 뒤 `flutter run -d <deviceId>`를 사용한다.

## 6. 결과 기록
- 각 단계에서 발생한 오류, 해결법, 추가 작업 필요 여부를 `agents/logs.md` (미존재 시 생성) 에 순차적으로 기록해 다음 태스크의 근거로 삼는다.

## 7. 릴리스 체크리스트
- **Android**
  - `android/key.properties`가 존재하고 네 개의 키(`storeFile`, `storePassword`, `keyAlias`, `keyPassword`)가 모두 채워져 있는지 확인한다.
  - `flutter build apk --release` 또는 `flutter build appbundle --release` 실행 후 출력물(AAB/APK)을 실제 기기에 설치해 위젯/알림이 동작하는지 검증한다.
  - Play Console 업로드 전 `bundletool validate`를 돌려 서명/패키지명 문제가 없는지 확인한다.
- **iOS**
  - Xcode에서 `Runner` 타깃의 Bundle ID, Team, Capabilities를 최신 상태로 맞춘 뒤 Archive → Validate/Distribute 테스트를 수행한다.
  - iOS 기기에서 `flutter run --release -d <device>`로 실제 하드웨어 테스트를 최소 1회 진행한다.
- **Web**
  - `web/manifest.json`, `web/index.html` 브랜드 문자열/아이콘이 최신 상태인지 확인한 뒤 `flutter build web --web-renderer html`을 실행한다.
  - Lighthouse PWA 체크, 이미지/LCP 이슈 등을 기록하고 호스팅 환경에 배포한다.

릴리스 작업을 마치면 모든 명령/결과를 `agents/logs.md`에 기록해 다음 배포 시 참고할 수 있도록 한다.
