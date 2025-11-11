// 퍼센트 숫자/아이콘/에러 메시지를 그리는 배터리 표시 위젯.
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

import '../providers/battery_provider.dart';
import '../utils/theme.dart';

/// 현재 배터리 수치와 충전 여부를 강조해 보여주는 컴포넌트.
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
      return Colors.redAccent;
    }
    if (status.level <= 50) {
      return Colors.orangeAccent;
    }
    return Colors.lightGreenAccent;
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
              style: textTheme.displayLarge?.copyWith(
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
