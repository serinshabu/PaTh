import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:life_os/data/database/life_os_database.dart';
import 'package:life_os/data/settings/settings_repository.dart';

void main() {
  late LifeOsDatabase database;
  late SettingsRepository repository;

  setUp(() {
    database = LifeOsDatabase.forTesting(NativeDatabase.memory());
    repository = SettingsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('first launch seeds neutral preferences and dashboard cards', () async {
    await repository.ensureDefaults();

    final AppPreference preferences = await database
        .select(database.appPreferences)
        .getSingle();
    final List<DashboardCardSetting> cards = await database
        .select(database.dashboardCards)
        .get();

    expect(preferences.themeId, 'midnightRose');
    expect(preferences.accentId, 'rose');
    expect(preferences.currencyCode, 'INR');
    expect(preferences.dateFormat, 'DD/MM/YYYY');
    expect(preferences.timeFormat, '12-hour');
    expect(
      cards.map((DashboardCardSetting card) => card.cardId),
      SettingsRepository.defaultDashboardCards,
    );
    expect(cards.every((DashboardCardSetting card) => card.visible), isTrue);
    expect(
      cards.take(4).every((DashboardCardSetting card) => card.desktopSpan == 1),
      isTrue,
    );
    expect(
      cards.skip(4).every((DashboardCardSetting card) => card.desktopSpan == 2),
      isTrue,
    );
  });

  test('preferences survive closing and reopening a SQLite file', () async {
    final Directory temporaryDirectory = await Directory.systemTemp.createTemp(
      'life_os_settings_',
    );
    final File file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}life_os.sqlite',
    );
    final LifeOsDatabase firstDatabase = LifeOsDatabase.forTesting(
      NativeDatabase(file),
    );
    try {
      final SettingsRepository firstRepository = SettingsRepository(
        firstDatabase,
      );
      await firstRepository.ensureDefaults();
      await firstRepository.setTheme('softBlush');
      await firstRepository.setAccent('lavender');
    } finally {
      await firstDatabase.close();
    }

    final LifeOsDatabase reopenedDatabase = LifeOsDatabase.forTesting(
      NativeDatabase(file),
    );
    try {
      final AppPreference preferences = await reopenedDatabase
          .select(reopenedDatabase.appPreferences)
          .getSingle();
      expect(preferences.themeId, 'softBlush');
      expect(preferences.accentId, 'lavender');
    } finally {
      await reopenedDatabase.close();
      await temporaryDirectory.delete(recursive: true);
    }
  });
  test('settings updates persist in SQLite', () async {
    await repository.ensureDefaults();
    await repository.setTheme('softBlush');
    await repository.setAccent('lavender');
    await repository.setCurrency('USD');
    await repository.setDateFormat('MM/DD/YYYY');
    await repository.setTimeFormat('24-hour');

    final AppPreference preferences = await database
        .select(database.appPreferences)
        .getSingle();
    expect(preferences.themeId, 'softBlush');
    expect(preferences.accentId, 'lavender');
    expect(preferences.currencyCode, 'USD');
    expect(preferences.dateFormat, 'MM/DD/YYYY');
    expect(preferences.timeFormat, '24-hour');
  });

  test('device reminders and installation identity persist locally', () async {
    await repository.ensureDefaults();
    final String installationId = await repository.installationId();
    await repository.saveDeviceFeaturePreferences(
      const DeviceFeaturePreferences(
        habitEnabled: true,
        habitHour: 19,
        habitMinute: 15,
        quietHoursEnabled: true,
        quietStartHour: 23,
        quietEndHour: 6,
      ),
    );

    final DeviceFeaturePreferences reloaded = await repository
        .watchDeviceFeaturePreferences()
        .first;
    expect(reloaded.habitEnabled, isTrue);
    expect(reloaded.habitHour, 19);
    expect(reloaded.habitMinute, 15);
    expect(reloaded.quietHoursEnabled, isTrue);
    expect(reloaded.quietStartHour, 23);
    expect(reloaded.quietEndHour, 6);
    expect(await repository.installationId(), installationId);
    expect(installationId, hasLength(32));
  });

  test('dashboard visibility, span, and order changes persist', () async {
    await repository.ensureDefaults();
    await repository.setCardVisible('habits', false);
    await repository.setCardSpan('habits', 4);
    await repository.moveCard('habits', 1);

    final List<DashboardCardSetting> cards =
        await (database.select(database.dashboardCards)
              ..orderBy(<OrderClauseGenerator<DashboardCards>>[
                (DashboardCards table) => OrderingTerm.asc(table.position),
              ]))
            .get();
    final DashboardCardSetting habits = cards.singleWhere(
      (DashboardCardSetting card) => card.cardId == 'habits',
    );

    expect(habits.visible, isFalse);
    expect(habits.desktopSpan, 4);
    expect(cards.first.cardId, 'study');
    expect(habits.position, 1);
  });

  test('reset restores dashboard defaults without changing theme', () async {
    await repository.ensureDefaults();
    await repository.setTheme('lavenderDream');
    await repository.setCardVisible('habits', false);
    await repository.moveCard('habits', 2);
    await repository.resetDashboard();

    final AppPreference preferences = await database
        .select(database.appPreferences)
        .getSingle();
    final List<DashboardCardSetting> cards =
        await (database.select(database.dashboardCards)
              ..orderBy(<OrderClauseGenerator<DashboardCards>>[
                (DashboardCards table) => OrderingTerm.asc(table.position),
              ]))
            .get();
    expect(preferences.themeId, 'lavenderDream');
    expect(
      cards.map((DashboardCardSetting card) => card.cardId),
      SettingsRepository.defaultDashboardCards,
    );
    expect(cards.every((DashboardCardSetting card) => card.visible), isTrue);
  });
}
