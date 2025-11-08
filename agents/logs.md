# 2024-11-08 실행 체크 로그

1. `flutter_windows` SDK가 WSL에서 동작하지 않아 `git clone https://github.com/flutter/flutter.git -b 3.24.3`로 리눅스용 SDK를 내려받고 `.flutter-sdk/`에 배치했다. `local-bin/unzip`을 PATH에 추가해 Flutter가 필요한 압축 해제를 수행하도록 설정.
2. Flutter가 HOME 디렉터리에 설정 파일을 쓰지 못해 `HOME=$PWD/.home`으로 로컬 홈을 만들고 `flutter config --enable-web` 적용.
3. `flutter pub get` 실행 시 pub.dev 접근이 차단되어 권한 상승 모드로 재실행 후 성공.
4. `flutter analyze`는 정상 통과.
5. `flutter test`가 VM 서비스 포트 바인딩 제한으로 실패하여 권한 상승 모드로 재실행했고 기본 위젯 테스트 1건 모두 통과.
6. `flutter run -d web-server --web-port=5000 --web-hostname=127.0.0.1 --no-hot`으로 웹 서버 타깃 실행. 앱이 `http://127.0.0.1:5000`에서 서빙되는 것을 확인했으며 명령은 대기 상태라 수동 종료 필요.

# 2024-11-09 실행 체크 로그

1. `flutter run -d chrome` / `flutter doctor -v` 실행 시 `/mnt/d/.../engine.stamp: Permission denied`가 발생했다. Windows 드라이브에 설치된 Flutter SDK가 WSL에서 쓰기 권한을 가지지 못하는 것이 원인임을 확인.
2. SDK를 WSL 내부로 복사하거나 Windows PowerShell에서만 명령을 실행해야 한다는 해결책을 `README.md`에 기록했다.
3. 권한 문제가 풀리지 않아 `flutter pub get`, `flutter analyze`, `flutter test`는 이번 시도에서 실행하지 못했다. Flutter 명령을 재시도하기 전까지는 README에 정리된 SDK 이전 절차를 따라야 함.
4. 로컬 `.flutter-sdk/bin/flutter pub get` 을 실행했으며 네트워크 접근 승인을 받아 의존성 설치를 완료했다.
5. `flutter analyze` 는 `/home/blue92lee/.dartServer` 생성 권한 문제로 실패했으나 `HOME=$PWD/.home` 환경변수를 주고 재실행해 통과했다.
6. `flutter test` 는 VM 서비스 포트 생성 제한으로 인해 기본 모드에서 실패하여 권한 상승 모드로 재실행했고 모든 위젯 테스트가 통과했다.
7. 안드로이드 홈 위젯(`BatteryStatusWidget`)을 추가하고 레이아웃/메타데이터/리시버를 구성했다. `flutter` 명령은 변경 없이, 위젯 확인은 실제 단말/에뮬레이터에서 홈 화면 위젯 추가로 진행해야 함.
