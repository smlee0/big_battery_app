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
            title: const Text('고대비 모드'),
            value: settings.highContrast,
            onChanged: provider.toggleHighContrast,
            subtitle: const Text('명암 대비를 높여 가독성을 높입니다.'),
          ),
          SwitchListTile(
            title: const Text('자동 갱신'),
            value: settings.autoRefresh,
            onChanged: provider.toggleAutoRefresh,
            subtitle: const Text('1분마다 배터리 정보를 자동으로 새로고칩니다.'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: provider.refreshBatteryStatus,
            icon: const Icon(Icons.refresh),
            label: const Text('지금 배터리 정보 갱신'),
          ),
        ],
      ),
    );
  }
}
