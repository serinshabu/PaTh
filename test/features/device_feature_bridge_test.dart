import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:life_os/data/settings/settings_repository.dart';
import 'package:life_os/features/device/device_feature_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('DeviceFeaturePreferences', () {
    test('round-trips reminder times and quiet-hour settings', () {
      const DeviceFeaturePreferences original = DeviceFeaturePreferences(
        habitEnabled: true,
        habitHour: 7,
        habitMinute: 45,
        taskEnabled: true,
        taskHour: 17,
        taskMinute: 5,
        quietHoursEnabled: true,
        quietStartHour: 22,
        quietEndHour: 6,
      );

      final DeviceFeaturePreferences restored =
          DeviceFeaturePreferences.fromJson(original.toJson());
      expect(restored.toMap(), original.toMap());
    });

    test('rejects malformed time values by clamping them to valid ranges', () {
      final DeviceFeaturePreferences restored =
          DeviceFeaturePreferences.fromJson(
            '{"habitHour":99,"habitMinute":-3,"quietStartHour":-4}',
          );
      expect(restored.habitHour, 23);
      expect(restored.habitMinute, 0);
      expect(restored.quietStartHour, 0);
    });
  });

  group('ScreenTimeImportRules', () {
    test('handles overnight quiet hours', () {
      expect(
        ScreenTimeImportRules.isQuietHour(hour: 23, start: 22, end: 7),
        isTrue,
      );
      expect(
        ScreenTimeImportRules.isQuietHour(hour: 6, start: 22, end: 7),
        isTrue,
      );
      expect(
        ScreenTimeImportRules.isQuietHour(hour: 12, start: 22, end: 7),
        isFalse,
      );
    });

    test('handles a daytime quiet interval and all-day interval', () {
      expect(
        ScreenTimeImportRules.isQuietHour(hour: 13, start: 12, end: 15),
        isTrue,
      );
      expect(
        ScreenTimeImportRules.isQuietHour(hour: 11, start: 12, end: 15),
        isFalse,
      );
      expect(
        ScreenTimeImportRules.isQuietHour(hour: 11, start: 0, end: 0),
        isTrue,
      );
    });

    test('floors usage milliseconds to whole minutes without rounding up', () {
      expect(ScreenTimeImportRules.roundedMinutes(125999), 2);
      expect(ScreenTimeImportRules.roundedMinutes(59999), 0);
      expect(
        () => ScreenTimeImportRules.roundedMinutes(-1),
        throwsArgumentError,
      );
    });
  });

  test('notification permission denial is returned to the caller', () async {
    const MethodChannel channel = MethodChannel('lifeos/device_features');
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          if (call.method == 'requestNotificationPermission') return false;
          return null;
        });
    try {
      expect(
        await const DeviceFeatureBridge().requestNotificationPermission(),
        isFalse,
      );
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
