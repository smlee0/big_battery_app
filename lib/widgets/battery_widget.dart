import 'package:flutter/material.dart';

import '../providers/battery_provider.dart';
import 'battery_display.dart';

class BatteryWidget extends StatelessWidget {
  const BatteryWidget({
    super.key,
    required this.status,
    required this.settings,
  });

  final BatteryStatus status;
  final BatterySettings settings;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.black,
      Colors.grey.shade900,
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: BatteryDisplay(status: status, settings: settings),
    );
  }
}
