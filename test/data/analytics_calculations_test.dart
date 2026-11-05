import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/database/life_os_database.dart';
import 'package:life_os/data/records/analytics_calculations.dart';

void main() {
  group('AnalyticsWindow', () {
    test('day and week compare equal-length preceding windows', () {
      final AnalyticsWindow day = AnalyticsWindow.day(DateTime(2026, 10, 20));
      expect(day.start, DateTime(2026, 10, 20));
      expect(day.endExclusive, DateTime(2026, 10, 21));
      expect(day.comparisonStart, DateTime(2026, 10, 19));

      final AnalyticsWindow week = AnalyticsWindow.week(DateTime(2026, 10, 21));
      expect(week.start, DateTime(2026, 10, 19));
      expect(week.endExclusive, DateTime(2026, 10, 26));
      expect(week.comparisonStart, DateTime(2026, 10, 12));
    });

    test('current month compares only the same elapsed dates', () {
      final AnalyticsWindow month = AnalyticsWindow.month(
        DateTime(2026, 10, 1),
        today: DateTime(2026, 10, 20),
      );
      expect(month.start, DateTime(2026, 10, 1));
      expect(month.endExclusive, DateTime(2026, 10, 21));
      expect(month.comparisonStart, DateTime(2026, 9, 1));
      expect(month.comparisonEndExclusive, DateTime(2026, 9, 21));
    });

    test('month comparison handles shorter prior month', () {
      final AnalyticsWindow month = AnalyticsWindow.month(
        DateTime(2026, 3, 1),
        today: DateTime(2026, 4, 10),
      );
      expect(month.endExclusive, DateTime(2026, 4, 1));
      expect(month.comparisonStart, DateTime(2026, 2, 1));
      expect(month.comparisonEndExclusive, DateTime(2026, 3, 1));
    });

    test('custom range compares a preceding window of the same length', () {
      final AnalyticsWindow custom = AnalyticsWindow.custom(
        DateTime(2026, 4, 5),
        DateTime(2026, 4, 9),
      );
      expect(custom.endExclusive, DateTime(2026, 4, 10));
      expect(custom.comparisonStart, DateTime(2026, 3, 31));
      expect(custom.comparisonEndExclusive, DateTime(2026, 4, 5));
    });
  });

  group('AnalyticsCalculations', () {
    test(
      'scheduled habit percentage excludes missing, skipped, and off-schedule',
      () {
        final Habit weekday = habit(
          id: 'weekday',
          trackingType: 'completion',
          scheduleDays: '1,2,3,4,5',
          startDate: DateTime(2026, 10, 19),
        );
        final List<HabitOccurrence> rows = <HabitOccurrence>[
          occurrence('done', 'weekday', DateTime(2026, 10, 19), 'Completed'),
          occurrence('missed', 'weekday', DateTime(2026, 10, 20), 'Missed'),
          occurrence('skip', 'weekday', DateTime(2026, 10, 21), 'Skipped'),
          occurrence('sunday', 'weekday', DateTime(2026, 10, 25), 'Completed'),
        ];

        final AnalyticsSummary result = summary(
          DateTime(2026, 10, 19),
          DateTime(2026, 10, 26),
          habits: <Habit>[weekday],
          occurrences: rows,
        );

        expect(result.habitCompleted, 1);
        expect(result.habitEligible, 2);
        expect(result.habitCompletionPercent, 50);
      },
    );

    test('no eligible recorded habit outcomes remain no data', () {
      final Habit daily = habit(id: 'daily', trackingType: 'completion');
      final AnalyticsSummary result = summary(
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 20),
        habits: <Habit>[daily],
        occurrences: <HabitOccurrence>[
          occurrence('skip', 'daily', DateTime(2026, 10, 19), 'Skipped'),
        ],
      );
      expect(result.habitCompletionPercent, isNull);
    });

    test(
      'numerical habit values stay separate from completion percentages',
      () {
        final Habit numeric = habit(id: 'water', trackingType: 'numeric');
        final AnalyticsSummary result = summary(
          DateTime(2026, 10, 19),
          DateTime(2026, 10, 20),
          habits: <Habit>[numeric],
          occurrences: <HabitOccurrence>[
            occurrence(
              'water-value',
              'water',
              DateTime(2026, 10, 19),
              'Recorded',
              numericValue: 1200,
            ),
          ],
        );
        expect(result.habitCompletionPercent, isNull);
        expect(result.numericHabitCheckIns, 1);
      },
    );

    test(
      'study, mood, sleep quality, and screen time aggregate actual records',
      () {
        final AnalyticsSummary result = summary(
          DateTime(2026, 10, 19),
          DateTime(2026, 10, 20),
          records: <ActivityRecord>[
            record('study-1', 'study', DateTime(2026, 10, 19), 50),
            record('study-2', 'study', DateTime(2026, 10, 19, 16), 70),
            record('mood-1', 'mood', DateTime(2026, 10, 19), 4),
            record('mood-2', 'mood', DateTime(2026, 10, 19, 12), 8),
            record(
              'sleep',
              'sleep',
              DateTime(2026, 10, 19),
              420,
              metadataJson: '{"quality":4}',
            ),
            record('screen', 'screentime', DateTime(2026, 10, 19), 95),
          ],
        );
        expect(result.studyMinutes, 120);
        expect(result.moodAverage, 6);
        expect(result.moodDistribution[3], 1);
        expect(result.moodDistribution[7], 1);
        expect(result.sleepMinutes, 420);
        expect(result.sleepQualityAverage, 4);
        expect(result.screenTimeMinutes, 95);
      },
    );

    test('money uses integer minor units and transaction categories', () {
      final AnalyticsSummary result = summary(
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 20),
        records: <ActivityRecord>[
          record(
            'expense-a',
            'money',
            DateTime(2026, 10, 19),
            12999,
            status: 'Expense',
            metadataJson: '{"category":"Groceries"}',
          ),
          record(
            'expense-b',
            'money',
            DateTime(2026, 10, 19, 12),
            1,
            status: 'Expense',
            metadataJson: '{"category":"Groceries"}',
          ),
          record(
            'income',
            'money',
            DateTime(2026, 10, 19, 18),
            20000,
            status: 'Income',
          ),
        ],
      );
      expect(result.expenseMinor, 13000);
      expect(result.incomeMinor, 20000);
      expect(result.moneyCategories['Groceries'], 13000);
    });

    test(
      'journal and tasks count only recorded rows in the selected interval',
      () {
        final AnalyticsSummary result = summary(
          DateTime(2026, 10, 19),
          DateTime(2026, 10, 21),
          records: <ActivityRecord>[
            record('journal-a', 'journal', DateTime(2026, 10, 19), null),
            record('journal-b', 'journal', DateTime(2026, 10, 19, 22), null),
            record(
              'task-a',
              'tasks',
              DateTime(2026, 10, 20),
              null,
              status: 'Completed',
            ),
            record(
              'task-b',
              'tasks',
              DateTime(2026, 10, 20),
              null,
              status: 'Planned',
            ),
            record('outside', 'journal', DateTime(2026, 10, 21), null),
          ],
        );
        expect(result.journalEntries, 2);
        expect(result.journalDays, 1);
        expect(result.tasksCompleted, 1);
        expect(result.tasksPlanned, 2);
      },
    );

    test('period estimate uses adjacent historical start dates', () {
      final List<ActivityRecord> starts = <ActivityRecord>[
        record(
          'start-1',
          'period',
          DateTime(2026, 9, 1),
          null,
          status: 'Period start',
        ),
        record(
          'start-2',
          'period',
          DateTime(2026, 9, 29),
          null,
          status: 'Period start',
        ),
        record(
          'start-3',
          'period',
          DateTime(2026, 10, 19),
          null,
          status: 'Period start',
        ),
      ];
      final AnalyticsSummary result = summary(
        DateTime(2026, 10, 1),
        DateTime(2026, 11, 1),
        records: <ActivityRecord>[starts.last],
        allPeriodStarts: starts,
      );
      expect(result.periodStarts, 1);
      expect(result.averageCycleDays, 20);
    });

    test('records outside the interval and deleted rows are excluded', () {
      final AnalyticsSummary result = summary(
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 20),
        records: <ActivityRecord>[
          record('inside', 'study', DateTime(2026, 10, 19), 30),
          record('after', 'study', DateTime(2026, 10, 20), 60),
          record(
            'deleted',
            'study',
            DateTime(2026, 10, 19),
            90,
            isDeleted: true,
          ),
        ],
      );
      expect(result.studyMinutes, 30);
    });
  });
}

