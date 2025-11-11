# big_battery_app

> Flutter 기반으로 제작된 접근성 친화 배터리 모니터링 앱과 안드로이드 홈 위젯 샘플입니다. 실시간 배터리 스트림, 저전력 알림, 사용자 설정 영속화를 통해 실제 디바이스의 배터리 상태를 직관적으로 확인할 수 있습니다.

## 📷 Screen Gallery

| ![앱 홈 – 밝은 테마](docs/images/placeholder_app_home_1.png) | ![앱 홈 – 다크 테마](docs/images/placeholder_app_home_2.png) |
| --- | --- |
| ![홈 위젯 – 기본](docs/images/placeholder_widget_1.png) | ![홈 위젯 – 충전 중](docs/images/placeholder_widget_2.png) |

> 이미지는 `docs/images/` 폴더에서 관리하며, 새 캡처를 촬영하면 동일한 파일명을 교체하거나 표를 확장하면 됩니다.

---

## 프로젝트 소개

- **큰 배터리 카드**: `BatteryWidget`이 퍼센트와 충전 상태를 크게 보여 주고 남은 용량 구간에 맞춰 색을 변경합니다.
- **실시간 스트림**: `BatteryProvider`가 `battery_plus` 스트림과 네이티브 위젯 브로드캐스트를 모두 구독해 앱/홈 위젯을 동시에 갱신합니다.
- **저전력 알림**: 잔량 20% 이하 & 미충전 시 `flutter_local_notifications`로 경고 알림을 발송하고 Android 13+ 권한 요청을 처리합니다.
- **간결한 설정**: 글꼴 크기, 라이트/다크 테마, 저전력 알림 여부만 남겨 사용성이 단순해졌으며 모든 값은 `shared_preferences`에 저장됩니다.
- **안드로이드 홈 위젯**: `BatteryStatusWidget`이 충전 이벤트 브로드캐스트와 위젯 내 새로고침 버튼으로 앱 실행 여부와 관계없이 상태를 반영합니다.

## 현재 버전 하이라이트

- 앱 홈 상세 카드에서 배터리 상태/동기화 시각/현재 테마를 한눈에 확인하고, 위젯과 동일한 색상 체계를 적용했습니다.
- 홈 위젯은 좌상단 충전 배지, 우상단 새로고침 버튼으로 고정 배치되어 UX가 단순합니다.
- 고대비 테마는 기본 UI 팔레트로 통합해 별도 토글이 필요 없으며, 라이트/다크 전환만 유지합니다.

## 폴더 구조

```text
lib/
 ├── app.dart                   # Provider + MaterialApp 부트스트랩
 ├── main.dart                  # 서비스 초기화 엔트리포인트
 ├── providers/battery_provider.dart
 ├── screens/
 │    ├── home_screen.dart      # 배터리 대시보드
 │    └── settings_screen.dart  # 글꼴/테마/알림 설정
 ├── services/
 │    ├── battery_service.dart
 │    └── notification_service.dart
 ├── widgets/
 │    ├── battery_display.dart
 │    └── battery_widget.dart
 └── utils/theme.dart
test/
 └── widgets/battery_display_test.dart
android/app/src/main/kotlin/com/bigbattery/
 ├── BatteryStatusWidget.kt         # AppWidgetProvider
 ├── BatterySnapshotProvider.kt     # 네이티브 배터리 측정
 └── MainActivity.kt                # EventChannel + Flutter 엔진
```

## 추가 문서

빌드/설정/운영 가이드는 `agents/` 디렉터리의 문서를 참고하세요. README에는 앱 소개와 구조만 유지합니다.

문의나 개선 제안은 이 레포지토리의 이슈 트래커에 등록해 주세요.
