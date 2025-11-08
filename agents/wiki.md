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
