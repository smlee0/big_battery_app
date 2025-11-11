// 로컬 알림 권한을 확인하고 저전력 알림을 발송하는 서비스.
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 플랫폼별 로컬 알림 초기화 및 발송을 담당하는 유틸 클래스.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static const _channelId = 'battery_alerts';

  /// 앱 시작 시 알림 채널을 준비하고 권한을 확인한다.
  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      'ic_battery_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initializationSettings);
    await _ensureAndroidPermissions();
  }

  /// 배터리 잔량과 충전 상태를 메시지로 표시하는 경고 알림.
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

  /// POST_NOTIFICATIONS 권한이 없으면 사용자에게 요청한다.
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
