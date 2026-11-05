import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../database/life_os_database.dart';

enum BackupRestoreMode { merge, replace }

class BackupPreview {
  const BackupPreview({required this.counts, required this.duplicateIds});
  final Map<String, int> counts;
  final int duplicateIds;
  int get total => counts.values.fold<int>(0, (int a, int b) => a + b);
}

class LifeOsBackup {
  LifeOsBackup(this.database);
  final LifeOsDatabase database;

  static const int currentVersion = 1;
  static const List<String> _collections = <String>[
    'activities',
    'habits',
    'habitOccurrences',
    'goals',
    'budgets',
  ];

  Future<String> createJson() async =>
      const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
        'format': 'lifeos-backup',
        'version': currentVersion,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'data': await _readData(),
      });

  Future<Map<String, dynamic>> _readData() async => <String, dynamic>{
    'preferences': _preferencesJson(
      await database.select(database.appPreferences).getSingleOrNull(),
    ),
    'dashboardCards': (await database.select(database.dashboardCards).get())
        .map(_dashboardJson)
        .toList(),
    'activities': (await database.select(database.activityRecords).get())
        .map(_activityJson)
        .toList(),
    'habits': (await database.select(database.habits).get())
        .map(_habitJson)
        .toList(),
    'habitOccurrences': (await database.select(database.habitOccurrences).get())
        .map(_occurrenceJson)
        .toList(),
    'goals': (await database.select(database.goals).get())
        .map(_goalJson)
        .toList(),
    'budgets': (await database.select(database.budgets).get())
        .map(_budgetJson)
        .toList(),
    'deviceFeatures':
        (await (database.select(database.syncMetadata)..where(
                  (SyncMetadata t) => t.key.equals('local.device_features.v1'),
                ))
                .getSingleOrNull())
            ?.value,
  };

  Future<BackupPreview> preview(String json) async {
    final Map<String, dynamic> backup = _validate(json);
    final Map<String, dynamic> data = backup['data'] as Map<String, dynamic>;
    final Map<String, int> counts = <String, int>{
      for (final String key in _collections)
        key: (data[key] as List<dynamic>).length,
    };
    int duplicates = 0;
    for (final (String key, TableInfo<Table, dynamic> table) in _idTables()) {
      final Set<String> existing =
          (await database
                  .customSelect('SELECT id FROM ${table.actualTableName}')
                  .get())
              .map((QueryRow row) => row.read<String>('id'))
              .toSet();
      for (final dynamic raw in data[key] as List<dynamic>) {
        if (existing.contains((raw as Map<String, dynamic>)['id']))
          duplicates++;
      }
    }
    return BackupPreview(counts: counts, duplicateIds: duplicates);
  }

  Future<BackupPreview> restore(String json, BackupRestoreMode mode) async {
    final Map<String, dynamic> data =
        _validate(json)['data'] as Map<String, dynamic>;
    final BackupPreview summary = await preview(json);
    await database.transaction(() async {
      if (mode == BackupRestoreMode.replace) {
        final List<ActivityRecord> oldActivities = await database
            .select(database.activityRecords)
            .get();
        final List<Habit> oldHabits = await database
            .select(database.habits)
            .get();
        final List<HabitOccurrence> oldOccurrences = await database
            .select(database.habitOccurrences)
            .get();
        final List<Goal> oldGoals = await database.select(database.goals).get();
        final List<Budget> oldBudgets = await database
            .select(database.budgets)
            .get();
        await database.delete(database.habitOccurrences).go();
        await database.delete(database.habits).go();
        await database.delete(database.activityRecords).go();
        await database.delete(database.goals).go();
        await database.delete(database.budgets).go();
        for (final ActivityRecord row in oldActivities) {
          if (!(data['activities'] as List).any(
            (dynamic e) => e['id'] == row.id,
          ))
            await _queue('activity', row.id, 'delete', <String, dynamic>{
              'id': row.id,
              'kind': row.kind,
            });
        }
        for (final Habit row in oldHabits) {
          if (!(data['habits'] as List).any((dynamic e) => e['id'] == row.id))
            await _queue('habit', row.id, 'delete', <String, dynamic>{
              'id': row.id,
            });
        }
        for (final HabitOccurrence row in oldOccurrences) {
          if (!(data['habitOccurrences'] as List).any(
            (dynamic e) => e['id'] == row.id,
          ))
            await _queue('habitOccurrence', row.id, 'delete', <String, dynamic>{
              'id': row.id,
              'habitId': row.habitId,
            });
        }
        for (final Goal row in oldGoals) {
          if (!(data['goals'] as List).any((dynamic e) => e['id'] == row.id))
            await _queue('goal', row.id, 'delete', <String, dynamic>{
              'id': row.id,
            });
        }
        for (final Budget row in oldBudgets) {
          if (!(data['budgets'] as List).any((dynamic e) => e['id'] == row.id))
            await _queue('budget', row.id, 'delete', <String, dynamic>{
              'id': row.id,
            });
        }
      }
      final bool replace = mode == BackupRestoreMode.replace;
      await _importRows(
        'activities',
        data,
        replace,
        database.activityRecords,
        _activityFromJson,
        'activity',
      );
      await _importRows(
        'habits',
        data,
        replace,
        database.habits,
        _habitFromJson,
        'habit',
      );
      await _importRows(
        'habitOccurrences',
        data,
        replace,
        database.habitOccurrences,
        _occurrenceFromJson,
        'habitOccurrence',
      );
      await _importRows(
        'goals',
        data,
        replace,
        database.goals,
        _goalFromJson,
        'goal',
      );
      await _importRows(
        'budgets',
        data,
        replace,
        database.budgets,
        _budgetFromJson,
        'budget',
      );
      final Map<String, dynamic>? prefs =
          data['preferences'] as Map<String, dynamic>?;
      if (prefs != null &&
          (replace ||
              await database
                      .select(database.appPreferences)
                      .getSingleOrNull() ==
                  null)) {
        await database
            .into(database.appPreferences)
            .insertOnConflictUpdate(
              AppPreferencesCompanion.insert(
                id: const Value<int>(1),
                themeId: Value<String>(prefs['themeId'] as String),
                accentId: Value<String>(prefs['accentId'] as String),
                currencyCode: Value<String>(prefs['currencyCode'] as String),
                dateFormat: Value<String>(prefs['dateFormat'] as String),
                timeFormat: Value<String>(prefs['timeFormat'] as String),
                sidebarCollapsed: Value<bool>(
                  prefs['sidebarCollapsed'] as bool,
                ),
              ),
            );
      }
      final List<dynamic> cards = data['dashboardCards'] as List<dynamic>;
      if (replace) await database.delete(database.dashboardCards).go();
      for (final dynamic raw in cards) {
        final Map<String, dynamic> card = raw as Map<String, dynamic>;
        if (replace ||
            await (database.select(database.dashboardCards)..where(
                      (DashboardCards t) =>
                          t.cardId.equals(card['cardId'] as String),
                    ))
                    .getSingleOrNull() ==
                null) {
          await database
              .into(database.dashboardCards)
              .insertOnConflictUpdate(
                DashboardCardsCompanion.insert(
                  cardId: card['cardId'] as String,
                  position: card['position'] as int,
                  visible: Value<bool>(card['visible'] as bool),
                  desktopSpan: Value<int>(card['desktopSpan'] as int),
                ),
              );
        }
      }
      final String? deviceFeatures = data['deviceFeatures'] as String?;
      final SyncMetadataData? currentDeviceFeatures =
          await (database.select(database.syncMetadata)..where(
                (SyncMetadata t) => t.key.equals('local.device_features.v1'),
              ))
              .getSingleOrNull();
      if (deviceFeatures != null &&
          (replace || currentDeviceFeatures == null)) {
        await database
            .into(database.syncMetadata)
            .insertOnConflictUpdate(
              SyncMetadataCompanion.insert(
                key: 'local.device_features.v1',
                value: deviceFeatures,
              ),
            );
      }
    });
    return summary;
  }

  Future<void> _importRows<T extends DataClass>(
    String key,
    Map<String, dynamic> data,
    bool replace,
    TableInfo<Table, dynamic> table,
    dynamic Function(Map<String, dynamic>) decode,
    String entityType,
  ) async {
    for (final dynamic raw in data[key] as List<dynamic>) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(
        raw as Map<String, dynamic>,
      );
      final String id = json['id'] as String;
      final bool exists =
          (await database
                  .customSelect(
                    'SELECT id FROM ${table.actualTableName} WHERE id = ?',
                    variables: <Variable<Object>>[Variable<String>(id)],
                  )
                  .get())
              .isNotEmpty;
      if (!replace && exists) continue;
      final dynamic row = decode(json);
      await _put(table, row);
      await _queue(entityType, id, 'upsert', json);
    }
  }

  Future<void> _put(dynamic table, dynamic row) async {
    await database.into(table).insertOnConflictUpdate(row);
  }

  Future<void> _queue(
    String type,
    String id,
    String operation,
    Map<String, dynamic> payload,
  ) async {
    final String queueId = '$type:$id';
    final SyncPendingChange? prior = await (database.select(
      database.syncPendingChanges,
    )..where((SyncPendingChanges t) => t.id.equals(queueId))).getSingleOrNull();
    final SyncMetadataData? rev =
        await (database.select(database.syncMetadata)
              ..where((SyncMetadata t) => t.key.equals('revision:$queueId')))
            .getSingleOrNull();
    await database
        .into(database.syncPendingChanges)
        .insertOnConflictUpdate(
          SyncPendingChangesCompanion.insert(
            id: queueId,
            entityType: type,
            entityId: id,
            operation: operation,
            changeId: Value<String>(_id()),
            payloadJson: Value<String>(jsonEncode(payload)),
            baseRevision: Value<int?>(
              prior?.baseRevision ?? int.tryParse(rev?.value ?? ''),
            ),
            enqueuedAt: prior?.enqueuedAt ?? DateTime.now(),
          ),
        );
  }

  Map<String, dynamic> _validate(String raw) {
    try {
      return _validateDecoded(raw);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException(
        'The backup contains invalid or incomplete data.',
      );
    }
  }

  Map<String, dynamic> _validateDecoded(String raw) {
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const FormatException('This file is not valid JSON.');
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != 'lifeos-backup')
      throw const FormatException('This is not a PaTh backup.');
    if (decoded['version'] != currentVersion)
      throw FormatException(
        'Backup version ${decoded['version']} is not supported by this app.',
      );
    final dynamic data = decoded['data'];
    if (data is! Map<String, dynamic>)
      throw const FormatException('Backup data section is missing.');
    for (final String key in _collections) {
      final dynamic rows = data[key];
      if (rows is! List<dynamic>)
        throw FormatException('Backup section "$key" is missing or invalid.');
      final Set<String> ids = <String>{};
      for (final dynamic row in rows) {
        if (row is! Map<String, dynamic> ||
            row['id'] is! String ||
            (row['id'] as String).isEmpty)
          throw FormatException('A record in "$key" has no valid ID.');
        if (!ids.add(row['id'] as String))
          throw FormatException('Duplicate IDs were found in "$key".');
      }
    }
    _validateRows(data);
    final dynamic preferences = data['preferences'];
    if (preferences != null) {
      if (preferences is! Map<String, dynamic> ||
          preferences['themeId'] is! String ||
          preferences['accentId'] is! String ||
          preferences['currencyCode'] is! String ||
          preferences['dateFormat'] is! String ||
          preferences['timeFormat'] is! String ||
          preferences['sidebarCollapsed'] is! bool) {
        throw const FormatException('Backup preferences are invalid.');
      }
    }
    final dynamic cards = data['dashboardCards'];
    if (cards is! List<dynamic>) {
      throw const FormatException('Backup dashboard settings are invalid.');
    }
    final Set<String> cardIds = <String>{};
    for (final dynamic card in cards) {
      if (card is! Map<String, dynamic> ||
          card['cardId'] is! String ||
          card['position'] is! int ||
          card['visible'] is! bool ||
          card['desktopSpan'] is! int ||
          !cardIds.add(card['cardId'] as String)) {
        throw const FormatException('A dashboard card setting is invalid.');
      }
    }
    return decoded;
  }

  void _validateRows(Map<String, dynamic> data) {
    for (final dynamic r in data['activities'] as List) {
      final Map<String, dynamic> x = r;
      _date(x, 'recordDate');
      _date(x, 'createdAt');
      _date(x, 'updatedAt');
      if (x['kind'] is! String ||
          x['title'] is! String ||
          (x['value'] != null && x['value'] is! int))
        throw const FormatException('An activity record has invalid fields.');
      jsonDecode(x['metadataJson'] as String);
    }
    for (final dynamic r in data['habits'] as List) {
      final Map<String, dynamic> x = r;
      _date(x, 'startDate');
      _date(x, 'createdAt');
      if (x['name'] is! String)
        throw const FormatException('A habit has an invalid name.');
    }
    for (final dynamic r in data['habitOccurrences'] as List) {
      final Map<String, dynamic> x = r;
      _date(x, 'occurrenceDate');
      _date(x, 'updatedAt');
      if (x['habitId'] is! String || x['status'] is! String)
        throw const FormatException('A habit occurrence is invalid.');
    }
    for (final dynamic r in data['goals'] as List) {
      final Map<String, dynamic> x = r;
      _date(x, 'createdAt');
      _date(x, 'updatedAt');
      if (x['name'] is! String || x['progress'] is! int)
        throw const FormatException('A goal is invalid.');
      if (x['dueDate'] != null) DateTime.parse(x['dueDate'] as String);
    }
    for (final dynamic r in data['budgets'] as List) {
      final Map<String, dynamic> x = r;
      _date(x, 'createdAt');
      _date(x, 'updatedAt');
      if (x['category'] is! String || x['amountMinor'] is! int)
        throw const FormatException('A budget is invalid.');
    }
  }

  void _date(Map<String, dynamic> row, String key) {
    if (row[key] is! String)
      throw FormatException('A record has no valid $key.');
    DateTime.parse(row[key] as String);
  }

  String _id() => List<String>.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  Iterable<(String, TableInfo<Table, dynamic>)> _idTables() =>
      <(String, TableInfo<Table, dynamic>)>[
        ('activities', database.activityRecords),
        ('habits', database.habits),
        ('habitOccurrences', database.habitOccurrences),
        ('goals', database.goals),
        ('budgets', database.budgets),
      ];
  Map<String, dynamic> _preferencesJson(AppPreference? x) => <String, dynamic>{
    'themeId': x?.themeId ?? 'midnightRose',
    'accentId': x?.accentId ?? 'rose',
    'currencyCode': x?.currencyCode ?? 'INR',
    'dateFormat': x?.dateFormat ?? 'DD/MM/YYYY',
    'timeFormat': x?.timeFormat ?? '12-hour',
    'sidebarCollapsed': x?.sidebarCollapsed ?? false,
  };
  Map<String, dynamic> _dashboardJson(DashboardCardSetting x) =>
      <String, dynamic>{
        'cardId': x.cardId,
        'position': x.position,
        'visible': x.visible,
        'desktopSpan': x.desktopSpan,
      };
  Map<String, dynamic> _activityJson(ActivityRecord x) => <String, dynamic>{
    'id': x.id,
    'kind': x.kind,
    'recordDate': x.recordDate.toIso8601String(),
    'title': x.title,
    'value': x.value,
    'unit': x.unit,
    'status': x.status,
    'notes': x.notes,
    'metadataJson': x.metadataJson,
    'createdAt': x.createdAt.toIso8601String(),
    'updatedAt': x.updatedAt.toIso8601String(),
    'isDeleted': x.isDeleted,
  };
  Map<String, dynamic> _habitJson(Habit x) => <String, dynamic>{
    'id': x.id,
    'name': x.name,
    'description': x.description,
    'category': x.category,
    'trackingType': x.trackingType,
    'unit': x.unit,
    'scheduleDays': x.scheduleDays,
    'target': x.target,
    'isReduction': x.isReduction,
    'isArchived': x.isArchived,
    'startDate': x.startDate.toIso8601String(),
    'createdAt': x.createdAt.toIso8601String(),
  };
  Map<String, dynamic> _occurrenceJson(HabitOccurrence x) => <String, dynamic>{
    'id': x.id,
    'habitId': x.habitId,
    'occurrenceDate': x.occurrenceDate.toIso8601String(),
    'status': x.status,
    'numericValue': x.numericValue,
    'notes': x.notes,
    'updatedAt': x.updatedAt.toIso8601String(),
  };
  Map<String, dynamic> _goalJson(Goal x) => <String, dynamic>{
    'id': x.id,
    'name': x.name,
    'timeframe': x.timeframe,
    'target': x.target,
    'progress': x.progress,
    'unit': x.unit,
    'dueDate': x.dueDate?.toIso8601String(),
    'status': x.status,
    'notes': x.notes,
    'createdAt': x.createdAt.toIso8601String(),
    'updatedAt': x.updatedAt.toIso8601String(),
    'isDeleted': x.isDeleted,
  };
  Map<String, dynamic> _budgetJson(Budget x) => <String, dynamic>{
    'id': x.id,
    'category': x.category,
    'amountMinor': x.amountMinor,
    'period': x.period,
    'createdAt': x.createdAt.toIso8601String(),
    'updatedAt': x.updatedAt.toIso8601String(),
  };
  ActivityRecordsCompanion _activityFromJson(Map<String, dynamic> x) =>
      ActivityRecordsCompanion.insert(
        id: x['id'] as String,
        kind: x['kind'] as String,
        recordDate: DateTime.parse(x['recordDate'] as String),
        title: x['title'] as String,
        value: Value<int?>(x['value'] as int?),
        unit: Value<String?>(x['unit'] as String?),
        status: Value<String?>(x['status'] as String?),
        notes: Value<String>(x['notes'] as String),
        metadataJson: Value<String>(x['metadataJson'] as String),
        createdAt: DateTime.parse(x['createdAt'] as String),
        updatedAt: DateTime.parse(x['updatedAt'] as String),
        isDeleted: Value<bool>(x['isDeleted'] as bool),
      );
  HabitsCompanion _habitFromJson(Map<String, dynamic> x) =>
      HabitsCompanion.insert(
        id: x['id'] as String,
        name: x['name'] as String,
        description: Value<String>(x['description'] as String),
        category: Value<String>(x['category'] as String),
        trackingType: Value<String>(x['trackingType'] as String),
        unit: Value<String>(x['unit'] as String),
        scheduleDays: Value<String>(x['scheduleDays'] as String),
        target: Value<int?>(x['target'] as int?),
        isReduction: Value<bool>(x['isReduction'] as bool),
        isArchived: Value<bool>(x['isArchived'] as bool),
        startDate: DateTime.parse(x['startDate'] as String),
        createdAt: DateTime.parse(x['createdAt'] as String),
      );
  HabitOccurrencesCompanion _occurrenceFromJson(Map<String, dynamic> x) =>
      HabitOccurrencesCompanion.insert(
        id: x['id'] as String,
        habitId: x['habitId'] as String,
        occurrenceDate: DateTime.parse(x['occurrenceDate'] as String),
        status: x['status'] as String,
        numericValue: Value<int?>(x['numericValue'] as int?),
        notes: Value<String>(x['notes'] as String),
        updatedAt: DateTime.parse(x['updatedAt'] as String),
      );
  GoalsCompanion _goalFromJson(Map<String, dynamic> x) => GoalsCompanion.insert(
    id: x['id'] as String,
    name: x['name'] as String,
    timeframe: Value<String>(x['timeframe'] as String),
    target: Value<int?>(x['target'] as int?),
    progress: Value<int>(x['progress'] as int),
    unit: Value<String>(x['unit'] as String),
    dueDate: Value<DateTime?>(
      (x['dueDate'] as String?) == null
          ? null
          : DateTime.parse(x['dueDate'] as String),
    ),
    status: Value<String>(x['status'] as String),
    notes: Value<String>(x['notes'] as String),
    createdAt: DateTime.parse(x['createdAt'] as String),
    updatedAt: DateTime.parse(x['updatedAt'] as String),
    isDeleted: Value<bool>(x['isDeleted'] as bool),
  );
  BudgetsCompanion _budgetFromJson(Map<String, dynamic> x) =>
      BudgetsCompanion.insert(
        id: x['id'] as String,
        category: x['category'] as String,
        amountMinor: x['amountMinor'] as int,
        period: Value<String>(x['period'] as String),
        createdAt: DateTime.parse(x['createdAt'] as String),
        updatedAt: DateTime.parse(x['updatedAt'] as String),
      );
}

class LifeOsCsv {
  static String export(
    String dataset,
    List<Map<String, dynamic>> rows, {
    List<String>? headers,
    Map<String, String> columnLabels = const <String, String>{},
  }) {
    final List<String> columns =
        headers ?? (rows.isEmpty ? <String>[] : rows.first.keys.toList());
    String cell(Object? value) {
      String text = value?.toString() ?? '';
      if (RegExp(r'^[=+@\-]').hasMatch(text)) text = "'$text";
      return '"${text.replaceAll('"', '""')}"';
    }

    return <String>[
      if (columns.isNotEmpty)
        columns.map((String key) => cell(columnLabels[key] ?? key)).join(','),
      ...rows.map(
        (Map<String, dynamic> row) =>
            columns.map((String h) => cell(row[h])).join(','),
      ),
    ].join('\r\n');
  }
}
