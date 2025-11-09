import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/battery_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BatteryProvider>();
    final settings = provider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Text('글씨 크기', style: Theme.of(context).textTheme.titleMedium),
          ...BatteryTextSize.values.map(
            (textSize) => RadioListTile<BatteryTextSize>(
              title: Text(textSize.label),
              value: textSize,
              groupValue: settings.textSize,
              onChanged: (value) {
                if (value != null) {
                  provider.updateTextSize(value);
                }
              },
            ),
          ),
          const Divider(height: 32),
          SwitchListTile(
            title: const Text('다크 테마'),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) => provider.updateThemeMode(
              value ? ThemeMode.dark : ThemeMode.light,
            ),
            subtitle: const Text('어두운 배경을 선호할 때 사용하세요.'),
          ),
          SwitchListTile(
            title: const Text('저전력 알림'),
            value: settings.notificationsEnabled,
            onChanged: provider.toggleNotifications,
            subtitle: const Text('배터리 20% 이하일 때 알림을 받습니다.'),
          ),
        ],
      ),
    );
  }
}
