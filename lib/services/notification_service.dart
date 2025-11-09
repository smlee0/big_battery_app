import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static const _channelId = 'battery_alerts';

  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initializationSettings);
    await _ensureAndroidPermissions();
  }

  Future<void> showLowBatteryAlert({
    required int batteryLevel,
    required bool isCharging,
  }) async {
    if (kIsWeb) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Battery Alerts',
      channelDescription: '배터리 수준 관련 알림',
      importance: Importance.max,
      priority: Priority.high,
    );

    try {
      await _plugin.show(
        1001,
        '배터리가 $batteryLevel% 남았어요',
        isCharging ? '현재 충전 중입니다.' : '충전을 시작해 주세요.',
        const NotificationDetails(android: androidDetails),
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to show notification: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _ensureAndroidPermissions() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      return;
    }

    final granted = await androidPlugin.areNotificationsEnabled();
    if (granted == null || !granted) {
      await androidPlugin.requestNotificationsPermission();
    }
  }
}
