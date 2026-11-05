import 'dart:math';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/life_os_database.dart';

class RecordsRepository {
  RecordsRepository(this._db);
  final LifeOsDatabase _db;

  Stream<List<ActivityRecord>> watch(String kind) =>
      (_db.select(_db.activityRecords)
            ..where(
              (ActivityRecords t) =>
                  t.kind.equals(kind) & t.isDeleted.equals(false),
            )
            ..orderBy(<OrderClauseGenerator<ActivityRecords>>[
              (ActivityRecords t) => OrderingTerm.desc(t.recordDate),
              (ActivityRecords t) => OrderingTerm.desc(t.updatedAt),
            ]))
          .watch();

  Stream<List<ActivityRecord>> watchCalendarRecords(
    DateTime start,
    DateTime endExclusive,
  ) =>
      (_db.select(_db.activityRecords)
            ..where(
              (ActivityRecords t) =>
                  t.isDeleted.equals(false) &
                  t.recordDate.isBiggerOrEqualValue(start) &
                  t.recordDate.isSmallerThanValue(endExclusive),
            )
            ..orderBy(<OrderClauseGenerator<ActivityRecords>>[
              (ActivityRecords t) => OrderingTerm.asc(t.recordDate),
              (ActivityRecords t) => OrderingTerm.asc(t.createdAt),
            ]))
          .watch();

  Stream<List<HabitOccurrence>> watchHabitOccurrencesBetween(
    DateTime start,
    DateTime endExclusive,
  ) =>
      (_db.select(_db.habitOccurrences)
            ..where(
              (HabitOccurrences t) =>
                  t.occurrenceDate.isBiggerOrEqualValue(start) &
                  t.occurrenceDate.isSmallerThanValue(endExclusive),
            )
            ..orderBy(<OrderClauseGenerator<HabitOccurrences>>[
              (HabitOccurrences t) => OrderingTerm.asc(t.occurrenceDate),
            ]))
          .watch();

  Stream<List<HabitOccurrence>> watchRecentHabitOccurrences({int limit = 7}) =>
      (_db.select(_db.habitOccurrences)
            ..orderBy(<OrderClauseGenerator<HabitOccurrences>>[
              (HabitOccurrences table) =>
                  OrderingTerm.desc(table.occurrenceDate),
              (HabitOccurrences table) => OrderingTerm.desc(table.updatedAt),
            ])
            ..limit(limit.clamp(1, 30)))
          .watch();

