import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/database/life_os_database.dart';
import 'package:life_os/data/records/tracking_calculations.dart';

void main() {
  test('missing, skipped and not-applicable habits are not failures', () {
    final DateTime day = DateTime(2026, 10, 18);
    final List<HabitOccurrence> rows = <HabitOccurrence>[
      occurrence(day, 'Completed'),
      occurrence(day.add(const Duration(days: 1)), 'Missed'),
      occurrence(day.add(const Duration(days: 2)), 'Skipped'),
      occurrence(day.add(const Duration(days: 3)), 'Not applicable'),
    ];
    expect(TrackingCalculations.habitCompletionPercent(rows), 50);
    expect(
      TrackingCalculations.habitCompletionPercent(<HabitOccurrence>[]),
      isNull,
    );
  });

  test('study duration totals add valid sessions', () {
    expect(
      TrackingCalculations.studyMinutes(<ActivityRecord>[
        activity('study', value: 45),
        activity('study', value: 75),
        activity('money', value: 300),
      ]),
      120,
    );
  });

  test('mood averages use only recorded ratings', () {
    expect(
      TrackingCalculations.averageMood(<ActivityRecord>[
        activity('mood', value: 3),
        activity('mood', value: 8),
      ]),
      5.5,
    );
    expect(TrackingCalculations.averageMood(<ActivityRecord>[]), isNull);
  });

  test('sleep intervals can cross midnight', () {
    expect(
      TrackingCalculations.sleepMinutes(
        DateTime(2026, 10, 18, 23, 30),
        DateTime(2026, 10, 18, 7, 0),
      ),
      450,
    );
  });

  test('cycle length estimate averages plausible start intervals', () {
    expect(
      TrackingCalculations.averageCycleLength(<DateTime>[
        DateTime(2026, 7, 1),
        DateTime(2026, 7, 29),
        DateTime(2026, 8, 28),
      ]),
      29,
    );
    expect(
      TrackingCalculations.averageCycleLength(<DateTime>[DateTime(2026, 7, 1)]),
      isNull,
    );
  });

  test(
    'money adds integer minor units exactly and can filter income/expense',
    () {
      final List<ActivityRecord> rows = <ActivityRecord>[
        activity('money', value: 1999, status: 'Expense'),
        activity('money', value: 2, status: 'Expense'),
        activity('money', value: 5000, status: 'Income'),
      ];
      expect(TrackingCalculations.moneyMinorUnits(rows), 7001);
      expect(
        TrackingCalculations.moneyMinorUnits(rows, status: 'Expense'),
        2001,
      );
      expect(
        TrackingCalculations.parseMoneyMinorUnits('0.10') +
            TrackingCalculations.parseMoneyMinorUnits('0.20'),
        30,
      );
      expect(TrackingCalculations.parseMoneyMinorUnits('125'), 12500);
      expect(
        () => TrackingCalculations.parseMoneyMinorUnits('1.009'),
        throwsFormatException,
      );
    },
  );
}

HabitOccurrence occurrence(DateTime date, String status) => HabitOccurrence(
  id: '${date.day}',
  habitId: 'habit-1',
  occurrenceDate: date,
  status: status,
  numericValue: null,
  notes: '',
  updatedAt: date,
);

ActivityRecord activity(String kind, {int? value, String? status}) {
  final DateTime now = DateTime(2026, 10, 18);
  return ActivityRecord(
    id: '$kind-${value ?? 0}',
    kind: kind,
    recordDate: now,
    title: 'entry',
    value: value,
    unit: null,
    status: status,
    notes: '',
    metadataJson: '{}',
    createdAt: now,
    updatedAt: now,
    isDeleted: false,
  );
}
