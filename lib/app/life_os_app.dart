import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/life_os_database.dart';
import '../data/sync/sync_runtime.dart';
import '../data/settings/settings_repository.dart';
import '../features/device/reminder_runtime.dart';
import 'app_providers.dart';
import 'navigation/life_os_router.dart';
import 'theme/life_os_palette.dart';

class LifeOsApp extends ConsumerWidget {
  const LifeOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncRunnerProvider);
    final ReminderRuntime reminderRuntime = ref.watch(reminderRuntimeProvider);
    ref.listen(deviceFeaturePreferencesProvider, (previous, next) {
      next.whenData(reminderRuntime.update);
    });
    final DeviceFeaturePreferences? deviceFeatures = ref
        .read(deviceFeaturePreferencesProvider)
        .value;
    if (deviceFeatures != null) reminderRuntime.update(deviceFeatures);
    final AppPreference? preferences = ref.watch(preferencesProvider).value;
    final LifeOsPalette palette = LifeOsPalette.fromId(
      preferences?.themeId ?? LifeOsPalette.midnightRose.id,
    );
    return MaterialApp.router(
      title: 'PaTh',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: reminderRuntime.messengerKey,
      theme: palette.toTheme(accentId: preferences?.accentId ?? 'rose'),
      routerConfig: ref.watch(lifeOsRouterProvider),
    );
  }
}
