import 'dart:async';
import 'dart:io' show Platform;

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/battery_service.dart';
import '../services/notification_service.dart';

enum BatteryTextSize { large, extraLarge }

extension BatteryTextSizeX on BatteryTextSize {
  double get scaleFactor => switch (this) {
        BatteryTextSize.large => 1.15,
        BatteryTextSize.extraLarge => 1.3,
      };

  String get label => switch (this) {
        BatteryTextSize.large => '크게',
        BatteryTextSize.extraLarge => '아주 크게',
      };
}

class BatterySettings {
  const BatterySettings({
    this.textSize = BatteryTextSize.extraLarge,
    this.themeMode = ThemeMode.light,
    this.notificationsEnabled = true,
  });

  final BatteryTextSize textSize;
  final ThemeMode themeMode;
  final bool notificationsEnabled;

  static const _textSizeKey = 'battery_text_size';
  static const _themeModeKey = 'battery_theme_mode';
  static const _notificationKey = 'battery_notifications';

  double get textScaleFactor => textSize.scaleFactor;

  BatterySettings copyWith({
    BatteryTextSize? textSize,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
  }) {
    return BatterySettings(
      textSize: textSize ?? this.textSize,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  BatterySettings mergePreferences(SharedPreferences prefs) {
    final textValue = prefs.getString(_textSizeKey);
    final themeValue = prefs.getString(_themeModeKey);
    return copyWith(
      textSize: textValue != null
          ? BatteryTextSize.values.firstWhere(
              (value) => value.name == textValue,
              orElse: () => textSize,
            )
          : textSize,
      themeMode: themeValue != null
          ? ThemeMode.values.firstWhere(
              (value) => value.name == themeValue,
              orElse: () => themeMode,
            )
          : themeMode,
      notificationsEnabled:
          prefs.getBool(_notificationKey) ?? notificationsEnabled,
    );
  }

  Future<void> persist(SharedPreferences prefs) async {
    await prefs.setString(_textSizeKey, textSize.name);
    await prefs.setString(_themeModeKey, themeMode.name);
    await prefs.setBool(_notificationKey, notificationsEnabled);
  }
}

class BatteryStatus {
  const BatteryStatus({
    required this.level,
    required this.state,
    this.lastUpdated,
    this.errorMessage,
  });

  final int level;
  final BatteryState state;
  final DateTime? lastUpdated;
  final String? errorMessage;

  bool get isCharging => state == BatteryState.charging;
  bool get isLow => level <= 20;

  BatteryStatus copyWith({
    int? level,
    BatteryState? state,
    DateTime? lastUpdated,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BatteryStatus(
      level: level ?? this.level,
      state: state ?? this.state,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BatteryProvider extends ChangeNotifier {
  BatteryProvider({
    required this.batteryService,
    required this.notificationService,
    required this.preferences,
  })  : _status = const BatteryStatus(
          level: 0,
          state: BatteryState.unknown,
        ),
        _settings = const BatterySettings();

  final BatteryService batteryService;
  final NotificationService notificationService;
  final SharedPreferences preferences;

  BatteryStatus _status;
  BatterySettings _settings;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  StreamSubscription<BatterySnapshotUpdate>? _batterySnapshotSubscription;
  bool _initialized = false;
  bool _lowBatteryAlertActive = false;

  BatteryStatus get status => _status;
  BatterySettings get settings => _settings;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _settings = _settings.mergePreferences(preferences);
    await refreshBatteryStatus();
    final hasNativeStream = _listenBatterySnapshots();
    if (!hasNativeStream) {
      _listenBatteryState();
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> refreshBatteryStatus() async {
    try {
      final level = await batteryService.getBatteryLevel();
      final fetchedState = await batteryService.getBatteryState();
      final state = fetchedState == BatteryState.unknown
          ? (_status.state != BatteryState.unknown
              ? _status.state
              : BatteryState.discharging)
          : fetchedState;
      _updateStatus(
        _status.copyWith(
          level: level,
          state: state,
          lastUpdated: DateTime.now(),
          clearError: true,
        ),
      );
    } catch (error) {
      _updateStatus(
        _status.copyWith(
          errorMessage: error.toString(),
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  void updateTextSize(BatteryTextSize size) {
    _updateSettings(_settings.copyWith(textSize: size));
  }

  void updateThemeMode(ThemeMode mode) {
    _updateSettings(_settings.copyWith(themeMode: mode));
  }

  void toggleNotifications(bool value) {
    _updateSettings(_settings.copyWith(notificationsEnabled: value));
  }

  void _updateStatus(BatteryStatus status) {
    _status = status;
    _maybeShowLowBatteryAlert(status);
    notifyListeners();
  }

  void _updateSettings(BatterySettings next) {
    _settings = next;
    unawaited(_settings.persist(preferences));
    notifyListeners();
  }

  void _listenBatteryState() {
    try {
      _batteryStateSubscription?.cancel();
      _batteryStateSubscription = batteryService.onBatteryStateChanged.listen(
        (state) {
          _updateStatus(
            _status.copyWith(
              state: state,
              lastUpdated: DateTime.now(),
              clearError: state != BatteryState.unknown,
            ),
          );
        },
      );
    } on MissingPluginException {
      // ignore: avoid_print
      debugPrint('Battery state stream is not available on this platform.');
    }
  }

  bool _listenBatterySnapshots() {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      _batterySnapshotSubscription?.cancel();
      _batterySnapshotSubscription =
          batteryService.watchBatterySnapshots().listen((snapshot) {
        _updateStatus(
          _status.copyWith(
            level: snapshot.level,
            state: snapshot.derivedState,
            lastUpdated: snapshot.updatedAt,
            clearError: true,
          ),
        );
      });
      return true;
    } on MissingPluginException {
      // ignore if the native channel is not available
      return false;
    }
  }

  void _maybeShowLowBatteryAlert(BatteryStatus status) {
    if (!_settings.notificationsEnabled) {
      _lowBatteryAlertActive = false;
      return;
    }
    final shouldAlert = status.isLow && !status.isCharging;
    if (shouldAlert && !_lowBatteryAlertActive) {
      _lowBatteryAlertActive = true;
      unawaited(
        notificationService.showLowBatteryAlert(
          batteryLevel: status.level,
          isCharging: status.isCharging,
        ),
      );
    } else if (!shouldAlert && _lowBatteryAlertActive) {
      _lowBatteryAlertActive = false;
    }
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    _batterySnapshotSubscription?.cancel();
    super.dispose();
  }
}
