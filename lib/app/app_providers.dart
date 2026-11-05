import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/life_os_database.dart';
import '../data/settings/settings_repository.dart';
import '../data/records/records_repository.dart';
import '../features/device/reminder_runtime.dart';

final Provider<LifeOsDatabase> lifeOsDatabaseProvider =
    Provider<LifeOsDatabase>((Ref ref) {
      final LifeOsDatabase database = LifeOsDatabase();
      ref.onDispose(database.close);
      return database;
    });

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
      (Ref ref) => SettingsRepository(ref.watch(lifeOsDatabaseProvider)),
    );

final Provider<RecordsRepository> recordsRepositoryProvider =
    Provider<RecordsRepository>(
      (Ref ref) => RecordsRepository(ref.watch(lifeOsDatabaseProvider)),
    );

final Provider<ReminderRuntime> reminderRuntimeProvider =
    Provider<ReminderRuntime>((Ref ref) {
      final ReminderRuntime runtime = ReminderRuntime();
      ref.onDispose(runtime.dispose);
      return runtime;
    });

final activityRecordsProvider =
    StreamProvider.family<List<ActivityRecord>, String>(
      (Ref ref, String kind) =>
          ref.watch(recordsRepositoryProvider).watch(kind),
    );

final StreamProvider<List<Habit>> activeHabitsProvider =
    StreamProvider<List<Habit>>(
      (Ref ref) => ref.watch(recordsRepositoryProvider).watchHabits(),
    );

final todayHabitOccurrencesProvider =
    StreamProvider.family<List<HabitOccurrence>, DateTime>(
      (Ref ref, DateTime day) =>
          ref.watch(recordsRepositoryProvider).watchTodayOccurrences(day),
    );

final StreamProvider<AppPreference> preferencesProvider =
    StreamProvider<AppPreference>(
      (Ref ref) => ref.watch(settingsRepositoryProvider).watchPreferences(),
    );

final StreamProvider<DeviceFeaturePreferences>
deviceFeaturePreferencesProvider = StreamProvider<DeviceFeaturePreferences>(
  (Ref ref) =>
      ref.watch(settingsRepositoryProvider).watchDeviceFeaturePreferences(),
);

final StreamProvider<List<DashboardCardSetting>> dashboardCardsProvider =
    StreamProvider<List<DashboardCardSetting>>(
      (Ref ref) => ref.watch(settingsRepositoryProvider).watchDashboardCards(),
    );
