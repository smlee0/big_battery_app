import 'dart:async';
import 'dart:io' show Platform;

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';

class BatteryService {
  BatteryService({Battery? battery}) : _battery = battery ?? Battery();

  final Battery _battery;
  static const _batteryEventChannel =
      EventChannel('com.bigbattery/battery_updates');

  Future<int> getBatteryLevel() => _battery.batteryLevel;

  Future<BatteryState> getBatteryState() async {
    try {
      return await _battery.batteryState;
    } catch (_) {
      return BatteryState.unknown;
    }
  }

  Stream<BatteryState> get onBatteryStateChanged =>
      _battery.onBatteryStateChanged;

  Stream<BatterySnapshotUpdate> watchBatterySnapshots() {
    if (!Platform.isAndroid) {
      return const Stream.empty();
    }
    return _batteryEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => BatterySnapshotUpdate.fromMap(
              Map<String, dynamic>.from(event as Map),
            ));
  }
}

class BatterySnapshotUpdate {
  const BatterySnapshotUpdate({
    required this.level,
    required this.statusText,
    required this.isCharging,
    required this.timestamp,
  });

  final int level;
  final String statusText;
  final bool isCharging;
  final int timestamp;

  BatteryState get derivedState {
    if (isCharging && level >= 100) {
      return BatteryState.full;
    }
    return isCharging ? BatteryState.charging : BatteryState.discharging;
  }

  DateTime get updatedAt =>
      DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);

  factory BatterySnapshotUpdate.fromMap(Map<String, dynamic> map) {
    return BatterySnapshotUpdate(
      level: (map['level'] as num?)?.toInt() ?? 0,
      statusText: map['statusText'] as String? ?? '',
      isCharging: map['isCharging'] as bool? ?? false,
      timestamp: (map['timestamp'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}
