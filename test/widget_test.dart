import 'package:battery_plus/battery_plus.dart';
import 'package:big_battery_app/providers/battery_provider.dart';
import 'package:big_battery_app/widgets/battery_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
const settings = BatterySettings(
  textSize: BatteryTextSize.extraLarge,
  themeMode: ThemeMode.light,
);

  testWidgets('BatteryWidget shows percent text', (tester) async {
    const status = BatteryStatus(level: 88, state: BatteryState.discharging);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BatteryWidget(status: status, settings: settings),
        ),
      ),
    );

    expect(find.text('88%'), findsOneWidget);
  });
}
