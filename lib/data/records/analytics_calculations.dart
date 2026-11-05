import 'dart:convert';

import '../database/life_os_database.dart';

enum AnalyticsPeriod { day, week, month, custom }

enum AnalyticsMetric {
  habits('Habit completion', '%'),
  study('Study time', 'hours'),
  gym('Gym attendance', 'days'),
  mood('Mood average', '/10'),
  sleep('Sleep duration', 'hours'),
  spending('Expenses', 'minor units'),
  screenTime('Screen time', 'minutes'),
  journal('Journal entries', 'entries'),
  tasks('Tasks completed', 'tasks'),
  period('Period starts', 'starts');

  const AnalyticsMetric(this.label, this.unit);
  final String label;
  final String unit;
}

class AnalyticsWindow {
  const AnalyticsWindow({
    required this.period,
    required this.start,
    required this.endExclusive,
    required this.comparisonStart,
    required this.comparisonEndExclusive,
  });

  final AnalyticsPeriod period;
  final DateTime start;
  final DateTime endExclusive;
  final DateTime comparisonStart;
  final DateTime comparisonEndExclusive;

  factory AnalyticsWindow.day(DateTime anchor) {
    final DateTime start = analyticsDay(anchor);
    return AnalyticsWindow(
      period: AnalyticsPeriod.day,
      start: start,
      endExclusive: start.add(const Duration(days: 1)),
      comparisonStart: start.subtract(const Duration(days: 1)),
      comparisonEndExclusive: start,
    );
  }

  factory AnalyticsWindow.week(DateTime anchor) {
    final DateTime normalized = analyticsDay(anchor);
    final DateTime start = normalized.subtract(
      Duration(days: normalized.weekday - DateTime.monday),
    );
    return AnalyticsWindow(
      period: AnalyticsPeriod.week,
      start: start,
      endExclusive: start.add(const Duration(days: 7)),
      comparisonStart: start.subtract(const Duration(days: 7)),
      comparisonEndExclusive: start,
    );
  }

  factory AnalyticsWindow.month(DateTime anchor, {DateTime? today}) {
    final DateTime first = DateTime(anchor.year, anchor.month);
    final DateTime nextMonth = DateTime(anchor.year, anchor.month + 1);
    final DateTime now = analyticsDay(today ?? DateTime.now());
    final bool isCurrentMonth =
        first.year == now.year && first.month == now.month;
    final DateTime end = isCurrentMonth
        ? (now.add(const Duration(days: 1)).isBefore(nextMonth)
              ? now.add(const Duration(days: 1))
              : nextMonth)
        : nextMonth;
    final DateTime previous = DateTime(first.year, first.month - 1);
    final int daysInPreviousMonth = DateTime(
      previous.year,
      previous.month + 1,
    ).difference(previous).inDays;
    final int elapsedDays = end.difference(first).inDays;
    final int comparisonDays = elapsedDays.clamp(1, daysInPreviousMonth);
    return AnalyticsWindow(
      period: AnalyticsPeriod.month,
      start: first,
      endExclusive: end,
      comparisonStart: previous,
      comparisonEndExclusive: previous.add(Duration(days: comparisonDays)),
    );
  }

  factory AnalyticsWindow.custom(DateTime first, DateTime lastInclusive) {
    final DateTime start = analyticsDay(first);
    final DateTime end = analyticsDay(
      lastInclusive,
    ).add(const Duration(days: 1));
    final Duration length = end.difference(start);
    return AnalyticsWindow(
      period: AnalyticsPeriod.custom,
      start: start,
      endExclusive: end,
      comparisonStart: start.subtract(length),
      comparisonEndExclusive: start,
    );
  }
}

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.habitCompletionPercent,
    required this.habitCompleted,
    required this.habitEligible,
    required this.numericHabitCheckIns,
    required this.studyMinutes,
    required this.gymDays,
    required this.moodAverage,
    required this.moodDistribution,
    required this.sleepMinutes,
    required this.sleepQualityAverage,
    required this.expenseMinor,
    required this.incomeMinor,
    required this.moneyCategories,
    required this.screenTimeMinutes,
    required this.journalEntries,
    required this.journalDays,
    required this.tasksCompleted,
    required this.tasksPlanned,
    required this.periodStarts,
    required this.averageCycleDays,
  });

  final double? habitCompletionPercent;
  final int habitCompleted;
  final int habitEligible;
  final int numericHabitCheckIns;
  final int? studyMinutes;
  final int? gymDays;
  final double? moodAverage;
  final List<int> moodDistribution;
  final int? sleepMinutes;
  final double? sleepQualityAverage;
  final int? expenseMinor;
  final int? incomeMinor;
  final Map<String, int> moneyCategories;
  final int? screenTimeMinutes;
  final int? journalEntries;
  final int? journalDays;
  final int? tasksCompleted;
  final int? tasksPlanned;
  final int? periodStarts;
  final int? averageCycleDays;

  num? valueFor(AnalyticsMetric metric) => switch (metric) {
    AnalyticsMetric.habits => habitCompletionPercent,
    AnalyticsMetric.study => studyMinutes == null ? null : studyMinutes! / 60,
    AnalyticsMetric.gym => gymDays,
    AnalyticsMetric.mood => moodAverage,
    AnalyticsMetric.sleep => sleepMinutes == null ? null : sleepMinutes! / 60,
    AnalyticsMetric.spending =>
      expenseMinor == null ? null : expenseMinor! / 100,
    AnalyticsMetric.screenTime => screenTimeMinutes,
    AnalyticsMetric.journal => journalEntries,
    AnalyticsMetric.tasks => tasksCompleted,
    AnalyticsMetric.period => periodStarts,
  };
}

