// 글꼴 크기·테마·알림 설정 및 앱 정보를 제공하는 화면.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/battery_provider.dart';

/// 사용자 설정을 변경하고 앱 정보를 볼 수 있는 화면.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';
  static const _appName = 'Big Battery';
  static const _appVersion = 'v0.2.0';
  static const _developerEmail = '-';
  static const _developerName = '이세만두🥟';

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
          const SizedBox(height: 24),
          const _AppInfoCard(),
        ],
      ),
    );
  }
}

/// 앱 이름/버전/연락처를 보여주는 정보 카드.
class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('앱 정보', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            const _InfoRow(label: '앱 이름', value: SettingsScreen._appName),
            const SizedBox(height: 8),
            const _InfoRow(label: '버전', value: SettingsScreen._appVersion),
            const SizedBox(height: 8),
            const _InfoRow(label: '개발자 이메일', value: SettingsScreen._developerEmail),
            const SizedBox(height: 8),
            const _InfoRow(label: '개발자 이름', value: SettingsScreen._developerName),
          ],
        ),
      ),
    );
  }
}

/// 라벨과 값을 양쪽 정렬로 배치하는 재사용 행 위젯.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
