import 'package:battery_plus/battery_plus.dart';
import 'package:big_battery_app/providers/battery_provider.dart';
import 'package:big_battery_app/widgets/battery_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
const settings = BatterySettings(
  textSize: BatteryTextSize.large,
  themeMode: ThemeMode.light,
);

  testWidgets('배터리 퍼센트를 표시한다', (tester) async {
    const status = BatteryStatus(
      level: 72,
      state: BatteryState.discharging,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: BatteryDisplay(status: status, settings: settings),
      ),
    );

    expect(find.text('72%'), findsOneWidget);
    expect(find.text('배터리 사용 중'), findsOneWidget);
  });

  testWidgets('충전 중 아이콘을 노출한다', (tester) async {
    const status = BatteryStatus(
      level: 55,
      state: BatteryState.charging,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: BatteryDisplay(status: status, settings: settings),
      ),
    );

    expect(find.byIcon(Icons.flash_on), findsOneWidget);
  });
}
