import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/settings/settings_repository.dart';
import 'device_feature_bridge.dart';

class ReminderRuntime {
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final DeviceFeatureBridge _bridge = const DeviceFeatureBridge();
  final Set<String> _shownToday = <String>{};
  Timer? _timer;
  String? _lastAndroidConfiguration;
  DeviceFeaturePreferences _preferences = const DeviceFeaturePreferences();

  void update(DeviceFeaturePreferences preferences) {
    _preferences = preferences;
    if (_bridge.supportsAndroidNotifications) {
      final String configuration = preferences.toJson();
      if (_lastAndroidConfiguration != configuration) {
        _lastAndroidConfiguration = configuration;
        unawaited(
          _bridge.configureReminders(preferences).catchError((Object _) {}),
        );
      }
      return;
    }
    _timer ??= Timer.periodic(const Duration(seconds: 15), (_) => _check());
    _check();
  }

  void _check() {
    final DateTime now = DateTime.now();
    if (_preferences.quietHoursEnabled &&
        ScreenTimeImportRules.isQuietHour(
          hour: now.hour,
          start: _preferences.quietStartHour,
          end: _preferences.quietEndHour,
        )) {
      return;
    }
    final List<(bool, int, int, String)> reminders = <(bool, int, int, String)>[
      (
        _preferences.habitEnabled,
        _preferences.habitHour,
        _preferences.habitMinute,
        'A moment for your habits',
      ),
      (
        _preferences.taskEnabled,
        _preferences.taskHour,
        _preferences.taskMinute,
        'Check in with your tasks',
      ),
      (
        _preferences.reviewEnabled,
        _preferences.reviewHour,
        _preferences.reviewMinute,
        'Your optional evening review is here',
      ),
      (
        _preferences.planningEnabled,
        _preferences.planningHour,
        _preferences.planningMinute,
        'A gentle moment to plan your day',
      ),
    ];
    for (int index = 0; index < reminders.length; index++) {
      final (bool enabled, int hour, int minute, String message) =
          reminders[index];
      if (!enabled || now.hour != hour || now.minute != minute) continue;
      final String key = '${now.year}-${now.month}-${now.day}-$index';
      if (!_shownToday.add(key)) continue;
      messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void dispose() => _timer?.cancel();
}
