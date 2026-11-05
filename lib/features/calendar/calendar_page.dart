import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_providers.dart';
import '../../app/theme/life_os_palette.dart';
import '../../data/database/life_os_database.dart';
import '../../data/records/records_repository.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = _day(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final LifeOsPalette palette = LifeOsPalette.fromId(
      ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose',
    );
    final RecordsRepository repository = ref.watch(recordsRepositoryProvider);
    final DateTime start = DateTime(_month.year, _month.month);
    final DateTime end = DateTime(_month.year, _month.month + 1);
    return StreamBuilder<List<ActivityRecord>>(
      stream: repository.watchCalendarRecords(start, end),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<ActivityRecord>> recordSnapshot,
          ) {
            return StreamBuilder<List<HabitOccurrence>>(
              stream: repository.watchHabitOccurrencesBetween(start, end),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<HabitOccurrence>> habitSnapshot,
                  ) {
                    if (recordSnapshot.hasError || habitSnapshot.hasError) {
                      return _CalendarMessage(
                        palette: palette,
                        icon: Icons.error_outline_rounded,
                        title: 'Calendar could not be loaded',
                        message:
                            'Your saved records are unchanged. Try opening the calendar again.',
                      );
                    }
                    if (!recordSnapshot.hasData || !habitSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final List<ActivityRecord> records = recordSnapshot.data!;
                    final List<HabitOccurrence> occurrences =
                        habitSnapshot.data!;
                    return _calendarContent(
                      context,
                      palette,
                      records,
                      occurrences,
                    );
                  },
            );
          },
    );
  }

  Widget _calendarContent(
    BuildContext context,
    LifeOsPalette palette,
    List<ActivityRecord> records,
    List<HabitOccurrence> occurrences,
  ) {
    final int leading = _month.weekday - 1;
    final int daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final int cellCount = ((leading + daysInMonth + 6) ~/ 7) * 7;
    final DateTime today = _day(DateTime.now());
    final List<ActivityRecord> selectedRecords = records
        .where((ActivityRecord row) => _sameDay(row.recordDate, _selected))
        .toList();
    final List<HabitOccurrence> selectedHabits = occurrences
        .where((HabitOccurrence row) => _sameDay(row.occurrenceDate, _selected))
        .toList();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double sidePadding = constraints.maxWidth < 600 ? 16 : 28;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(sidePadding, 16, sidePadding, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _monthHeader(context, palette),
                  const SizedBox(height: 14),
                  _legend(palette),
                  const SizedBox(height: 14),
                  Container(
                    padding: EdgeInsets.all(
                      constraints.maxWidth < 600 ? 10 : 18,
                    ),
                    decoration: BoxDecoration(
                      color: palette.card,
                      border: Border.all(color: palette.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            for (String weekday in <String>[
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun',
                            ])
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Text(weekday),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cellCount,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                childAspectRatio: 0.86,
                              ),
                          itemBuilder: (BuildContext context, int index) {
                            final int dayNumber = index - leading + 1;
                            if (dayNumber < 1 || dayNumber > daysInMonth) {
                              return const SizedBox.shrink();
                            }
                            final DateTime day = DateTime(
                              _month.year,
                              _month.month,
                              dayNumber,
                            );
                            final List<ActivityRecord> dayRecords = records
                                .where(
                                  (ActivityRecord row) =>
                                      _sameDay(row.recordDate, day),
                                )
                                .toList();
                            final List<HabitOccurrence> dayHabits = occurrences
                                .where(
                                  (HabitOccurrence row) =>
                                      _sameDay(row.occurrenceDate, day),
                                )
                                .toList();
                            final List<int> moods = dayRecords
                                .where(
                                  (ActivityRecord row) =>
                                      row.kind == 'mood' && row.value != null,
                                )
                                .map((ActivityRecord row) => row.value!)
                                .toList();
                            final double? averageMood = moods.isEmpty
                                ? null
                                : moods.reduce((int a, int b) => a + b) /
                                      moods.length;
                            final bool hasActivity =
                                dayRecords.isNotEmpty || dayHabits.isNotEmpty;
                            return _CalendarDayCell(
                              day: day,
                              selected: _sameDay(day, _selected),
                              isToday: _sameDay(day, today),
                              recordCount: dayRecords.length + dayHabits.length,
                              moodAverage: averageMood,
                              palette: palette,
                              onTap: () => setState(() => _selected = day),
                              hasActivity: hasActivity,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _selectedDayPanel(
                    context,
                    palette,
                    selectedRecords,
                    selectedHabits,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _monthHeader(BuildContext context, LifeOsPalette palette) => Row(
    children: <Widget>[
      Expanded(
        child: Text(
          DateFormat('MMMM yyyy').format(_month),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      IconButton(
        tooltip: 'Previous month',
        onPressed: () => setState(() {
          _month = DateTime(_month.year, _month.month - 1);
          _selected = DateTime(_month.year, _month.month, 1);
        }),
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      IconButton(
        tooltip: 'Next month',
        onPressed: () => setState(() {
          _month = DateTime(_month.year, _month.month + 1);
          _selected = DateTime(_month.year, _month.month, 1);
        }),
        icon: const Icon(Icons.chevron_right_rounded),
      ),
      TextButton(
        onPressed: () => setState(() {
          _month = DateTime(DateTime.now().year, DateTime.now().month);
          _selected = _day(DateTime.now());
        }),
        child: const Text('Today'),
      ),
    ],
  );

  Widget _legend(LifeOsPalette palette) => Wrap(
    spacing: 14,
    runSpacing: 8,
    children: <Widget>[
      _LegendItem(
        icon: Icons.sentiment_dissatisfied_outlined,
        color: palette.negative,
        label: 'Lower mood (1–3)',
      ),
      _LegendItem(
        icon: Icons.sentiment_neutral_outlined,
        color: palette.warning,
        label: 'Mid-range mood (4–6)',
      ),
      _LegendItem(
        icon: Icons.sentiment_satisfied_alt_outlined,
        color: palette.positive,
        label: 'Higher mood (7–10)',
      ),
      _LegendItem(
        icon: Icons.circle,
        color: palette.lavender,
        label: 'Recorded activity',
      ),
      _LegendItem(
        icon: Icons.circle_outlined,
        color: palette.secondaryText,
        label: 'No records',
      ),
    ],
  );

  Widget _selectedDayPanel(
    BuildContext context,
    LifeOsPalette palette,
    List<ActivityRecord> records,
    List<HabitOccurrence> occurrences,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(_selected),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (records.isEmpty && occurrences.isEmpty)
            Text(
              'No records for this date. A blank day means no data was recorded; it is not a negative result.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
            ),
          for (final ActivityRecord record in records)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_kindIcon(record.kind), color: palette.lavender),
              title: Text(_recordTitle(record)),
              subtitle: Text(_recordSummary(record)),
              trailing: TextButton(
                onPressed: () => context.go(_trackerPath(record.kind)),
                child: const Text('Open tracker'),
              ),
            ),
          for (final HabitOccurrence occurrence in occurrences)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.check_circle_outline_rounded,
                color: palette.rose,
              ),
              title: const Text('Habit occurrence'),
              subtitle: Text(occurrence.status),
              trailing: TextButton(
                onPressed: () => context.go('/habits'),
                child: const Text('Open habits'),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.recordCount,
    required this.moodAverage,
    required this.palette,
    required this.onTap,
    required this.hasActivity,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final int recordCount;
  final double? moodAverage;
  final LifeOsPalette palette;
  final VoidCallback onTap;
  final bool hasActivity;

  @override
  Widget build(BuildContext context) {
    final Color? moodColor = moodAverage == null
        ? null
        : moodAverage! <= 3
        ? palette.negative
        : moodAverage! <= 6
        ? palette.warning
        : palette.positive;
    final String label =
        '${DateFormat('EEEE, d MMMM').format(day)}'
        '${moodAverage == null ? '' : ', mood average ${moodAverage!.toStringAsFixed(1)} out of 10'}'
        '${hasActivity ? ', $recordCount recorded activit${recordCount == 1 ? 'y' : 'ies'}' : ', no records'}';
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: selected
              ? palette.rose.withValues(alpha: 0.18)
              : palette.elevated.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday
                      ? palette.rose
                      : selected
                      ? palette.rose
                      : palette.border.withValues(alpha: 0.4),
                  width: isToday || selected ? 1.5 : 0.7,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: moodColor?.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (moodAverage != null)
                    Icon(
                      moodAverage! <= 3
                          ? Icons.sentiment_dissatisfied_outlined
                          : moodAverage! <= 6
                          ? Icons.sentiment_neutral_outlined
                          : Icons.sentiment_satisfied_alt_outlined,
                      size: 13,
                      color: moodColor,
                    )
                  else
                    Icon(
                      hasActivity ? Icons.circle : Icons.circle_outlined,
                      size: 7,
                      color: hasActivity
                          ? palette.lavender
                          : palette.secondaryText.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _CalendarMessage extends StatelessWidget {
  const _CalendarMessage({
    required this.palette,
    required this.icon,
    required this.title,
    required this.message,
  });
  final LifeOsPalette palette;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: palette.rose, size: 30),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
          ),
        ],
      ),
    ),
  );
}

String _recordTitle(ActivityRecord record) {
  if (record.kind == 'mood' && record.value != null)
    return 'Mood · ${record.value}/10';
  return record.title.isEmpty ? _kindLabel(record.kind) : record.title;
}

String _recordSummary(ActivityRecord record) {
  final List<String> details = <String>[
    if (record.status != null && record.status!.isNotEmpty) record.status!,
    if (record.value != null && record.kind != 'mood')
      '${record.value} ${record.unit ?? ''}'.trim(),
    if (record.notes.trim().isNotEmpty) record.notes.trim(),
  ];
  return details.isEmpty ? _kindLabel(record.kind) : details.join(' · ');
}

String _kindLabel(String kind) => switch (kind) {
  'screentime' => 'Screen time',
  'gym' => 'Gym',
  'study' => 'Study',
  'sleep' => 'Sleep',
  'period' => 'Period',
  'money' => 'Money',
  'journal' => 'Journal',
  'tasks' => 'Tasks',
  _ => kind[0].toUpperCase() + kind.substring(1),
};

String _trackerPath(String kind) => switch (kind) {
  'screentime' => '/screen-time',
  _ => '/$kind',
};

IconData _kindIcon(String kind) => switch (kind) {
  'mood' => Icons.mood_rounded,
  'study' => Icons.auto_stories_outlined,
  'gym' => Icons.fitness_center_rounded,
  'sleep' => Icons.nightlight_round,
  'period' => Icons.water_drop_outlined,
  'money' => Icons.account_balance_wallet_outlined,
  'screentime' => Icons.devices_rounded,
  'journal' => Icons.menu_book_rounded,
  'tasks' => Icons.flag_outlined,
  _ => Icons.circle_outlined,
};

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