AnalyticsSummary summary(
  DateTime start,
  DateTime end, {
  Iterable<ActivityRecord> records = const <ActivityRecord>[],
  Iterable<HabitOccurrence> occurrences = const <HabitOccurrence>[],
  Iterable<Habit> habits = const <Habit>[],
  Iterable<ActivityRecord> allPeriodStarts = const <ActivityRecord>[],
}) => AnalyticsCalculations.summarize(
  start: start,
  endExclusive: end,
  records: records,
  occurrences: occurrences,
  habits: habits,
  allPeriodStarts: allPeriodStarts,
);

ActivityRecord record(
  String id,
  String kind,
  DateTime date,
  int? value, {
  String? status,
  String metadataJson = '{}',
  bool isDeleted = false,
}) {
  final DateTime now = DateTime(2026, 10, 20);
  return ActivityRecord(
    id: id,
    kind: kind,
    recordDate: date,
    title: id,
    value: value,
    unit: null,
    status: status,
    notes: '',
    metadataJson: metadataJson,
    createdAt: now,
    updatedAt: now,
    isDeleted: isDeleted,
  );
}

Habit habit({
  required String id,
  required String trackingType,
  String scheduleDays = '1,2,3,4,5,6,7',
  DateTime? startDate,
}) => Habit(
  id: id,
  name: id,
  description: '',
  category: 'Personal',
  trackingType: trackingType,
  unit: '',
  scheduleDays: scheduleDays,
  target: null,
  isReduction: false,
  isArchived: false,
  startDate: startDate ?? DateTime(2026, 1, 1),
  createdAt: DateTime(2026, 1, 1),
);

HabitOccurrence occurrence(
  String id,
  String habitId,
  DateTime date,
  String status, {
  int? numericValue,
}) => HabitOccurrence(
  id: id,
  habitId: habitId,
  occurrenceDate: DateTime(date.year, date.month, date.day),
  status: status,
  numericValue: numericValue,
  notes: '',
  updatedAt: DateTime(2026, 10, 20),
);
