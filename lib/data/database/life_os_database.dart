import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'life_os_database.g.dart';

class AppPreferences extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get themeId =>
      text().withDefault(const Constant('midnightRose'))();
  TextColumn get accentId => text().withDefault(const Constant('rose'))();
  TextColumn get currencyCode => text().withDefault(const Constant('INR'))();
  TextColumn get dateFormat =>
      text().withDefault(const Constant('DD/MM/YYYY'))();
  TextColumn get timeFormat => text().withDefault(const Constant('12-hour'))();
  BoolColumn get sidebarCollapsed =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DashboardCardSetting')
class DashboardCards extends Table {
  TextColumn get cardId => text()();
  IntColumn get position => integer()();
  BoolColumn get visible => boolean().withDefault(const Constant(true))();
  IntColumn get desktopSpan => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {cardId};
}

class SyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class SyncPendingChanges extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get changeId => text().withDefault(const Constant(''))();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  IntColumn get baseRevision => integer().nullable()();
  DateTimeColumn get enqueuedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get localPayloadJson => text()();
  TextColumn get remotePayloadJson => text()();
  IntColumn get remoteRevision => integer()();
  DateTimeColumn get detectedAt => dateTime()();
  TextColumn get resolution => text().nullable()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ActivityRecords extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  DateTimeColumn get recordDate => dateTime()();
  TextColumn get title => text()();
  IntColumn get value => integer().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('Personal'))();
  TextColumn get trackingType =>
      text().withDefault(const Constant('completion'))();
  TextColumn get unit => text().withDefault(const Constant(''))();
  TextColumn get scheduleDays =>
      text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  IntColumn get target => integer().nullable()();
  BoolColumn get isReduction => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class HabitOccurrences extends Table {
  TextColumn get id => text()();
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get occurrenceDate => dateTime()();
  TextColumn get status => text()();
  IntColumn get numericValue => integer().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get timeframe => text().withDefault(const Constant('Long-term'))();
  IntColumn get target => integer().nullable()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  TextColumn get unit => text().withDefault(const Constant('steps'))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('Active'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get period => text().withDefault(const Constant('Monthly'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    AppPreferences,
    DashboardCards,
    SyncMetadata,
    SyncPendingChanges,
    SyncConflicts,
    ActivityRecords,
    Habits,
    HabitOccurrences,
    Goals,
    Budgets,
  ],
)
class LifeOsDatabase extends _$LifeOsDatabase {
  LifeOsDatabase() : super(driftDatabase(name: 'life_os'));

  LifeOsDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await migrator.createTable(activityRecords);
        await migrator.createTable(habits);
        await migrator.createTable(habitOccurrences);
      }
      if (from < 3) {
        await migrator.createTable(goals);
      }
      if (from < 4) {
        await migrator.createTable(budgets);
      }
      if (from < 5) {
        await migrator.createTable(syncPendingChanges);
        await migrator.createTable(syncConflicts);
      }
      if (from >= 5 && from < 6) {
        await migrator.addColumn(
          syncPendingChanges,
          syncPendingChanges.changeId,
        );
      }
      if (from >= 5 && from < 7) {
        await migrator.addColumn(syncConflicts, syncConflicts.resolution);
        await migrator.addColumn(syncConflicts, syncConflicts.resolvedAt);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
