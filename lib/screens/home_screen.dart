import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/battery_provider.dart';
import '../widgets/battery_widget.dart';
import 'settings_screen.dart';

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
            title: const Text('큰 배터리 위젯'),
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
            child: RefreshIndicator(
              onRefresh: provider.refreshBatteryStatus,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  BatteryWidget(status: status, settings: settings),
                  const SizedBox(height: 24),
                  _StatusCard(provider: provider),
                  const SizedBox(height: 16),
                  _Actions(provider: provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.provider});

  final BatteryProvider provider;

  @override
  Widget build(BuildContext context) {
    final status = provider.status;
    final textTheme = Theme.of(context).textTheme;
    final hintStyle =
        textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('상세 정보', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.update, size: 20),
                const SizedBox(width: 8),
                Text(
                  status.lastUpdated != null
                      ? '${status.lastUpdated}'
                      : '초기 데이터를 불러오는 중입니다.',
                  style: hintStyle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.autorenew, size: 20),
                const SizedBox(width: 8),
                Text(
                  provider.settings.autoRefresh
                      ? '자동 갱신 (${provider.settings.refreshInterval.inMinutes}분)'
                      : '수동 갱신',
                  style: hintStyle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.visibility, size: 20),
                const SizedBox(width: 8),
                Text(
                  provider.settings.highContrast ? '고대비 모드 사용 중' : '기본 대비 모드',
                  style: hintStyle,
                ),
              ],
            ),
            if (status.errorMessage != null) ...[
              const Divider(height: 24),
              Text(
                '오류가 발생했습니다. 새로고침을 눌러 다시 시도해 주세요.',
                style: textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.provider});

  final BatteryProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed:
              provider.isRefreshing ? null : provider.refreshBatteryStatus,
          icon: provider.isRefreshing
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: Text(provider.isRefreshing ? '갱신 중...' : '지금 갱신'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(
            SettingsScreen.routeName,
          ),
          icon: const Icon(Icons.tune),
          label: const Text('설정으로 이동'),
        ),
      ],
    );
  }
}