class AnalyticsCalculations {
  const AnalyticsCalculations._();

  static AnalyticsSummary summarize({
    required DateTime start,
    required DateTime endExclusive,
    required Iterable<ActivityRecord> records,
    required Iterable<HabitOccurrence> occurrences,
    required Iterable<Habit> habits,
    required Iterable<ActivityRecord> allPeriodStarts,
  }) {
    final List<ActivityRecord> inRange = records
        .where(
          (ActivityRecord row) =>
              !row.isDeleted &&
              !row.recordDate.isBefore(start) &&
              row.recordDate.isBefore(endExclusive),
        )
        .toList();
    final List<HabitOccurrence> occurrenceRows = occurrences
        .where(
          (HabitOccurrence row) =>
              !row.occurrenceDate.isBefore(start) &&
              row.occurrenceDate.isBefore(endExclusive),
        )
        .toList();
    final Map<String, Habit> habitById = <String, Habit>{
      for (final Habit habit in habits) habit.id: habit,
    };
    final List<HabitOccurrence> scheduled = occurrenceRows.where((
      HabitOccurrence row,
    ) {
      final Habit? habit = habitById[row.habitId];
      if (habit == null ||
          _day(row.occurrenceDate).isBefore(_day(habit.startDate))) {
        return false;
      }
      final Set<int> days = habit.scheduleDays
          .split(',')
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
      return days.contains(row.occurrenceDate.weekday);
    }).toList();
    final List<HabitOccurrence> eligible = scheduled
        .where(
          (HabitOccurrence row) =>
              !_isNumeric(habitById[row.habitId]?.trackingType) &&
              (row.status == 'Completed' || row.status == 'Missed'),
        )
        .toList();
    final int completed = eligible
        .where((HabitOccurrence row) => row.status == 'Completed')
        .length;
    final int numericValues = scheduled
        .where(
          (HabitOccurrence row) =>
              _isNumeric(habitById[row.habitId]?.trackingType) &&
              row.numericValue != null,
        )
        .length;

    final List<ActivityRecord> study = inRange
        .where((ActivityRecord row) => row.kind == 'study' && row.value != null)
        .toList();
    final List<ActivityRecord> gym = inRange
        .where((ActivityRecord row) => row.kind == 'gym')
        .toList();
    final List<ActivityRecord> moods = inRange
        .where(
          (ActivityRecord row) =>
              row.kind == 'mood' &&
              row.value != null &&
              row.value! >= 1 &&
              row.value! <= 10,
        )
        .toList();
    final List<int> moodValues = moods
        .map((ActivityRecord row) => row.value!)
        .toList();
    final List<ActivityRecord> sleeps = inRange
        .where(
          (ActivityRecord row) =>
              row.kind == 'sleep' &&
              row.value != null &&
              row.value! > 0 &&
              row.value! <= 1440,
        )
        .toList();
    final List<double> qualities = sleeps
        .map((ActivityRecord row) => _metadata(row.metadataJson)['quality'])
        .whereType<num>()
        .where((num value) => value >= 1 && value <= 5)
        .map((num value) => value.toDouble())
        .toList();
    final List<ActivityRecord> money = inRange
        .where(
          (ActivityRecord row) =>
              row.kind == 'money' &&
              row.value != null &&
              (row.status == 'Expense' || row.status == 'Income'),
        )
        .toList();
    final List<ActivityRecord> expenses = money
        .where((ActivityRecord row) => row.status == 'Expense')
        .toList();
    final List<ActivityRecord> income = money
        .where((ActivityRecord row) => row.status == 'Income')
        .toList();
    final Map<String, int> categoryTotals = <String, int>{};
    for (final ActivityRecord row in expenses) {
      final String rawCategory =
          _metadata(row.metadataJson)['category'] is String
          ? (_metadata(row.metadataJson)['category'] as String).trim()
          : '';
      final String category = rawCategory.isEmpty
          ? 'Uncategorized'
          : rawCategory;
      categoryTotals.update(
        category,
        (int previous) => previous + row.value!,
        ifAbsent: () => row.value!,
      );
    }
    final List<ActivityRecord> screenRecords = inRange
        .where(
          (ActivityRecord row) =>
              row.kind == 'screentime' && row.value != null && row.value! >= 0,
        )
        .toList();
    final List<ActivityRecord> journals = inRange
        .where((ActivityRecord row) => row.kind == 'journal')
        .toList();
    final Set<DateTime> journalDays = journals
        .map((ActivityRecord row) => _day(row.recordDate))
        .toSet();
    final List<ActivityRecord> tasks = inRange
        .where(
          (ActivityRecord row) =>
              row.kind == 'tasks' &&
              <String>{
                'Planned',
                'In progress',
                'Completed',
                'Rescheduled',
              }.contains(row.status),
        )
        .toList();
    final List<DateTime> starts =
        allPeriodStarts
            .where(
              (ActivityRecord row) =>
                  row.kind == 'period' &&
                  row.status == 'Period start' &&
                  !row.isDeleted &&
                  !row.recordDate.isBefore(start) &&
                  row.recordDate.isBefore(endExclusive),
            )
            .map((ActivityRecord row) => _day(row.recordDate))
            .toSet()
            .toList()
          ..sort();
    final bool hasPeriodRecords = inRange.any(
      (ActivityRecord row) => row.kind == 'period',
    );
    final List<DateTime> periodHistory =
        allPeriodStarts
            .where(
              (ActivityRecord row) =>
                  row.kind == 'period' &&
                  row.status == 'Period start' &&
                  !row.isDeleted &&
                  row.recordDate.isBefore(endExclusive),
            )
            .map((ActivityRecord row) => _day(row.recordDate))
            .toSet()
            .toList()
          ..sort();
    final List<int> cycleLengths = <int>[];
    for (int index = 1; index < periodHistory.length; index++) {
      final DateTime latest = periodHistory[index];
      if (latest.isBefore(start)) continue;
      final int days = latest.difference(periodHistory[index - 1]).inDays;
      if (days >= 15 && days <= 60) cycleLengths.add(days);
    }

    return AnalyticsSummary(
      habitCompletionPercent: eligible.isEmpty
          ? null
          : completed * 100 / eligible.length,
      habitCompleted: completed,
      habitEligible: eligible.length,
      numericHabitCheckIns: numericValues,
      studyMinutes: study.isEmpty
          ? null
          : study.fold<int>(
              0,
              (int sum, ActivityRecord row) => sum + row.value!,
            ),
      gymDays: gym.isEmpty
          ? null
          : gym
                .where((ActivityRecord row) => row.status == 'Attended')
                .map((ActivityRecord row) => _day(row.recordDate))
                .toSet()
                .length,
      moodAverage: moodValues.isEmpty
          ? null
          : moodValues.reduce((int a, int b) => a + b) / moodValues.length,
      moodDistribution: List<int>.generate(
        10,
        (int index) =>
            moodValues.where((int value) => value == index + 1).length,
        growable: false,
      ),
      sleepMinutes: sleeps.isEmpty
          ? null
          : sleeps.fold<int>(
                  0,
                  (int sum, ActivityRecord row) => sum + row.value!,
                ) ~/
                sleeps.length,
      sleepQualityAverage: qualities.isEmpty
          ? null
          : qualities.reduce((double a, double b) => a + b) / qualities.length,
      expenseMinor: money.isEmpty
          ? null
          : expenses.fold<int>(
              0,
              (int sum, ActivityRecord row) => sum + row.value!,
            ),
      incomeMinor: money.isEmpty
          ? null
          : income.fold<int>(
              0,
              (int sum, ActivityRecord row) => sum + row.value!,
            ),
      moneyCategories: categoryTotals,
      screenTimeMinutes: screenRecords.isEmpty
          ? null
          : screenRecords.fold<int>(
              0,
              (int sum, ActivityRecord row) => sum + row.value!,
            ),
      journalEntries: journals.isEmpty ? null : journals.length,
      journalDays: journals.isEmpty ? null : journalDays.length,
      tasksCompleted: tasks.isEmpty
          ? null
          : tasks
                .where((ActivityRecord row) => row.status == 'Completed')
                .length,
      tasksPlanned: tasks.isEmpty ? null : tasks.length,
      periodStarts: hasPeriodRecords ? starts.length : null,
      averageCycleDays: cycleLengths.isEmpty
          ? null
          : cycleLengths.reduce((int a, int b) => a + b) ~/ cycleLengths.length,
    );
  }

  static Map<String, dynamic> _metadata(String raw) {
    try {
      final dynamic parsed = jsonDecode(raw);
      return parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }

  static bool _isNumeric(String? trackingType) {
    final String normalized = trackingType?.toLowerCase() ?? '';
    return normalized.contains('numeric') || normalized.contains('number');
  }

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

DateTime analyticsDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);
