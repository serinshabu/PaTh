import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../database/life_os_database.dart';

class SettingsRepository {
  SettingsRepository(this._database);

  final LifeOsDatabase _database;

  static const List<String> defaultDashboardCards = <String>[
    'habits',
    'study',
    'tasks',
    'mood',
    'schedule',
    'wellness',
    'gym-study',
    'money',
    'screen-time',
    'journal',
    'calendar',
  ];

  static const Set<String> _wideDashboardCards = <String>{
    'schedule',
    'wellness',
    'gym-study',
    'money',
    'screen-time',
    'journal',
    'calendar',
  };

  static const String _deviceSettingsKey = 'local.device_features.v1';
  static const String _installationIdKey = 'local.installation_id.v1';

  Stream<DeviceFeaturePreferences> watchDeviceFeaturePreferences() =>
      (_database.select(_database.syncMetadata)
            ..where((SyncMetadata row) => row.key.equals(_deviceSettingsKey)))
          .watchSingle()
          .map(
            (SyncMetadataData row) =>
                DeviceFeaturePreferences.fromJson(row.value),
          );

  Stream<AppPreference> watchPreferences() =>
      _database.select(_database.appPreferences).watchSingle();

  Stream<List<DashboardCardSetting>> watchDashboardCards() =>
      (_database.select(_database.dashboardCards)
            ..orderBy(<OrderClauseGenerator<DashboardCards>>[
              (DashboardCards table) => OrderingTerm.asc(table.position),
            ]))
          .watch();

