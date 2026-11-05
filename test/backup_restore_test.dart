import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/backup/life_os_backup.dart';
import 'package:life_os/data/database/life_os_database.dart';
import 'package:life_os/data/records/records_repository.dart';

void main() {
  late LifeOsDatabase source;
  late LifeOsDatabase target;

  setUp(() {
    source = LifeOsDatabase.forTesting(NativeDatabase.memory());
    target = LifeOsDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  test(
    'versioned backup round trips content, history, and preferences',
    () async {
      final RecordsRepository repository = RecordsRepository(source);
      await repository.save(
        id: 'journal-1',
        kind: 'journal',
        title: 'A private note',
        date: DateTime(2026, 10, 20),
        notes: 'Kept in local backup',
      );
      await repository.saveHabit(
        id: 'habit-1',
        name: 'Read',
        category: 'Study',
        trackingType: 'completion',
        unit: '',
        scheduledDays: '1,2,3,4,5,6,7',
        reduction: false,
      );
      final String json = await LifeOsBackup(source).createJson();
      expect(jsonDecode(json)['version'], LifeOsBackup.currentVersion);
      final BackupPreview preview = await LifeOsBackup(target).preview(json);
      expect(preview.counts['activities'], 1);
      await LifeOsBackup(target).restore(json, BackupRestoreMode.merge);
      final ActivityRecord restored = await (target.select(
        target.activityRecords,
      )..where((ActivityRecords t) => t.id.equals('journal-1'))).getSingle();
      expect(restored.notes, 'Kept in local backup');
      expect(await (target.select(target.habits)).get(), hasLength(1));
      expect(await (target.select(target.appPreferences)).get(), hasLength(1));
    },
  );

  test('merge preserves a matching local ID without overwriting it', () async {
    await RecordsRepository(source).save(
      id: 'shared',
      kind: 'journal',
      title: 'From backup',
      date: DateTime(2026, 10, 20),
    );
    await RecordsRepository(target).save(
      id: 'shared',
      kind: 'journal',
      title: 'Keep local',
      date: DateTime(2026, 10, 21),
    );
    final String json = await LifeOsBackup(source).createJson();
    final BackupPreview preview = await LifeOsBackup(target).preview(json);
    expect(preview.duplicateIds, 1);
    await LifeOsBackup(target).restore(json, BackupRestoreMode.merge);
    final ActivityRecord result = await (target.select(
      target.activityRecords,
    )..where((ActivityRecords t) => t.id.equals('shared'))).getSingle();
    expect(result.title, 'Keep local');
  });

  test('malformed backup is rejected before changing records', () async {
    await RecordsRepository(target).save(
      id: 'existing',
      kind: 'journal',
      title: 'Stay',
      date: DateTime(2026),
    );
    await expectLater(
      LifeOsBackup(target).restore(
        '{"format":"lifeos-backup","version":99}',
        BackupRestoreMode.replace,
      ),
      throwsFormatException,
    );
    expect(await (target.select(target.activityRecords)).get(), hasLength(1));
  });

  test(
    'replace queues records absent from the restored backup for sync deletion',
    () async {
      await RecordsRepository(
        target,
      ).save(id: 'old', kind: 'journal', title: 'Old', date: DateTime(2026));
      final String emptyBackup = await LifeOsBackup(source).createJson();
      await LifeOsBackup(
        target,
      ).restore(emptyBackup, BackupRestoreMode.replace);
      final SyncPendingChange deletion =
          await (target.select(target.syncPendingChanges)
                ..where((SyncPendingChanges t) => t.id.equals('activity:old')))
              .getSingle();
      expect(deletion.operation, 'delete');
      expect(await (target.select(target.activityRecords)).get(), isEmpty);
    },
  );

  test(
    'CSV exports include headers for empty data and escape spreadsheet formulas',
    () {
      expect(
        LifeOsCsv.export(
          'empty',
          const <Map<String, dynamic>>[],
          headers: const <String>['id', 'title'],
        ),
        '"id","title"',
      );
      expect(
        LifeOsCsv.export('notes', <Map<String, dynamic>>[
          <String, dynamic>{'note': '=1+1'},
        ]),
        contains("'=1+1"),
      );
    },
  );
}
