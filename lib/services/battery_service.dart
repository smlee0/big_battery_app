// battery_plus 와 네이티브 EventChannel 을 묶어 배터리 정보를 제공하는 서비스.
import 'dart:async';
import 'dart:io' show Platform;

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';

/// 배터리 퍼센트/상태 및 안드로이드 스냅샷 스트림을 노출하는 헬퍼.
class BatteryService {
  BatteryService({Battery? battery}) : _battery = battery ?? Battery();

  final Battery _battery;
  // Android 네이티브 EventChannel에서 전달되는 배터리 스냅샷 스트림
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
      // iOS/Web은 EventChannel을 사용하지 않으므로 빈 스트림을 반환
      return const Stream.empty();
    }
    return _batteryEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => BatterySnapshotUpdate.fromMap(
              Map<String, dynamic>.from(event as Map),
            ));
  }
}

/// 안드로이드 네이티브에서 전달되는 배터리 스냅샷 모델.
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