  Future<void> ensureDefaults() async {
    await _database.transaction(() async {
      final AppPreference? preferences = await (_database.select(
        _database.appPreferences,
      )..where((AppPreferences table) => table.id.equals(1))).getSingleOrNull();
      if (preferences == null) {
        await _database
            .into(_database.appPreferences)
            .insert(const AppPreferencesCompanion(id: Value<int>(1)));
      }

      final SyncMetadataData? deviceSettings =
          await (_database.select(_database.syncMetadata)..where(
                (SyncMetadata row) => row.key.equals(_deviceSettingsKey),
              ))
              .getSingleOrNull();
      if (deviceSettings == null) {
        await _database
            .into(_database.syncMetadata)
            .insert(
              SyncMetadataCompanion.insert(
                key: _deviceSettingsKey,
                value: const DeviceFeaturePreferences().toJson(),
              ),
            );
      }
      final SyncMetadataData? installationId =
          await (_database.select(_database.syncMetadata)..where(
                (SyncMetadata row) => row.key.equals(_installationIdKey),
              ))
              .getSingleOrNull();
      if (installationId == null) {
        final Random random = Random.secure();
        final String id = List<String>.generate(
          16,
          (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
        ).join();
        await _database
            .into(_database.syncMetadata)
            .insert(
              SyncMetadataCompanion.insert(key: _installationIdKey, value: id),
            );
      }

      final List<DashboardCardSetting> existing = await _database
          .select(_database.dashboardCards)
          .get();
      final Set<String> known = existing
          .map((DashboardCardSetting row) => row.cardId)
          .toSet();
      int nextPosition = existing.fold<int>(
        0,
        (int current, DashboardCardSetting row) =>
            row.position >= current ? row.position + 1 : current,
      );
      for (final String cardId in defaultDashboardCards) {
        if (!known.contains(cardId)) {
          await _database
              .into(_database.dashboardCards)
              .insert(
                DashboardCardsCompanion.insert(
                  cardId: cardId,
                  position: nextPosition,
                  desktopSpan: Value<int>(_defaultSpan(cardId)),
                ),
              );
          nextPosition++;
        }
      }
    });
  }

  Future<void> saveDeviceFeaturePreferences(
    DeviceFeaturePreferences preferences,
  ) => _database
      .into(_database.syncMetadata)
      .insertOnConflictUpdate(
        SyncMetadataCompanion.insert(
          key: _deviceSettingsKey,
          value: preferences.toJson(),
        ),
      );

  Future<String> installationId() async =>
      (await (_database.select(_database.syncMetadata)..where(
                (SyncMetadata row) => row.key.equals(_installationIdKey),
              ))
              .getSingle())
          .value;

  Future<void> setTheme(String themeId) => _savePreferences(
    AppPreferencesCompanion(
      id: const Value<int>(1),
      themeId: Value<String>(themeId),
    ),
  );

  Future<void> setAccent(String accentId) => _savePreferences(
    AppPreferencesCompanion(
      id: const Value<int>(1),
      accentId: Value<String>(accentId),
    ),
  );

  Future<void> setCurrency(String currencyCode) => _savePreferences(
    AppPreferencesCompanion(
      id: const Value<int>(1),
      currencyCode: Value<String>(currencyCode),
    ),
  );

  Future<void> setDateFormat(String dateFormat) => _savePreferences(
    AppPreferencesCompanion(
      id: const Value<int>(1),
      dateFormat: Value<String>(dateFormat),
    ),
  );

  Future<void> setTimeFormat(String timeFormat) => _savePreferences(
    AppPreferencesCompanion(
      id: const Value<int>(1),
      timeFormat: Value<String>(timeFormat),
    ),
  );

  Future<void> setSidebarCollapsed(bool collapsed) => _savePreferences(
    AppPreferencesCompanion(
      id: const Value<int>(1),
      sidebarCollapsed: Value<bool>(collapsed),
    ),
  );

  Future<void> _savePreferences(AppPreferencesCompanion changes) async {
    final int updated = await (_database.update(
      _database.appPreferences,
    )..where((AppPreferences table) => table.id.equals(1))).write(changes);
    if (updated != 1) {
      throw StateError('Settings have not been initialized.');
    }
  }

  Future<void> setCardVisible(String cardId, bool visible) async {
    await (_database.update(_database.dashboardCards)
          ..where((DashboardCards table) => table.cardId.equals(cardId)))
        .write(DashboardCardsCompanion(visible: Value<bool>(visible)));
  }

  Future<void> setCardSpan(String cardId, int span) async {
    await (_database.update(
      _database.dashboardCards,
    )..where((DashboardCards table) => table.cardId.equals(cardId))).write(
      DashboardCardsCompanion(
        desktopSpan: Value<int>(span.clamp(1, 4).toInt()),
      ),
    );
  }

  Future<void> moveCard(String cardId, int offset) async {
    await _database.transaction(() async {
      final List<DashboardCardSetting> rows =
          await (_database.select(_database.dashboardCards)
                ..orderBy(<OrderClauseGenerator<DashboardCards>>[
                  (DashboardCards table) => OrderingTerm.asc(table.position),
                ]))
              .get();
      final int current = rows.indexWhere(
        (DashboardCardSetting row) => row.cardId == cardId,
      );
      final int target = current + offset;
      if (current < 0 || target < 0 || target >= rows.length) {
        return;
      }
      final DashboardCardSetting first = rows[current];
      final DashboardCardSetting second = rows[target];
      await (_database.update(
            _database.dashboardCards,
          )..where((DashboardCards table) => table.cardId.equals(first.cardId)))
          .write(
            DashboardCardsCompanion(position: Value<int>(second.position)),
          );
      await (_database.update(_database.dashboardCards)..where(
            (DashboardCards table) => table.cardId.equals(second.cardId),
          ))
          .write(DashboardCardsCompanion(position: Value<int>(first.position)));
    });
  }

  Future<void> resetDashboard() async {
    await _database.transaction(() async {
      await _database.delete(_database.dashboardCards).go();
      for (int index = 0; index < defaultDashboardCards.length; index++) {
        await _database
            .into(_database.dashboardCards)
            .insert(
              DashboardCardsCompanion.insert(
                cardId: defaultDashboardCards[index],
                position: index,
                desktopSpan: Value<int>(
                  _defaultSpan(defaultDashboardCards[index]),
                ),
              ),
            );
      }
    });
  }

  int _defaultSpan(String cardId) =>
      _wideDashboardCards.contains(cardId) ? 2 : 1;
}

/// On-device settings. Stored in local sync metadata but excluded from the
/// sync protocol, since reminders and permissions are specific to each device.
class DeviceFeaturePreferences {
  const DeviceFeaturePreferences({
    this.habitEnabled = false,
    this.habitHour = 20,
    this.habitMinute = 0,
    this.taskEnabled = false,
    this.taskHour = 18,
    this.taskMinute = 0,
    this.reviewEnabled = false,
    this.reviewHour = 20,
    this.reviewMinute = 30,
    this.planningEnabled = false,
    this.planningHour = 8,
    this.planningMinute = 0,
    this.quietHoursEnabled = false,
    this.quietStartHour = 22,
    this.quietEndHour = 7,
  });

