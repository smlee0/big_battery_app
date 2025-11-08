= Big Battery Widget App =

== 개요 ==
Big Battery Widget App은 Flutter로 제작된 배터리 정보 위젯 데모 애플리케이션이다. 커다란 배터리 카드 위젯, 실시간 상태 갱신, 저전력 알림, 접근성 설정, 설정 영속화 등 모바일 환경에서 배터리 상태를 직관적으로 확인하고 관리하는 데 초점을 맞추고 있다.

== Flutter 실행 진단 ==
현재 ``flutter run -d chrome`` 과 ``flutter doctor -v`` 모두 아래와 같은 오류로 실패한다.

 <syntaxhighlight lang="bash">
 /mnt/d/98.program/flutter/flutter_windows_3.32.5-stable/flutter/bin/internal/update_engine_version.sh: line 74: /mnt/d/98.program/flutter/flutter_windows_3.32.5-stable/flutter/bin/cache/engine.stamp: Permission denied
 </syntaxhighlight>

Windows 파티션(``/mnt/d``)에 설치된 Flutter SDK를 WSL에서 실행하면 ``bin/cache`` 디렉터리를 갱신하는 순간 쓰기 권한이 거부된다. 문제를 해결하려면 아래 두 가지 방법 중 하나를 선택한다.

=== 방법 1: WSL 내부로 Flutter SDK 복사 ===
 # ``mkdir -p ~/development``
 # ``cp -r /mnt/d/98.program/flutter/flutter_windows_3.32.5-stable/flutter ~/development/flutter``
 # ``echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc``
 # ``source ~/.bashrc``
 # ``flutter doctor -v``
위 단계를 따르면 ``~/development/flutter/bin/cache`` 경로에 정상적으로 쓰기가 가능해진다.

=== 방법 2: Windows 환경에서만 Flutter 명령 실행 ===
PowerShell 또는 CMD에서 동일한 SDK 경로로 이동한 뒤 ``flutter run`` 을 실행하면 권한 문제가 발생하지 않는다. 단, 이 경우 WSL에서는 Flutter 명령을 실행하지 않는다. 권한 문제가 해소된 뒤에는 반드시 ``flutter doctor -v`` 로 SDK와 디바이스 상태를 재확인한다.

== 주요 기능 ==
* '''큰 배터리 카드''' — ``BatteryWidget``이 퍼센트와 충전 상태를 크게 표시하고 배터리 수준에 따라 색상이 변한다.
* '''실시간 상태 갱신''' — ``BatteryProvider``가 ``battery_plus`` 스트림을 구독하며 1분마다 자동 새로 고침한다.
* '''저전력 알림''' — 배터리가 20% 이하이면서 충전 중이 아니면 ``flutter_local_notifications``로 경고 알림을 보낸다.
* '''접근성 설정''' — 글씨 크기(크게/아주 크게), 고대비 모드, 라이트/다크 테마, 자동 갱신 여부를 설정 화면에서 토글할 수 있다.
* '''설정 영속화''' — ``shared_preferences``에 환경을 저장하여 앱 재시작 후에도 동일한 설정을 유지한다.

== 폴더 구조 ==
<syntaxhighlight lang="text">
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
</syntaxhighlight>

== 안드로이드 홈 위젯 ==
* ``android/app/src/main/kotlin/com/example/big_battery_widget_app/BatteryStatusWidget.kt`` — ``AppWidgetProvider``가 현재 배터리 잔량과 충전 상태를 읽어 원격 뷰에 반영한다.
* ``android/app/src/main/res/layout/widget_battery_meter.xml`` — 2x1 기본 크기를 갖는 카드 레이아웃으로 퍼센트·상태 텍스트, 진행 바, 충전 아이콘을 포함한다.
* ``android/app/src/main/res/xml/battery_widget_info.xml`` — 위젯 메타데이터로 30분 주기 자동 갱신과 가로 방향 리사이즈(높이 1셀 고정, 너비 확장)를 정의한다.

=== 설치 및 확인 절차 ===
# ``flutter install`` 또는 ``flutter run -d <android_device>`` 로 실제 기기나 에뮬레이터에 앱을 배포한다.
# 홈 화면에서 길게 눌러 '''위젯''' 목록을 열고 “큰 배터리 위젯”을 2x1 크기로 추가한다.
# 위젯을 길게 눌러 가로 리사이즈 핸들을 드래그하면 1행을 유지한 채 너비가 확장되어 더 긴 게이지 레이아웃이 적용된다.
# 충전 케이블 연결/분리 또는 배터리 잔량 변화를 주면 위젯이 자동으로 새 데이터를 표시한다. 즉시 갱신이 필요하면 위젯을 탭해 앱을 연 뒤 알림 센터를 내렸다 닫거나 위젯 옵션에서 ‘새로 고침’을 선택한다.

== 실행 방법 ==
# 의존성 설치 — ``flutter pub get``
# 정적 분석 — ``flutter analyze``
# 테스트 — ``flutter test``
# 앱 실행(예: Chrome) — ``flutter run -d chrome``

다른 디바이스를 사용하려면 ``flutter devices`` 로 타깃을 확인하고 원하는 디바이스 ID를 ``-d`` 옵션에 전달한다. Web 실행에서 렌더러가 필요하면 ``--web-renderer html`` 또는 ``--web-renderer canvaskit`` 옵션을 추가한다. 필요 시 ``flutter clean`` 으로 캐시를 초기화한 뒤 다시 ``flutter pub get`` 을 실행해 의존성 문제를 해결한다.
