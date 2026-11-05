import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/database/life_os_database.dart';
import 'package:life_os/data/records/records_repository.dart';

void main() {
  late LifeOsDatabase db;
  late RecordsRepository repo;
  setUp(() {
    db = LifeOsDatabase.forTesting(NativeDatabase.memory());
    repo = RecordsRepository(db);
  });
  tearDown(() async => db.close());

  test('record writes, historical edits, and soft deletion persist', () async {
    final DateTime date = DateTime(2026, 4, 3);
    await repo.save(
      kind: 'journal',
      title: 'First',
      date: date,
      notes: 'A note',
      id: 'stable-id',
    );
    await repo.save(
      kind: 'journal',
      title: 'Edited',
      date: date,
      notes: 'Updated',
      id: 'stable-id',
    );
    List<ActivityRecord> rows = await repo.watch('journal').first;
    expect(rows, hasLength(1));
    expect(rows.single.title, 'Edited');
    expect(rows.single.notes, 'Updated');
    await repo.delete(rows.single);
    expect(await repo.watch('journal').first, isEmpty);
    expect(
      (await db.select(db.activityRecords).get()).single.isDeleted,
      isTrue,
    );
  });

  test(
    'calendar queries include history in a month and exclude the next month',
    () async {
      await repo.save(
        kind: 'mood',
        title: 'Month boundary',
        date: DateTime(2026, 4, 30, 23, 45),
        value: 7,
        id: 'april-record',
      );
      await repo.save(
        kind: 'study',
        title: 'Next month',
        date: DateTime(2026, 5, 1),
        value: 30,
        id: 'may-record',
      );

      final List<ActivityRecord> april = await repo
          .watchCalendarRecords(DateTime(2026, 4), DateTime(2026, 5))
          .first;
      expect(april.map((ActivityRecord row) => row.id), <String>[
        'april-record',
      ]);
    },
  );

  test(
    'habits, schedule and occurrence status persist and update once per day',
    () async {
      await repo.saveHabit(
        name: 'Read',
        category: 'Study',
        trackingType: 'completion',
        unit: '',
        scheduledDays: '1,2,3,4,5',
        reduction: false,
      );
      final Habit habit = (await repo.watchHabits().first).single;
      expect(habit.scheduleDays, '1,2,3,4,5');
      await repo.recordHabit(habit, 'Completed');
      await repo.recordHabit(habit, 'Skipped');
      final DateTime now = DateTime.now();
      final List<HabitOccurrence> rows = await repo
          .watchTodayOccurrences(now)
          .first;
      expect(rows, hasLength(1));
      expect(rows.single.status, 'Skipped');
    },
  );

  test(
    'archiving and restoring a habit preserves its ID and history',
    () async {
      await repo.saveHabit(
        name: 'Stretch',
        category: 'Wellness',
        trackingType: 'completion',
        unit: '',
        scheduledDays: '1,2,3,4,5,6,7',
        reduction: false,
        id: 'habit-id',
      );
      Habit habit = (await repo.watchHabits().first).single;
      await repo.recordHabit(habit, 'Completed');
      await repo.archiveHabit(habit, true);
      expect(await repo.watchHabits().first, isEmpty);
      habit = (await repo.watchHabits(archived: true).first).single;
      await repo.archiveHabit(habit, false);
      expect((await repo.watchHabits().first).single.id, 'habit-id');
      expect(
        await repo.watchTodayOccurrences(DateTime.now()).first,
        hasLength(1),
      );
    },
  );

  test(
    'historical habit occurrences can be created and edited idempotently',
    () async {
      await repo.saveHabit(
        name: 'Walk',
        category: 'Wellness',
        trackingType: 'completion',
        unit: '',
        scheduledDays: '1,2,3,4,5,6,7',
        reduction: false,
        id: 'walk-habit',
      );
      final Habit habit = (await repo.watchHabits().first).single;
      final DateTime past = DateTime(2026, 2, 12, 17);
      await repo.recordHabitOnDate(habit, past, 'Completed');
      await repo.recordHabitOnDate(habit, past, 'Skipped');
      final List<HabitOccurrence> history = await repo
          .watchHabitHistory(habit.id)
          .first;
      expect(history, hasLength(1));
      expect(history.single.occurrenceDate, DateTime(2026, 2, 12));
      expect(history.single.status, 'Skipped');
    },
  );

  test('goal progress and budgets persist using integer minor units', () async {
    await repo.saveGoal(
      name: 'Read more',
      timeframe: 'Monthly',
      target: 4,
      progress: 1,
      unit: 'books',
      status: 'Active',
      notes: '',
      id: 'goal-1',
    );
    expect((await repo.watchGoals().first).single.progress, 1);
    await repo.saveGoal(
      name: 'Read more',
      timeframe: 'Monthly',
      target: 4,
      progress: 2,
      unit: 'books',
      status: 'Active',
      notes: '',
      id: 'goal-1',
    );
    expect((await repo.watchGoals().first).single.progress, 2);
    await repo.saveBudget(category: 'Groceries', amountMinor: 129999);
    expect((await repo.watchBudgets().first).single.amountMinor, 129999);
    await expectLater(
      repo.saveBudget(category: 'Invalid', amountMinor: 0),
      throwsArgumentError,
    );
  });

  test(
    'task status and rescheduling edits preserve prior state in metadata',
    () async {
      await repo.save(
        kind: 'tasks',
        title: 'Submit report',
        date: DateTime(2026, 4, 3),
        status: 'Planned',
        metadataJson: '{"priority":"High"}',
        id: 'task-a',
      );
      await repo.save(
        kind: 'tasks',
        title: 'Submit report',
        date: DateTime(2026, 4, 4),
        status: 'Completed',
        metadataJson: '{"priority":"High"}',
        id: 'task-a',
      );
      final ActivityRecord task = (await repo.watch('tasks').first).single;
      final Map<String, dynamic> metadata =
          jsonDecode(task.metadataJson) as Map<String, dynamic>;
      expect(metadata['priority'], 'High');
      final List<dynamic> history = metadata['history'] as List<dynamic>;
      expect(history, hasLength(1));
      expect(history.single['fromStatus'], 'Planned');
      expect(history.single['toStatus'], 'Completed');
    },
  );

  test(
    'offline record edits coalesce in the durable outbox with fresh idempotency keys',
    () async {
      await repo.save(
        kind: 'journal',
        title: 'Draft',
        date: DateTime(2026, 6, 1),
        notes: 'One',
        id: 'journal-offline',
      );
      final SyncPendingChange first =
          (await db.select(db.syncPendingChanges).get()).single;
      expect(first.entityType, 'activity');
      expect(first.operation, 'upsert');
      expect(first.changeId, isNotEmpty);
      await repo.save(
        kind: 'journal',
        title: 'Edited draft',
        date: DateTime(2026, 6, 1),
        notes: 'Two',
        id: 'journal-offline',
      );
      final SyncPendingChange second =
          (await db.select(db.syncPendingChanges).get()).single;
      expect(second.id, first.id);
      expect(second.changeId, isNot(first.changeId));
      expect(jsonDecode(second.payloadJson)['notes'], 'Two');
      await repo.delete((await repo.watch('journal').first).single);
      final SyncPendingChange deleted =
          (await db.select(db.syncPendingChanges).get()).single;
      expect(deleted.operation, 'delete');
    },
  );
}