  final bool habitEnabled;
  final int habitHour;
  final int habitMinute;
  final bool taskEnabled;
  final int taskHour;
  final int taskMinute;
  final bool reviewEnabled;
  final int reviewHour;
  final int reviewMinute;
  final bool planningEnabled;
  final int planningHour;
  final int planningMinute;
  final bool quietHoursEnabled;
  final int quietStartHour;
  final int quietEndHour;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'habitEnabled': habitEnabled,
    'habitHour': habitHour,
    'habitMinute': habitMinute,
    'taskEnabled': taskEnabled,
    'taskHour': taskHour,
    'taskMinute': taskMinute,
    'reviewEnabled': reviewEnabled,
    'reviewHour': reviewHour,
    'reviewMinute': reviewMinute,
    'planningEnabled': planningEnabled,
    'planningHour': planningHour,
    'planningMinute': planningMinute,
    'quietHoursEnabled': quietHoursEnabled,
    'quietStartHour': quietStartHour,
    'quietEndHour': quietEndHour,
  };

  String toJson() => jsonEncode(toMap());

  factory DeviceFeaturePreferences.fromJson(String value) {
    final Map<String, dynamic> json = jsonDecode(value) as Map<String, dynamic>;
    const DeviceFeaturePreferences defaults = DeviceFeaturePreferences();
    int readInt(String key, int fallback) {
      final int result = json[key] as int? ?? fallback;
      return result.clamp(0, 59);
    }

    int readHour(String key, int fallback) {
      final int result = json[key] as int? ?? fallback;
      return result.clamp(0, 23);
    }

    return DeviceFeaturePreferences(
      habitEnabled: json['habitEnabled'] as bool? ?? defaults.habitEnabled,
      habitHour: readHour('habitHour', defaults.habitHour),
      habitMinute: readInt('habitMinute', defaults.habitMinute),
      taskEnabled: json['taskEnabled'] as bool? ?? defaults.taskEnabled,
      taskHour: readHour('taskHour', defaults.taskHour),
      taskMinute: readInt('taskMinute', defaults.taskMinute),
      reviewEnabled: json['reviewEnabled'] as bool? ?? defaults.reviewEnabled,
      reviewHour: readHour('reviewHour', defaults.reviewHour),
      reviewMinute: readInt('reviewMinute', defaults.reviewMinute),
      planningEnabled:
          json['planningEnabled'] as bool? ?? defaults.planningEnabled,
      planningHour: readHour('planningHour', defaults.planningHour),
      planningMinute: readInt('planningMinute', defaults.planningMinute),
      quietHoursEnabled:
          json['quietHoursEnabled'] as bool? ?? defaults.quietHoursEnabled,
      quietStartHour: readHour('quietStartHour', defaults.quietStartHour),
      quietEndHour: readHour('quietEndHour', defaults.quietEndHour),
    );
  }

  DeviceFeaturePreferences copyWith({
    bool? habitEnabled,
    int? habitHour,
    int? habitMinute,
    bool? taskEnabled,
    int? taskHour,
    int? taskMinute,
    bool? reviewEnabled,
    int? reviewHour,
    int? reviewMinute,
    bool? planningEnabled,
    int? planningHour,
    int? planningMinute,
    bool? quietHoursEnabled,
    int? quietStartHour,
    int? quietEndHour,
  }) => DeviceFeaturePreferences(
    habitEnabled: habitEnabled ?? this.habitEnabled,
    habitHour: habitHour ?? this.habitHour,
    habitMinute: habitMinute ?? this.habitMinute,
    taskEnabled: taskEnabled ?? this.taskEnabled,
    taskHour: taskHour ?? this.taskHour,
    taskMinute: taskMinute ?? this.taskMinute,
    reviewEnabled: reviewEnabled ?? this.reviewEnabled,
    reviewHour: reviewHour ?? this.reviewHour,
    reviewMinute: reviewMinute ?? this.reviewMinute,
    planningEnabled: planningEnabled ?? this.planningEnabled,
    planningHour: planningHour ?? this.planningHour,
    planningMinute: planningMinute ?? this.planningMinute,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    quietStartHour: quietStartHour ?? this.quietStartHour,
    quietEndHour: quietEndHour ?? this.quietEndHour,
  );
}
