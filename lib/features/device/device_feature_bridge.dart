import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../data/settings/settings_repository.dart';

const MethodChannel _deviceChannel = MethodChannel('lifeos/device_features');

class DeviceFeatureBridge {
  const DeviceFeatureBridge();

  bool get supportsAndroidUsageImport =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get supportsAndroidNotifications =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> hasUsageAccess() async {
    if (!supportsAndroidUsageImport) return false;
    return await _deviceChannel.invokeMethod<bool>('hasUsageAccess') ?? false;
  }

  Future<void> requestUsageAccess() async {
    if (!supportsAndroidUsageImport) return;
    await _deviceChannel.invokeMethod<void>('requestUsageAccess');
  }

  Future<int> todayUsageMinutes() async {
    if (!supportsAndroidUsageImport) {
      throw UnsupportedError('Usage import is available on Android only.');
    }
    final int milliseconds =
        await _deviceChannel.invokeMethod<int>('todayUsageMilliseconds') ?? 0;
    return ScreenTimeImportRules.roundedMinutes(milliseconds);
  }

  Future<bool> notificationsEnabled() async {
    if (!supportsAndroidNotifications) return false;
    return await _deviceChannel.invokeMethod<bool>('notificationsEnabled') ??
        false;
  }

  Future<bool> requestNotificationPermission() async {
    if (!supportsAndroidNotifications) return false;
    return await _deviceChannel.invokeMethod<bool>(
          'requestNotificationPermission',
        ) ??
        false;
  }

  Future<void> configureReminders(DeviceFeaturePreferences preferences) async {
    if (!supportsAndroidNotifications) return;
    await _deviceChannel.invokeMethod<void>(
      'configureReminders',
      preferences.toMap(),
    );
  }
}

abstract final class ScreenTimeImportRules {
  static bool isQuietHour({
    required int hour,
    required int start,
    required int end,
  }) {
    if (start == end) return true;
    if (start < end) return hour >= start && hour < end;
    return hour >= start || hour < end;
  }

  static int roundedMinutes(int milliseconds) {
    if (milliseconds < 0) throw ArgumentError.value(milliseconds);
    return milliseconds ~/ Duration.millisecondsPerMinute;
  }
}
