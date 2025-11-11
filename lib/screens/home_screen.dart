// 배터리 대시보드와 상세 정보를 보여주는 홈 화면 위젯.
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/battery_provider.dart';
import '../widgets/battery_widget.dart';
import 'settings_screen.dart';

/// 홈 탭에서 배터리 카드·상세·설정 버튼을 제공하는 화면.
class BatteryWidgetScreen extends StatelessWidget {
  const BatteryWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BatteryProvider>(
      builder: (context, provider, _) {
        final status = provider.status;
        final settings = provider.settings;

        return Scaffold(
          appBar: AppBar(
            title: const Text('큰 배터리'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: '설정',
                onPressed: () => Navigator.of(context).pushNamed(
                  SettingsScreen.routeName,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                BatteryWidget(status: status, settings: settings),
                const SizedBox(height: 24),
                _StatusCard(provider: provider),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(
                    SettingsScreen.routeName,
                  ),
                  icon: const Icon(Icons.tune),
                  label: const Text('설정으로 이동'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 현재 상태·동기화 시각·테마 정보를 묶어 보여주는 카드.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.provider});

  final BatteryProvider provider;

  @override
  Widget build(BuildContext context) {
    final status = provider.status;
    final textTheme = Theme.of(context).textTheme;
    final hintStyle =
        textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600);
    final formatter = DateFormat('HH:mm');
    final lastUpdated = status.lastUpdated != null
        ? formatter.format(status.lastUpdated!)
        : '동기화 대기 중';

    final stateLabel = _stateLabel(status);
    final stateColor = _stateColor(status, context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('상세 정보', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.battery_full, size: 20),
                const SizedBox(width: 8),
                Text(
                  '상태: $stateLabel',
                  style: hintStyle?.copyWith(color: stateColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.update, size: 20),
                const SizedBox(width: 8),
                Text('마지막 동기화: $lastUpdated', style: hintStyle),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.palette, size: 20),
                const SizedBox(width: 8),
                Text(
                  '테마: ${provider.settings.themeMode == ThemeMode.dark ? '다크' : '화이트'}',
                  style: hintStyle,
                ),
              ],
            ),
            if (status.errorMessage != null) ...[
              const Divider(height: 24),
              Text(
                '오류가 발생했습니다. 잠시 후 자동으로 다시 시도합니다.',
                style: textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _stateLabel(BatteryStatus status) {
    switch (status.state) {
      case BatteryState.charging:
        return '충전 중';
      case BatteryState.full:
        return '충전 완료';
      case BatteryState.discharging:
        return '배터리 사용 중';
      default:
        return '상태 확인 중';
    }
  }

  Color _stateColor(BatteryStatus status, BuildContext context) {
    if (status.isCharging) {
      return Theme.of(context).colorScheme.primary;
    }
    if (status.isLow) {
      return Theme.of(context).colorScheme.error;
    }
    if (status.level <= 50) {
      return Colors.orange;
    }
    return Colors.green;
  }
}
