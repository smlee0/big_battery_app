import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

import '../providers/battery_provider.dart';
import '../utils/theme.dart';

class BatteryDisplay extends StatelessWidget {
  const BatteryDisplay({
    super.key,
    required this.status,
    required this.settings,
  });

  final BatteryStatus status;
  final BatterySettings settings;

  Color _levelColor(BuildContext context) {
    if (status.level <= 20) {
      return settings.highContrast ? Colors.redAccent : AppColors.alertRed;
    }

    if (status.level <= 50) {
      return settings.highContrast
          ? Colors.orangeAccent
          : AppColors.warningYellow;
    }

    return settings.highContrast
        ? Colors.lightGreenAccent
        : AppColors.safeGreen;
  }

  String _statusLabel() {
    return switch (status.state) {
      BatteryState.charging => '충전 중',
      BatteryState.discharging => '배터리 사용 중',
      BatteryState.full => '충전 완료',
      _ => '상태 확인 중',
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final levelColor = _levelColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${status.level}%',
              style: textTheme.displayMedium?.copyWith(
                color: levelColor,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            if (status.isCharging)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.flash_on,
                  color: levelColor,
                  size: 40,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _statusLabel(),
          style: textTheme.titleMedium?.copyWith(
            color: levelColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (status.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            '오류: ${status.errorMessage}',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.alertRed),
          ),
        ],
      ],
    );
  }
}