  Future<void> save({
    required String kind,
    required String title,
    required DateTime date,
    int? value,
    String? unit,
    String? status,
    String notes = '',
    String metadataJson = '{}',
    String? id,
  }) async {
    final DateTime now = DateTime.now();
    final String recordId = id ?? _id();
    final ActivityRecord? existing = id == null
        ? null
        : await (_db.select(
            _db.activityRecords,
          )..where((ActivityRecords t) => t.id.equals(id))).getSingleOrNull();
    String savedMetadata = metadataJson;
    if (kind == 'tasks' &&
        existing != null &&
        (existing.status != status ||
            !_sameLocalDay(existing.recordDate, date))) {
      final Map<String, dynamic> next = _decodeMetadata(metadataJson);
      final Map<String, dynamic> previous = _decodeMetadata(
        existing.metadataJson,
      );
      final List<dynamic> history = List<dynamic>.from(
        previous['history'] as List<dynamic>? ?? <dynamic>[],
      );
      history.add(<String, String?>{
        'changedAt': DateTime.now().toIso8601String(),
        'fromStatus': existing.status,
        'toStatus': status,
        'fromDate': existing.recordDate.toIso8601String(),
        'toDate': date.toIso8601String(),
      });
      next['history'] = history;
      savedMetadata = jsonEncode(next);
    }
    final Map<String, dynamic> payload = <String, dynamic>{
      'id': recordId,
      'kind': kind,
      'recordDate': date.toIso8601String(),
      'title': title.trim(),
      'value': value,
      'unit': unit,
      'status': status,
      'notes': notes.trim(),
      'metadataJson': savedMetadata,
      'createdAt': (existing?.createdAt ?? now).toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isDeleted': false,
    };
    await _db.transaction(() async {
      await _db
          .into(_db.activityRecords)
          .insertOnConflictUpdate(
            ActivityRecordsCompanion.insert(
              id: recordId,
              kind: kind,
              recordDate: date,
              title: title.trim(),
              value: Value<int?>(value),
              unit: Value<String?>(unit),
              status: Value<String?>(status),
              notes: Value<String>(notes.trim()),
              metadataJson: Value<String>(savedMetadata),
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
          );
      await _enqueue('activity', recordId, 'upsert', payload);
    });
  }

  Future<void> delete(ActivityRecord row) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.activityRecords,
      )..where((ActivityRecords t) => t.id.equals(row.id))).write(
        ActivityRecordsCompanion(
          isDeleted: const Value<bool>(true),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );
      await _enqueue('activity', row.id, 'delete', <String, dynamic>{
        'id': row.id,
        'kind': row.kind,
      });
    });
  }

  Stream<List<Habit>> watchHabits({bool archived = false}) =>
      (_db.select(_db.habits)
            ..where((Habits t) => t.isArchived.equals(archived))
            ..orderBy(<OrderClauseGenerator<Habits>>[
              (Habits t) => OrderingTerm.asc(t.name),
            ]))
          .watch();

  Stream<List<Habit>> watchAllHabits() =>
      (_db.select(_db.habits)..orderBy(<OrderClauseGenerator<Habits>>[
            (Habits t) => OrderingTerm.asc(t.name),
          ]))
          .watch();

  Stream<List<ActivityRecord>> watchPeriodStarts() =>
      (_db.select(_db.activityRecords)
            ..where(
              (ActivityRecords t) =>
                  t.kind.equals('period') &
                  t.status.equals('Period start') &
                  t.isDeleted.equals(false),
            )
            ..orderBy(<OrderClauseGenerator<ActivityRecords>>[
              (ActivityRecords t) => OrderingTerm.asc(t.recordDate),
            ]))
          .watch();

  Stream<List<HabitOccurrence>> watchTodayOccurrences(DateTime day) {
    final DateTime start = DateTime(day.year, day.month, day.day);
    return (_db.select(_db.habitOccurrences)..where(
          (HabitOccurrences t) =>
              t.occurrenceDate.isBiggerOrEqualValue(start) &
              t.occurrenceDate.isSmallerThanValue(
                start.add(const Duration(days: 1)),
              ),
        ))
        .watch();
  }

  Stream<List<HabitOccurrence>> watchHabitHistory(String habitId) =>
      (_db.select(_db.habitOccurrences)
            ..where((HabitOccurrences t) => t.habitId.equals(habitId))
            ..orderBy(<OrderClauseGenerator<HabitOccurrences>>[
              (HabitOccurrences t) => OrderingTerm.desc(t.occurrenceDate),
            ]))
          .watch();

  Future<void> saveHabit({
    String? id,
    required String name,
    required String category,
    required String trackingType,
    required String unit,
    required String scheduledDays,
    int? target,
    required bool reduction,
    String description = '',
  }) async {
    final String habitId = id ?? _id();
    final Habit? existing = id == null
        ? null
        : await (_db.select(
            _db.habits,
          )..where((Habits t) => t.id.equals(id))).getSingleOrNull();
    final Map<String, dynamic> payload = <String, dynamic>{
      'id': habitId,
      'name': name.trim(),
      'description': description.trim(),
      'category': category,
      'trackingType': trackingType,
      'unit': unit,
      'scheduleDays': scheduledDays,
      'target': target,
      'isReduction': reduction,
      'isArchived': false,
      'startDate': (existing?.startDate ?? DateTime.now()).toIso8601String(),
      'createdAt': (existing?.createdAt ?? DateTime.now()).toIso8601String(),
    };
    await _db.transaction(() async {
      await _db
          .into(_db.habits)
          .insertOnConflictUpdate(
            HabitsCompanion.insert(
              id: habitId,
              name: name.trim(),
              description: Value<String>(description.trim()),
              category: Value<String>(category),
              trackingType: Value<String>(trackingType),
              unit: Value<String>(unit),
              scheduleDays: Value<String>(scheduledDays),
              target: Value<int?>(target),
              isReduction: Value<bool>(reduction),
              startDate: existing?.startDate ?? DateTime.now(),
              createdAt: existing?.createdAt ?? DateTime.now(),
            ),
          );
      await _enqueue('habit', habitId, 'upsert', payload);
    });
  }

  Future<void> archiveHabit(Habit habit, bool archive) async {
    await _db.transaction(() async {
      await (_db.update(_db.habits)..where((Habits t) => t.id.equals(habit.id)))
          .write(HabitsCompanion(isArchived: Value<bool>(archive)));
      await _enqueue('habit', habit.id, 'upsert', <String, dynamic>{
        ..._habitJson(habit),
        'isArchived': archive,
      });
    });
  }

  Future<void> deleteHabit(Habit habit) async {
    await _db.transaction(() async {
      final List<HabitOccurrence> occurrences = await (_db.select(
        _db.habitOccurrences,
      )..where((HabitOccurrences t) => t.habitId.equals(habit.id))).get();
      for (final HabitOccurrence occurrence in occurrences) {
        await _enqueue(
          'habitOccurrence',
          occurrence.id,
          'delete',
          <String, dynamic>{'id': occurrence.id, 'habitId': habit.id},
        );
      }
      await (_db.delete(
        _db.habits,
      )..where((Habits t) => t.id.equals(habit.id))).go();
      await _enqueue('habit', habit.id, 'delete', <String, dynamic>{
        'id': habit.id,
      });
    });
  }

  Future<void> recordHabit(Habit habit, String status, {int? value}) async {
    final DateTime day = DateTime.now();
    await recordHabitOnDate(habit, day, status, value: value);
  }

  Future<void> recordHabitOnDate(
    Habit habit,
    DateTime date,
    String status, {
    int? value,
  }) async {
    final DateTime start = DateTime(date.year, date.month, date.day);
    await _db.transaction(() async {
      final HabitOccurrence? existing =
          await (_db.select(_db.habitOccurrences)..where(
                (HabitOccurrences t) =>
                    t.habitId.equals(habit.id) & t.occurrenceDate.equals(start),
              ))
              .getSingleOrNull();
      final HabitOccurrencesCompanion row = HabitOccurrencesCompanion.insert(
        id: existing?.id ?? _id(),
        habitId: habit.id,
        occurrenceDate: start,
        status: status,
        numericValue: Value<int?>(value),
        updatedAt: DateTime.now(),
      );
      await _db.into(_db.habitOccurrences).insertOnConflictUpdate(row);
      await _enqueue(
        'habitOccurrence',
        existing?.id ?? row.id.value,
        'upsert',
        <String, dynamic>{
          'id': existing?.id ?? row.id.value,
          'habitId': habit.id,
          'occurrenceDate': start.toIso8601String(),
          'status': status,
          'numericValue': value,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  Stream<List<Goal>> watchGoals() =>
      (_db.select(_db.goals)
            ..where((Goals t) => t.isDeleted.equals(false))
            ..orderBy(<OrderClauseGenerator<Goals>>[
              (Goals t) => OrderingTerm.asc(t.dueDate),
              (Goals t) => OrderingTerm.desc(t.updatedAt),
            ]))
          .watch();

  Future<void> saveGoal({
    String? id,
    required String name,
    required String timeframe,
    int? target,
    required int progress,
    required String unit,
    DateTime? dueDate,
    required String status,
    required String notes,
  }) async {
    final DateTime now = DateTime.now();
    final String goalId = id ?? _id();
    final Goal? existing = id == null
        ? null
        : await (_db.select(
            _db.goals,
          )..where((Goals t) => t.id.equals(id))).getSingleOrNull();
    final Map<String, dynamic> payload = <String, dynamic>{
      'id': goalId,
      'name': name.trim(),
      'timeframe': timeframe,
      'target': target,
      'progress': progress,
      'unit': unit,
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'notes': notes.trim(),
      'createdAt': (existing?.createdAt ?? now).toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isDeleted': false,
    };
    await _db.transaction(() async {
      await _db
          .into(_db.goals)
          .insertOnConflictUpdate(
            GoalsCompanion.insert(
              id: goalId,
              name: name.trim(),
              timeframe: Value<String>(timeframe),
              target: Value<int?>(target),
              progress: Value<int>(progress),
              unit: Value<String>(unit),
              dueDate: Value<DateTime?>(dueDate),
              status: Value<String>(status),
              notes: Value<String>(notes.trim()),
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
          );
      await _enqueue('goal', goalId, 'upsert', payload);
    });
  }

  Future<void> deleteGoal(Goal goal) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.goals,
      )..where((Goals t) => t.id.equals(goal.id))).write(
        GoalsCompanion(
          isDeleted: const Value<bool>(true),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );
      await _enqueue('goal', goal.id, 'delete', <String, dynamic>{
        'id': goal.id,
      });
    });
  }

  Stream<List<Budget>> watchBudgets() =>
      (_db.select(_db.budgets)..orderBy(<OrderClauseGenerator<Budgets>>[
            (Budgets t) => OrderingTerm.asc(t.category),
          ]))
          .watch();

  Future<void> saveBudget({
    String? id,
    required String category,
    required int amountMinor,
  }) async {
    if (amountMinor <= 0)
      throw ArgumentError.value(amountMinor, 'amountMinor', 'Must be positive');
    final DateTime now = DateTime.now();
    final String budgetId = id ?? _id();
    final Budget? existing = id == null
        ? null
        : await (_db.select(
            _db.budgets,
          )..where((Budgets t) => t.id.equals(id))).getSingleOrNull();
    final Map<String, dynamic> payload = <String, dynamic>{
      'id': budgetId,
      'category': category.trim(),
      'amountMinor': amountMinor,
      'period': 'Monthly',
      'createdAt': (existing?.createdAt ?? now).toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    await _db.transaction(() async {
      await _db
          .into(_db.budgets)
          .insertOnConflictUpdate(
            BudgetsCompanion.insert(
              id: budgetId,
              category: category.trim(),
              amountMinor: amountMinor,
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
          );
      await _enqueue('budget', budgetId, 'upsert', payload);
    });
  }

  Future<void> deleteBudget(Budget budget) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.budgets,
      )..where((Budgets t) => t.id.equals(budget.id))).go();
      await _enqueue('budget', budget.id, 'delete', <String, dynamic>{
        'id': budget.id,
      });
    });
  }

  String _id() {
    final Random random = Random.secure();
    return List<String>.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  Map<String, dynamic> _decodeMetadata(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }

  bool _sameLocalDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Map<String, dynamic> _habitJson(Habit habit) => <String, dynamic>{
    'id': habit.id,
    'name': habit.name,
    'description': habit.description,
    'category': habit.category,
    'trackingType': habit.trackingType,
    'unit': habit.unit,
    'scheduleDays': habit.scheduleDays,
    'target': habit.target,
    'isReduction': habit.isReduction,
    'isArchived': habit.isArchived,
    'startDate': habit.startDate.toIso8601String(),
    'createdAt': habit.createdAt.toIso8601String(),
  };

  Future<void> _enqueue(
    String type,
    String entityId,
    String operation,
    Map<String, dynamic> payload,
  ) async {
    final String id = '$type:$entityId';
    final SyncPendingChange? prior = await (_db.select(
      _db.syncPendingChanges,
    )..where((SyncPendingChanges t) => t.id.equals(id))).getSingleOrNull();
    final SyncMetadataData? revision =
        await (_db.select(_db.syncMetadata)
              ..where((SyncMetadata t) => t.key.equals('revision:$id')))
            .getSingleOrNull();
    await _db
        .into(_db.syncPendingChanges)
        .insertOnConflictUpdate(
          SyncPendingChangesCompanion.insert(
            id: id,
            entityType: type,
            entityId: entityId,
            operation: operation,
            changeId: Value<String>(_id()),
            payloadJson: Value<String>(jsonEncode(payload)),
            baseRevision: Value<int?>(
              prior?.baseRevision ?? int.tryParse(revision?.value ?? ''),
            ),
            enqueuedAt: prior?.enqueuedAt ?? DateTime.now(),
          ),
        );
  }
}
