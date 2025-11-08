import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/battery_provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/battery_service.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';

class BigBatteryWidgetApp extends StatelessWidget {
  const BigBatteryWidgetApp({
    super.key,
    required this.notificationService,
    required this.sharedPreferences,
  });

  final NotificationService notificationService;
  final SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BatteryProvider(
        batteryService: BatteryService(),
        notificationService: notificationService,
        preferences: sharedPreferences,
      )..initialize(),
      child: Consumer<BatteryProvider>(
        builder: (context, provider, child) {
          final settings = provider.settings;
          return MaterialApp(
            title: 'Big Battery',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(highContrast: settings.highContrast),
            darkTheme: AppTheme.dark(highContrast: settings.highContrast),
            themeMode: settings.themeMode,
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: TextScaler.linear(settings.textScaleFactor),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const BatteryWidgetScreen(),
            routes: {
              SettingsScreen.routeName: (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
