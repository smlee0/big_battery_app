## Flutter 명령어

- `flutter pub get` — 의존성 설치/업데이트
- `flutter clean` — 빌드 산출물 초기화
- `flutter analyze` — 정적 분석
- `flutter test` — 단위/위젯 테스트 실행
- `flutter run --release -d <deviceId>` — 릴리스 모드 실행
- `flutter build apk --release` — 릴리스 APK 생성

## 디바이스 확인 & 제어

- `flutter devices` — 연결된 디바이스/에뮬레이터 목록
- `adb devices` — ADB로 인식된 디바이스 확인
- `adb shell dumpsys battery set level <0-100>` — 배터리 잔량 강제 설정
- `adb shell dumpsys battery set ac 1|0` — 충전 연결/해제 시뮬레이션
- `adb shell dumpsys battery reset` — 배터리 상태 초기화
- `adb shell dumpsys alarm | rg ACTION_REFRESH_WIDGET` — 예약된 위젯 갱신 알람 확인
- `adb logcat | rg ACTION_REFRESH_WIDGET` — 브로드캐스트 수신 여부 로그 확인

## 기타 자주 사용한 명령어

- `rg <pattern>` — 코드 베이스에서 텍스트 검색
- `git status -sb` — 변경 현황 요약
