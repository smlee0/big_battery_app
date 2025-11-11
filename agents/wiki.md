# Big Battery 프로젝트 위키

## 1. 프로젝트 개요
- Flutter 기반 배터리 상태 앱 & 안드로이드 홈 위젯
- 실시간 배터리 퍼센티지 / 충전 여부 표시, 저전력 알림 제공
- 런처 아이콘 & 앱명(EN: Big Battery / KO: 큰 배터리) 현지화
- 홈 위젯은 2x1 전용, 숫자·퍼센트·게이지가 고정 레이아웃으로 유지

## 2. 환경 준비 및 실행
1. Flutter 3.32.x 이상 설치, `flutter doctor` 확인  
2. 루트에서 `flutter pub get`  
3. (필요 시) `flutter clean && flutter pub get`  
4. 실행  
   - Android: `flutter run -d emulator-5554`  
   - iOS: Xcode에서 Runner 타겟 실행  
5. 검증  
   - `flutter analyze`  
   - `flutter test`  
6. 홈 위젯 테스트: 앱 설치 → 홈에 “큰 배터리” 위젯 추가 (2x1 유지)

## 3. 프로젝트 구조
```
lib/
├─ main.dart                # 앱 부트스트랩
├─ app.dart                 # MaterialApp + Provider 설정
├─ providers/
│   └─ battery_provider.dart  # 상태/설정/알림 제어
├─ services/
│   ├─ battery_service.dart   # battery_plus + EventChannel
│   └─ notification_service.dart
├─ screens/
│   ├─ home_screen.dart
│   └─ settings_screen.dart
├─ widgets/
│   ├─ battery_widget.dart
│   └─ battery_display.dart
└─ utils/theme.dart

android/
├─ app/src/main/kotlin/.../
│   ├─ MainActivity.kt           # EventChannel
│   ├─ BatterySnapshotProvider.kt
│   └─ BatteryStatusWidget.kt    # 홈 위젯
├─ app/src/main/res/
│   ├─ layout/widget_battery_meter.xml
│   ├─ drawable/* (위젯/런처 아이콘)
│   └─ xml/battery_widget_info.xml
└─ AndroidManifest.xml           # 위젯 등록, 다국어 앱명

ios/
├─ Runner/Info.plist             # EN 기본
├─ Runner/Base.lproj/InfoPlist.strings  # EN 표시명
└─ Runner/ko.lproj/InfoPlist.strings    # KO 표시명
```

## 4. 주요 기능 요약
- EventChannel로 배터리 변경 스트리밍 → Flutter UI 즉시 갱신
- BatteryProvider가 자동/수동 갱신, 텍스트 크기, 고대비 옵션 관리
- NotificationService로 저전력 시 로컬 알림 발송
- 홈 위젯: 네이티브로 직접 배터리 스냅샷 읽어 RemoteViews 업데이트

## 5. 유지보수 팁
- 코드 수정 시 `dart format lib test`, `flutter analyze`, `flutter test`
- 위젯 UI 변경 후 홈 위젯을 삭제/재추가하여 레이아웃 캐시 초기화
- 안드로이드 리소스를 추가할 때 `AndroidManifest.xml`/`appwidget-provider` 동기화

## 6. 환경 주의사항
- **Flutter SDK 경로 (WSL)**: `/mnt/d` 등 Windows 파티션의 SDK를 참조하면 권한 문제가 발생하므로, 레포지토리 내 `.flutter-sdk/bin`을 PATH 맨 앞에 두고 `hash -r && flutter doctor -v`로 확인한다.
- **WSL ↔ Windows 권한**: Windows 파티션에서 Flutter 명령을 실행하면 `bin/cache` 갱신 시 `Permission denied`가 날 수 있다. 가능하면 WSL 홈 디렉터리나 repo 내부에서만 명령을 실행한다.
- **네트워크 차단 환경**: `flutter build apk --release`는 `storage.googleapis.com`에서 엔진 아티팩트를 받아온다. 프록시/방화벽으로 막히면 미리 ZIP을 내려 받아 `.flutter-sdk/bin/cache`에 넣고 다시 시도한다.
- **알림 권한 (Android 13+)**: `POST_NOTIFICATIONS` 권한이 필요하다. 최초 실행 시 권한 요청이 보이지 않으면 사용자에게 `설정 > 애플리케이션 > 알림`에서 수동 허용을 안내한다.

## 7. 배포 & 서명 가이드
### Android
1. `keytool -genkey -v -keystore android/app/bigbattery-release-key.jks -alias bigbattery-key -keyalg RSA -keysize 2048 -validity 10000`
2. `android/key.properties.example`를 복사해 `android/key.properties`를 만들고 아래 항목을 채운다.
   ```
   storeFile=android/app/bigbattery-release-key.jks
   storePassword=<keystore password>
   keyAlias=bigbattery-key
   keyPassword=<alias password>
   ```
3. 서명 정보가 존재하면 `flutter build apk --release`가 자동으로 릴리스 키로 서명된다. 파일이 없으면 Gradle에서 경고를 띄우고 디버그 키로 빌드되므로, 배포 전 반드시 값이 채워져 있어야 한다.

### iOS
- `Runner` 타깃의 `PRODUCT_BUNDLE_IDENTIFIER`를 App Store Connect에 예약된 값으로 맞추고, Xcode Signing & Capabilities에서 `DEVELOPMENT_TEAM` 및 배포 프로비저닝 프로파일을 지정한다.
- `flutter build ipa` 또는 Xcode Archive → Distribute 워크플로우로 TestFlight/스토어 빌드를 생성한다. 배터리 위젯은 Android 전용이라 iOS에서는 권한 안내만 남아 있는지 확인한다.

### Web
- `web/manifest.json`, `web/index.html`의 `name`, `short_name`, `description`, theme/background color, 아이콘 경로를 실제 브랜드 자산으로 교체한다.
- 배포 대상에 맞춰 `flutter build web --web-renderer html` 혹은 `canvaskit`을 실행하고, 정적 호스팅에 올리기 전에 PWA Lighthouse 레포트를 확인한다.

### 스토어 자산
- README 및 `docs/images/placeholder_*.png`는 실제 기기/위젯 캡처로 교체해 스토어 스크린샷/마케팅 이미지로 재활용한다.
- 저전력 알림, 라이트/다크 테마, 홈 위젯 등 주요 플로우를 최소 3장 이상 캡처한다.

## 8. 트러블슈팅 메모
- Flutter 명령이 특정 SDK로 고정되지 않으면 `which flutter`로 실제 경로를 확인하고, 잘못된 PATH를 셸 설정에서 제거한다.
- `Execution failed for task :app:processReleaseResources` 발생 시 `flutter clean && flutter pub get` 후 다시 빌드한다.
- 홈 위젯이 업데이트되지 않으면 `adb shell dumpsys alarm | rg ACTION_REFRESH_WIDGET`으로 예약된 알람을 확인하거나, `adb shell am broadcast -a com.bigbattery.ACTION_REFRESH_WIDGET`으로 수동 트리거한다.
