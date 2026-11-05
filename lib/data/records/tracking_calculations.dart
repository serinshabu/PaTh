import '../database/life_os_database.dart';

class TrackingCalculations {
  const TrackingCalculations._();

  /// Percent uses only recorded eligible statuses. Missing, skipped, and
  /// not-applicable occurrences are excluded, never counted as misses.
  static double? habitCompletionPercent(Iterable<HabitOccurrence> occurrences) {
    final List<HabitOccurrence> eligible = occurrences
        .where(
          (HabitOccurrence row) =>
              row.status == 'Completed' || row.status == 'Missed',
        )
        .toList();
    if (eligible.isEmpty) return null;
    return eligible
            .where((HabitOccurrence row) => row.status == 'Completed')
            .length *
        100 /
        eligible.length;
  }

  static int studyMinutes(Iterable<ActivityRecord> sessions) => sessions
      .where(
        (ActivityRecord row) => row.kind == 'study' && (row.value ?? 0) >= 0,
      )
      .fold<int>(0, (int sum, ActivityRecord row) => sum + (row.value ?? 0));

  static double? averageMood(Iterable<ActivityRecord> entries) {
    final List<int> values = entries
        .where(
          (ActivityRecord row) =>
              row.kind == 'mood' &&
              row.value != null &&
              row.value! >= 1 &&
              row.value! <= 10,
        )
        .map((ActivityRecord row) => row.value!)
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((int a, int b) => a + b) / values.length;
  }

  /// Minutes between local clock times; a wake-up earlier than bedtime is
  /// interpreted as crossing midnight.
  static int sleepMinutes(DateTime bedtime, DateTime wakeTime) {
    DateTime wake = DateTime(
      bedtime.year,
      bedtime.month,
      bedtime.day,
      wakeTime.hour,
      wakeTime.minute,
    );
    if (!wake.isAfter(bedtime)) wake = wake.add(const Duration(days: 1));
    return wake.difference(bedtime).inMinutes;
  }

  static int? averageCycleLength(Iterable<DateTime> periodStarts) {
    final List<DateTime> sorted = periodStarts.toList()..sort();
    if (sorted.length < 2) return null;
    final List<int> lengths = <int>[];
    for (int i = 1; i < sorted.length; i++) {
      final int days = DateTime(sorted[i].year, sorted[i].month, sorted[i].day)
          .difference(
            DateTime(
              sorted[i - 1].year,
              sorted[i - 1].month,
              sorted[i - 1].day,
            ),
          )
          .inDays;
      if (days >= 15 && days <= 60) lengths.add(days);
    }
    if (lengths.isEmpty) return null;
    return lengths.reduce((int a, int b) => a + b) ~/ lengths.length;
  }

  /// Money values are integer minor units (paise for INR) to avoid floating
  /// point accumulation.
  static int moneyMinorUnits(
    Iterable<ActivityRecord> transactions, {
    String? status,
  }) => transactions
      .where(
        (ActivityRecord row) =>
            row.kind == 'money' && (status == null || row.status == status),
      )
      .fold<int>(0, (int sum, ActivityRecord row) => sum + (row.value ?? 0));

  static int parseMoneyMinorUnits(String raw) {
    final String value = raw.trim();
    if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(value)) {
      throw const FormatException(
        'Use digits and no more than two decimal places.',
      );
    }
    final List<String> parts = value.split('.');
    return int.parse(parts.first) * 100 +
        int.parse(parts.length == 1 ? '00' : parts[1].padRight(2, '0'));
  }
}
