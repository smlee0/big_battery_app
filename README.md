# big_battery_widget_app

## Flutter 실행 진단

현재 `flutter run -d chrome` 과 `flutter doctor -v` 모두 아래와 같은 오류로 실패합니다.

```
/mnt/d/98.program/flutter/flutter_windows_3.32.5-stable/flutter/bin/internal/update_engine_version.sh: line 74: /mnt/d/98.program/flutter/flutter_windows_3.32.5-stable/flutter/bin/cache/engine.stamp: Permission denied
```

Flutter SDK가 Windows 파티션(`/mnt/d`)에 설치되어 있는 상태에서 WSL을 통해 실행하면 `bin/cache` 디렉터리를 갱신하려는 순간 쓰기 권한이 거부됩니다. 따라서 WSL 환경에서 Flutter를 사용하려면 **SDK를 Linux 파일 시스템(예: `~/development/flutter`)으로 옮기거나 새로 설치**해야 합니다. 요약하면 다음 중 하나를 선택하세요.

1. **WSL 내부로 Flutter SDK 복사**
   ```bash
   mkdir -p ~/development
   cp -r /mnt/d/98.program/flutter/flutter_windows_3.32.5-stable/flutter ~/development/flutter
   echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   flutter doctor -v
   ```
   이렇게 하면 `~/development/flutter/bin/cache` 에 정상적으로 쓰기가 가능해집니다.

2. **Windows(PowerShell/CMD)에서만 Flutter 명령 실행**  
   SDK가 Windows용으로 설치되어 있으므로, 동일한 경로에서 PowerShell을 열어 `flutter run` 을 실행하면 권한 문제가 발생하지 않습니다. 단, 이 경우 WSL에서 명령을 실행하지 않아야 합니다.

권한 문제가 해결된 뒤에는 반드시 `flutter doctor -v` 로 SDK와 디바이스 상태를 확인하세요.

## 주요 기능 개요

- **큰 배터리 카드**: `BatteryWidget`이 퍼센트·충전 상태를 크게 보여주며 배터리 수준에 따라 색상이 바뀝니다.
- **실시간 상태 갱신**: `BatteryProvider`가 `battery_plus` 스트림을 구독하고 1분마다 자동 새로고침합니다.
- **저전력 알림**: 배터리가 20% 이하이면서 충전 중이 아니면 `flutter_local_notifications`로 경고 알림을 띄웁니다.
- **접근성 설정**: 글씨 크기(크게/아주 크게), 고대비 모드, 라이트/다크 테마, 자동 갱신 여부를 설정 화면에서 토글할 수 있습니다.
- **설정 영속화**: `shared_preferences`에 저장해 앱 재시작 후에도 동일한 환경을 유지합니다.

## 폴더 구조

```
lib/
 ├── app.dart                  # Provider + MaterialApp 부트스트랩
 ├── main.dart                 # 서비스 초기화 진입점
 ├── providers/battery_provider.dart
 ├── screens/
 │    ├── home_screen.dart     # BatteryWidgetScreen
 │    └── settings_screen.dart # 접근성/테마 설정
 ├── services/
 │    ├── battery_service.dart
 │    └── notification_service.dart
 ├── widgets/
 │    ├── battery_display.dart
 │    └── battery_widget.dart
 └── utils/theme.dart
test/
 └── widgets/battery_display_test.dart
```

## 안드로이드 홈 위젯

- `android/app/src/main/kotlin/com/example/big_battery_widget_app/BatteryStatusWidget.kt`: 안드로이드 `AppWidgetProvider`가 현재 배터리 잔량과 충전 상태를 읽어 원격뷰에 반영합니다.
- `android/app/src/main/res/layout/widget_big_battery.xml`: 2x2 기본 크기, 4x2까지 리사이즈 가능한 카드 레이아웃입니다. 퍼센트·상태 텍스트와 진행바, 충전 아이콘을 포함합니다.
- `android/app/src/main/res/xml/battery_widget_info.xml`: 위젯 메타데이터로 최소/최대 크기 및 30분 주기 자동 갱신을 정의합니다.

### 설치·확인 방법

1. APK 설치: `flutter install` 또는 `flutter run -d <android_device>`로 실제 기기/에뮬레이터에 앱을 배포합니다.
2. 홈 화면에서 길게 눌러 **위젯** 목록을 열고 “큰 배터리 위젯”을 2x2 크기로 추가합니다.
3. 위젯을 길게 눌러 리사이즈 핸들을 드래그하면 4x2 크기로 확장되어 가로형 배치가 적용됩니다.
4. 충전 케이블 연결/분리 또는 배터리 잔량 변화를 주면 위젯이 자동으로 새 데이터를 표시합니다. 즉시 갱신이 필요하면 위젯을 탭해 앱을 연 뒤 알림센터를 내렸다 닫거나, 위젯 옵션에서 ‘새로 고침’(앱→위젯 업데이트)으로 갱신할 수 있습니다.

## 실행 방법

1. **의존성 설치**
   ```bash
   flutter pub get
   ```
2. **정적 분석**
   ```bash
   flutter analyze
   ```
3. **테스트**
   ```bash
   flutter test
   ```
4. **앱 실행 (예: Chrome)**
   ```bash
   flutter run -d chrome
   ```

Chrome 외의 디바이스를 사용하려면 `flutter devices` 로 가능한 타겟을 확인한 뒤 원하는 디바이스 ID를 `-d` 옵션에 전달하면 됩니다. Web 실행 시 렌더러가 필요하면 `--web-renderer html` 또는 `--web-renderer canvaskit` 을 추가하세요.

필요에 따라 `flutter clean` 으로 캐시를 초기화한 뒤 다시 `flutter pub get` 을 실행하면 의존성 관련 문제를 빠르게 해결할 수 있습니다.
