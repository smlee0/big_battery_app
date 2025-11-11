import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    BigBatteryApp(
      notificationService: notificationService,
      sharedPreferences: sharedPreferences,
    ),
  );
}
