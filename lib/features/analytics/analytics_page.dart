import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_providers.dart';
import '../../app/theme/life_os_palette.dart';
import '../../data/database/life_os_database.dart';
import '../../data/records/analytics_calculations.dart';
import '../../data/records/records_repository.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  AnalyticsPeriod _period = AnalyticsPeriod.week;
  DateTime _anchor = analyticsDay(DateTime.now());
  DateTime? _customStart;
  DateTime? _customEnd;
  AnalyticsMetric _trendMetric = AnalyticsMetric.mood;
  DateTime? _selectedBucket;

  AnalyticsWindow get _window {
    if (_period == AnalyticsPeriod.day) return AnalyticsWindow.day(_anchor);
    if (_period == AnalyticsPeriod.week) return AnalyticsWindow.week(_anchor);
    if (_period == AnalyticsPeriod.month) return AnalyticsWindow.month(_anchor);
    return AnalyticsWindow.custom(
      _customStart ?? _anchor,
      _customEnd ?? _anchor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final LifeOsPalette palette = LifeOsPalette.fromId(
      ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose',
    );
    final String currency =
        ref.watch(preferencesProvider).value?.currencyCode ?? 'INR';
    final RecordsRepository repo = ref.watch(recordsRepositoryProvider);
    final AnalyticsWindow window = _window;
    return StreamBuilder<List<ActivityRecord>>(
      stream: repo.watchCalendarRecords(
        window.comparisonStart,
        window.endExclusive,
      ),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<ActivityRecord>> records,
          ) => StreamBuilder<List<HabitOccurrence>>(
            stream: repo.watchHabitOccurrencesBetween(
              window.comparisonStart,
              window.endExclusive,
            ),
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<HabitOccurrence>> occurrences,
                ) => StreamBuilder<List<Habit>>(
                  stream: repo.watchAllHabits(),
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<List<Habit>> habits,
                      ) => StreamBuilder<List<ActivityRecord>>(
                        stream: repo.watchPeriodStarts(),
                        builder:
                            (
                              BuildContext context,
                              AsyncSnapshot<List<ActivityRecord>> starts,
                            ) => StreamBuilder<List<Goal>>(
                              stream: repo.watchGoals(),
                              builder:
                                  (
                                    BuildContext context,
                                    AsyncSnapshot<List<Goal>> goals,
                                  ) {
                                    if (records.hasError ||
                                        occurrences.hasError ||
                                        habits.hasError ||
                                        starts.hasError ||
                                        goals.hasError) {
                                      return const _Message(
                                        title: 'Analytics could not load',
                                        message:
                                            'Your local records are still saved. Try reopening this page.',
                                        icon: Icons.error_outline_rounded,
                                      );
                                    }
                                    if (!records.hasData ||
                                        !occurrences.hasData ||
                                        !habits.hasData ||
                                        !starts.hasData ||
                                        !goals.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return _buildReport(
                                      palette,
                                      currency,
                                      _window,
                                      records.data!,
                                      occurrences.data!,
                                      habits.data!,
                                      starts.data!,
                                      goals.data!,
                                    );
                                  },
                            ),
                      ),
                ),
          ),
    );
  }

  Widget _buildReport(
    LifeOsPalette palette,
    String currency,
    AnalyticsWindow window,
    List<ActivityRecord> records,
    List<HabitOccurrence> occurrences,
    List<Habit> habits,
    List<ActivityRecord> periodStarts,
    List<Goal> goals,
  ) {
    final AnalyticsSummary current = AnalyticsCalculations.summarize(
      start: window.start,
      endExclusive: window.endExclusive,
      records: records,
      occurrences: occurrences,
      habits: habits,
      allPeriodStarts: periodStarts,
    );
    final AnalyticsSummary previous = AnalyticsCalculations.summarize(
      start: window.comparisonStart,
      endExclusive: window.comparisonEndExclusive,
      records: records,
      occurrences: occurrences,
      habits: habits,
      allPeriodStarts: periodStarts,
    );
    final List<_Bucket> buckets = _makeBuckets(
      window,
      records,
      occurrences,
      habits,
      periodStarts,
    );
    final _Bucket? selected = buckets
        .where((_Bucket item) => item.start == _selectedBucket)
        .firstOrNull;
    final List<ActivityRecord> selectedRecords =
        selected == null
              ? <ActivityRecord>[]
              : records
                    .where(
                      (ActivityRecord row) =>
                          !row.recordDate.isBefore(selected.start) &&
                          row.recordDate.isBefore(selected.end),
                    )
                    .toList()
          ..sort(
            (ActivityRecord a, ActivityRecord b) =>
                a.recordDate.compareTo(b.recordDate),
          );
    final List<HabitOccurrence> selectedHabits = selected == null
        ? <HabitOccurrence>[]
        : occurrences
              .where(
                (HabitOccurrence row) =>
                    !row.occurrenceDate.isBefore(selected.start) &&
                    row.occurrenceDate.isBefore(selected.end),
              )
              .toList();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double padding = constraints.maxWidth < 500 ? 14 : 22;
        return ListView(
          padding: EdgeInsets.fromLTRB(padding, 12, padding, 30),
          children: <Widget>[
            _rangeControls(context),
            const SizedBox(height: 12),
            _comparisonCard(palette, window),
            const SizedBox(height: 18),
            Text(
              'Each area is tracked separately',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: palette.secondaryText),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final AnalyticsMetric metric in AnalyticsMetric.values)
                  SizedBox(
                    width: _cardWidth(constraints.maxWidth),
                    child: _MetricCard(
                      metric: metric,
                      current: current,
                      previous: previous,
                      currency: currency,
                      palette: palette,
                      records: records,
                    ),
                  ),
              ],
            ),
            if (current.numericHabitCheckIns > 0) ...<Widget>[
              const SizedBox(height: 14),
              _InfoPanel(
                palette: palette,
                title: 'Numerical habits',
                message:
                    current.numericHabitCheckIns.toString() +
                    ' recorded values. Units differ by habit, so values stay separate.',
              ),
            ],
            const SizedBox(height: 14),
            _trendCard(context, palette, buckets, selected, currency),
            const SizedBox(height: 14),
            _moodDistribution(context, palette, current),
            const SizedBox(height: 14),
            _expenseBreakdown(context, palette, current, currency),
            const SizedBox(height: 14),
            _goalSnapshot(context, palette, goals),
            const SizedBox(height: 14),
            _recordDetails(
              context,
              palette,
              selected,
              selectedRecords,
              selectedHabits,
              habits,
            ),
          ],
        );
      },
    );
  }

  Widget _rangeControls(BuildContext context) => Column(
    children: <Widget>[
      SegmentedButton<AnalyticsPeriod>(
        segments: const <ButtonSegment<AnalyticsPeriod>>[
          ButtonSegment(value: AnalyticsPeriod.day, label: Text('Day')),
          ButtonSegment(value: AnalyticsPeriod.week, label: Text('Week')),
          ButtonSegment(value: AnalyticsPeriod.month, label: Text('Month')),
          ButtonSegment(value: AnalyticsPeriod.custom, label: Text('Custom')),
        ],
        selected: <AnalyticsPeriod>{_period},
        showSelectedIcon: false,
        onSelectionChanged: (Set<AnalyticsPeriod> selection) async {
          if (selection.single == AnalyticsPeriod.custom) {
            await _chooseCustomRange(context);
          } else {
            setState(() {
              _period = selection.single;
              _anchor = analyticsDay(DateTime.now());
              _selectedBucket = null;
            });
          }
        },
      ),
      const SizedBox(height: 8),
      Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Previous period',
            onPressed: () => _movePeriod(-1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              _rangeLabel(_window),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: 'Next period',
            onPressed: () => _movePeriod(1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          TextButton(
            onPressed: () => setState(() {
              _anchor = analyticsDay(DateTime.now());
              if (_period == AnalyticsPeriod.custom) {
                _customStart = _anchor;
                _customEnd = _anchor;
              }
              _selectedBucket = null;
            }),
            child: const Text('Today'),
          ),
        ],
      ),
    ],
  );

  Widget _comparisonCard(LifeOsPalette palette, AnalyticsWindow window) {
    final bool monthToDate =
        _period == AnalyticsPeriod.month &&
        window.start.year == DateTime.now().year &&
        window.start.month == DateTime.now().month;
    final String explanation = monthToDate
        ? 'Month to date compared with the same elapsed dates in the previous month.'
        : _period == AnalyticsPeriod.month
        ? 'Full calendar month compared with the previous calendar month; months can contain different numbers of days.'
        : 'Compared with the immediately preceding window of the same duration.';
    return _InfoPanel(
      palette: palette,
      title: 'Period comparison',
      message:
          _dateRange(window.start, window.endExclusive) +
          ' vs ' +
          _dateRange(window.comparisonStart, window.comparisonEndExclusive) +
          '. ' +
          explanation +
          ' Changes describe records, not an overall score.',
      icon: Icons.compare_arrows_rounded,
    );
  }

  Widget _trendCard(
    BuildContext context,
    LifeOsPalette palette,
    List<_Bucket> buckets,
    _Bucket? selected,
    String currency,
  ) {
    final bool hasValues = buckets.any(
      (_Bucket bucket) => bucket.summary.valueFor(_trendMetric) != null,
    );
    return _Panel(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Trend over time',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              DropdownButton<AnalyticsMetric>(
                value: _trendMetric,
                underline: const SizedBox.shrink(),
                items: AnalyticsMetric.values
                    .map(
                      (AnalyticsMetric metric) => DropdownMenuItem(
                        value: metric,
                        child: Text(metric.label),
                      ),
                    )
                    .toList(),
                onChanged: (AnalyticsMetric? value) => setState(() {
                  _trendMetric = value ?? _trendMetric;
                  _selectedBucket = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasValues)
            Text(
              'No ' +
                  _trendMetric.label.toLowerCase() +
                  ' data in this period.',
              style: TextStyle(color: palette.secondaryText),
            )
          else ...<Widget>[
            SizedBox(
              height: 184,
              child: _TrendChart(
                buckets: buckets,
                metric: _trendMetric,
                selectedStart: selected?.start,
                currency: currency,
                palette: palette,
                onSelect: (_Bucket item) =>
                    setState(() => _selectedBucket = item.start),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose a bar to inspect its interval. Blank bars mean no data was recorded.',
              style: TextStyle(color: palette.secondaryText, fontSize: 12),
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Accessible data table'),
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Measure')),
                      DataColumn(label: Text('Records')),
                    ],
                    rows: buckets.map((_Bucket bucket) {
                      final num? value = bucket.summary.valueFor(_trendMetric);
                      return DataRow(
                        selected: bucket.start == selected?.start,
                        onSelectChanged: (_) =>
                            setState(() => _selectedBucket = bucket.start),
                        cells: <DataCell>[
                          DataCell(Text(bucket.label)),
                          DataCell(
                            Text(_formatMetric(_trendMetric, value, currency)),
                          ),
                          DataCell(Text(bucket.recordCount.toString())),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _moodDistribution(
    BuildContext context,
    LifeOsPalette palette,
    AnalyticsSummary summary,
  ) {
    final int total = summary.moodDistribution.fold<int>(
      0,
      (int sum, int n) => sum + n,
    );
    final int maximum = summary.moodDistribution.reduce(math.max);
    return _Panel(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Mood distribution',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          Text(
            total == 0
                ? 'No mood ratings recorded in this period.'
                : total.toString() +
                      ' ratings recorded. Descriptive history only; no diagnosis or claim about causes.',
            style: TextStyle(color: palette.secondaryText),
          ),
          if (total > 0) ...<Widget>[
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  for (int index = 0; index < 10; index++)
                    Expanded(
                      child: Semantics(
                        label:
                            'Mood rating ' +
                            (index + 1).toString() +
                            ': ' +
                            summary.moodDistribution[index].toString() +
                            ' records',
                        child: Tooltip(
                          message:
                              'Rating ' +
                              (index + 1).toString() +
                              ': ' +
                              summary.moodDistribution[index].toString(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  summary.moodDistribution[index].toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  height: math.max(
                                    3,
                                    48 *
                                        summary.moodDistribution[index] /
                                        math.max(1, maximum),
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.lavender,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  (index + 1).toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _expenseBreakdown(
    BuildContext context,
    LifeOsPalette palette,
    AnalyticsSummary summary,
    String currency,
  ) {
    final List<MapEntry<String, int>> categories =
        summary.moneyCategories.entries.toList()..sort(
          (MapEntry<String, int> a, MapEntry<String, int> b) =>
              b.value.compareTo(a.value),
        );
    return _Panel(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Expense categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          Text(
            summary.expenseMinor == null
                ? 'No expenses recorded in this period.'
                : 'Exact totals by saved transaction category. Older records without a category are grouped as Uncategorized.',
            style: TextStyle(color: palette.secondaryText),
          ),
          for (final MapEntry<String, int> entry in categories.take(8))
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(entry.key),
              trailing: Text(_money(entry.value, currency)),
            ),
        ],
      ),
    );
  }

  Widget _goalSnapshot(
    BuildContext context,
    LifeOsPalette palette,
    List<Goal> goals,
  ) => _Panel(
    palette: palette,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Current goal progress',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5),
        Text(
          'Current snapshot only. Dated goal-progress history is not stored, so past comparisons are unavailable.',
          style: TextStyle(color: palette.secondaryText),
        ),
        if (goals.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text('No active goals recorded.'),
          ),
        for (final Goal goal in goals)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(goal.name),
            subtitle: Text(
              goal.target == null
                  ? goal.progress.toString() +
                        ' ' +
                        goal.unit +
                        ' · ' +
                        goal.status
                  : goal.progress.toString() +
                        ' of ' +
                        goal.target.toString() +
                        ' ' +
                        goal.unit +
                        ' · ' +
                        goal.status,
            ),
            trailing: const Icon(Icons.flag_outlined),
            onTap: () => context.go('/tasks'),
          ),
      ],
    ),
  );

  Widget _recordDetails(
    BuildContext context,
    LifeOsPalette palette,
    _Bucket? selected,
    List<ActivityRecord> records,
    List<HabitOccurrence> occurrences,
    List<Habit> habits,
  ) => _Panel(
    palette: palette,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Record details', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 5),
        Text(
          selected == null
              ? 'Select a chart bar to see its records.'
              : selected.label,
          style: TextStyle(color: palette.secondaryText),
        ),
        if (selected != null && records.isEmpty && occurrences.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('No records in this interval.'),
          ),
        for (final ActivityRecord row in records)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_kindIcon(row.kind), color: palette.lavender),
            title: Text(_recordTitle(row)),
            subtitle: Text(
              DateFormat('dd/MM/yyyy · h:mm a').format(row.recordDate) +
                  ' · ' +
                  _recordSubtitle(row),
            ),
            onTap: () => context.go(_trackerRoute(row.kind)),
          ),
        for (final HabitOccurrence row in occurrences)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.check_circle_outline, color: palette.rose),
            title: Text(
              habits
                      .where((Habit habit) => habit.id == row.habitId)
                      .firstOrNull
                      ?.name ??
                  'Habit',
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(row.occurrenceDate) +
                  ' · ' +
                  row.status,
            ),
            onTap: () => context.go('/habits'),
          ),
      ],
    ),
  );

  Future<void> _chooseCustomRange(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: _customStart ?? _anchor,
        end: _customEnd ?? _anchor,
      ),
      helpText: 'Choose an analytics date range',
    );
    if (result == null) {
      if (_period == AnalyticsPeriod.custom) {
        setState(() => _period = AnalyticsPeriod.week);
      }
      return;
    }
    setState(() {
      _period = AnalyticsPeriod.custom;
      _customStart = analyticsDay(result.start);
      _customEnd = analyticsDay(result.end);
      _selectedBucket = null;
    });
  }

  void _movePeriod(int delta) {
    setState(() {
      if (_period == AnalyticsPeriod.day) {
        _anchor = _anchor.add(Duration(days: delta));
      } else if (_period == AnalyticsPeriod.week) {
        _anchor = _anchor.add(Duration(days: 7 * delta));
      } else if (_period == AnalyticsPeriod.month) {
        _anchor = DateTime(_anchor.year, _anchor.month + delta, 1);
      } else {
        final DateTime start = _customStart ?? _anchor;
        final DateTime end = _customEnd ?? _anchor;
        final int days = end.difference(start).inDays + 1;
        _customStart = start.add(Duration(days: days * delta));
        _customEnd = end.add(Duration(days: days * delta));
      }
      _selectedBucket = null;
    });
  }

  List<_Bucket> _makeBuckets(
    AnalyticsWindow window,
    List<ActivityRecord> records,
    List<HabitOccurrence> occurrences,
    List<Habit> habits,
    List<ActivityRecord> allStarts,
  ) {
    final int days = window.endExclusive.difference(window.start).inDays;
    final int stride = days > 31 ? 7 : 1;
    return List<_Bucket>.generate((days / stride).ceil(), (int index) {
      final DateTime start = window.start.add(Duration(days: index * stride));
      final DateTime candidate = start.add(Duration(days: stride));
      final DateTime end = candidate.isAfter(window.endExclusive)
          ? window.endExclusive
          : candidate;
      final AnalyticsSummary summary = AnalyticsCalculations.summarize(
        start: start,
        endExclusive: end,
        records: records,
        occurrences: occurrences,
        habits: habits,
        allPeriodStarts: allStarts,
      );
      final int count =
          records
              .where(
                (ActivityRecord row) =>
                    !row.recordDate.isBefore(start) &&
                    row.recordDate.isBefore(end),
              )
              .length +
          occurrences
              .where(
                (HabitOccurrence row) =>
                    !row.occurrenceDate.isBefore(start) &&
                    row.occurrenceDate.isBefore(end),
              )
              .length;
      final String label = stride == 1
          ? DateFormat('d MMM').format(start)
          : DateFormat('d MMM').format(start) +
                '–' +
                DateFormat(
                  'd MMM',
                ).format(end.subtract(const Duration(days: 1)));
      return _Bucket(
        start: start,
        end: end,
        label: label,
        summary: summary,
        recordCount: count,
      );
    });
  }

  double _cardWidth(double width) {
    if (width < 520) return width;
    if (width < 900) return (width - 12) / 2;
    if (width < 1300) return (width - 24) / 3;
    return (width - 36) / 4;
  }

  String _rangeLabel(AnalyticsWindow window) {
    if (_period == AnalyticsPeriod.day) {
      return DateFormat('EEEE, d MMM yyyy').format(window.start);
    }
    if (_period == AnalyticsPeriod.month) {
      return DateFormat('MMMM yyyy').format(window.start);
    }
    return _dateRange(window.start, window.endExclusive);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.current,
    required this.previous,
    required this.currency,
    required this.palette,
    required this.records,
  });
  final AnalyticsMetric metric;
  final AnalyticsSummary current;
  final AnalyticsSummary previous;
  final String currency;
  final LifeOsPalette palette;
  final List<ActivityRecord> records;

  @override
  Widget build(BuildContext context) {
    final num? value = current.valueFor(metric);
    final num? oldValue = previous.valueFor(metric);
    final String comparison = value == null || oldValue == null
        ? 'Prior period: No data'
        : 'Prior: ' +
              _formatMetric(metric, oldValue, currency) +
              ' · Change ' +
              _formatDelta(metric, value - oldValue, currency);
    return _Panel(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  metric.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.secondaryText,
                  ),
                ),
              ),
              Icon(_metricIcon(metric), color: palette.rose, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatMetric(metric, value, currency),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            _metricDetail(metric, current, records, currency),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
          ),
          const SizedBox(height: 9),
          Divider(color: palette.border, height: 1),
          const SizedBox(height: 7),
          Text(
            comparison,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: palette.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _Bucket {
  const _Bucket({
    required this.start,
    required this.end,
    required this.label,
    required this.summary,
    required this.recordCount,
  });
  final DateTime start;
  final DateTime end;
  final String label;
  final AnalyticsSummary summary;
  final int recordCount;
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.buckets,
    required this.metric,
    required this.selectedStart,
    required this.currency,
    required this.palette,
    required this.onSelect,
  });
  final List<_Bucket> buckets;
  final AnalyticsMetric metric;
  final DateTime? selectedStart;
  final String currency;
  final LifeOsPalette palette;
  final ValueChanged<_Bucket> onSelect;

  @override
  Widget build(BuildContext context) {
    final double maxValue = buckets
        .map(
          (_Bucket bucket) =>
              bucket.summary.valueFor(metric)?.abs().toDouble() ?? 0,
        )
        .fold<double>(0, math.max);
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final _Bucket bucket in buckets)
          Expanded(
            child: Semantics(
              button: true,
              selected: bucket.start == selectedStart,
              label:
                  bucket.label +
                  ', ' +
                  metric.label +
                  ': ' +
                  _formatMetric(
                    metric,
                    bucket.summary.valueFor(metric),
                    currency,
                  ) +
                  ', ' +
                  bucket.recordCount.toString() +
                  ' records',
              child: Tooltip(
                message:
                    bucket.label +
                    ': ' +
                    _formatMetric(
                      metric,
                      bucket.summary.valueFor(metric),
                      currency,
                    ) +
                    ' · ' +
                    bucket.recordCount.toString() +
                    ' records',
                child: InkWell(
                  onTap: () => onSelect(bucket),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: reduceMotion
                                  ? Duration.zero
                                  : const Duration(milliseconds: 180),
                              width: double.infinity,
                              height: _barHeight(bucket, metric, maxValue),
                              decoration: BoxDecoration(
                                color: bucket.start == selectedStart
                                    ? palette.rose
                                    : palette.lavender,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bucket.label.split(' ').first,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: palette.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _barHeight(_Bucket bucket, AnalyticsMetric metric, double maximum) {
    final num? value = bucket.summary.valueFor(metric);
    if (value == null) return 0;
    return math.max(3, 130 * value.abs().toDouble() / math.max(maximum, 1));
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.palette, required this.child});
  final LifeOsPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: palette.card,
      border: Border.all(color: palette.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.palette,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });
  final LifeOsPalette palette;
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => _Panel(
    palette: palette,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: palette.lavender),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 5),
              Text(message, style: TextStyle(color: palette.secondaryText)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    required this.message,
    required this.icon,
  });
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 32),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

String _dateRange(DateTime start, DateTime end) =>
    DateFormat('d MMM').format(start) +
    '–' +
    DateFormat('d MMM yyyy').format(end.subtract(const Duration(days: 1)));

String _formatMetric(AnalyticsMetric metric, num? value, String currency) {
  if (value == null) return 'No data';
  if (metric == AnalyticsMetric.habits) return value.toStringAsFixed(1) + '%';
  if (metric == AnalyticsMetric.study) return _duration((value * 60).round());
  if (metric == AnalyticsMetric.gym) {
    return value.toInt().toString() + (value.toInt() == 1 ? ' day' : ' days');
  }
  if (metric == AnalyticsMetric.mood) {
    return value.toStringAsFixed(1) + ' / 10';
  }
  if (metric == AnalyticsMetric.sleep) {
    return _duration((value * 60).round());
  }
  if (metric == AnalyticsMetric.spending) {
    return _money((value * 100).round(), currency);
  }
  if (metric == AnalyticsMetric.screenTime) return _duration(value.toInt());
  if (metric == AnalyticsMetric.journal) {
    return value.toInt().toString() + ' entries';
  }
  if (metric == AnalyticsMetric.period) {
    return value.toInt().toString() + ' starts';
  }
  return value.toInt().toString();
}

String _formatDelta(AnalyticsMetric metric, num delta, String currency) {
  final String sign = delta > 0 ? '+' : '';
  if (metric == AnalyticsMetric.spending) {
    return sign + _money((delta * 100).round(), currency);
  }
  if (metric == AnalyticsMetric.study || metric == AnalyticsMetric.sleep) {
    return sign + _duration((delta * 60).round());
  }
  if (metric == AnalyticsMetric.screenTime) {
    return sign + _duration(delta.round());
  }
  final int decimals =
      metric == AnalyticsMetric.habits || metric == AnalyticsMetric.mood
      ? 1
      : 0;
  return sign + delta.toStringAsFixed(decimals);
}

String _metricDetail(
  AnalyticsMetric metric,
  AnalyticsSummary summary,
  List<ActivityRecord> records,
  String currency,
) {
  if (metric == AnalyticsMetric.habits) {
    return summary.habitEligible == 0
        ? 'No eligible scheduled outcomes recorded.'
        : summary.habitCompleted.toString() +
              ' completed of ' +
              summary.habitEligible.toString() +
              ' eligible records. Skips and missing days are excluded.';
  }
  if (metric == AnalyticsMetric.study) {
    return summary.studyMinutes == null
        ? 'No study sessions recorded.'
        : records
                  .where((ActivityRecord row) => row.kind == 'study')
                  .length
                  .toString() +
              ' sessions · ' +
              summary.studyMinutes.toString() +
              ' minutes.';
  }
  if (metric == AnalyticsMetric.gym) {
    return summary.gymDays == null
        ? 'No gym records recorded.'
        : 'Attendance days. A percentage needs a configured schedule.';
  }
  if (metric == AnalyticsMetric.mood) {
    return summary.moodAverage == null
        ? 'No mood ratings recorded.'
        : 'Recorded check-ins · descriptive only.';
  }
  if (metric == AnalyticsMetric.sleep) {
    return summary.sleepMinutes == null
        ? 'No sleep durations recorded.'
        : summary.sleepQualityAverage == null
        ? 'Average duration. No quality ratings recorded.'
        : 'Average duration · quality ' +
              summary.sleepQualityAverage!.toStringAsFixed(1) +
              ' / 5.';
  }
  if (metric == AnalyticsMetric.spending) {
    return summary.expenseMinor == null
        ? 'No money records recorded.'
        : 'Income ' +
              _money(summary.incomeMinor ?? 0, currency) +
              ' · exact minor-unit totals.';
  }
  if (metric == AnalyticsMetric.screenTime) {
    return summary.screenTimeMinutes == null
        ? 'No screen-time records recorded.'
        : 'Saved records included as recorded.';
  }
  if (metric == AnalyticsMetric.journal) {
    return summary.journalEntries == null
        ? 'No journal entries recorded.'
        : summary.journalDays.toString() +
              ' days with entries. Entry contents stay out of analytics.';
  }
  if (metric == AnalyticsMetric.tasks) {
    return summary.tasksCompleted == null
        ? 'No task statuses recorded.'
        : summary.tasksCompleted.toString() +
              ' completed of ' +
              summary.tasksPlanned.toString() +
              ' task records. Current statuses are shown.';
  }
  return summary.periodStarts == null
      ? 'No period starts recorded.'
      : summary.averageCycleDays == null
      ? summary.periodStarts.toString() +
            ' starts · another recorded start is needed for a cycle estimate.'
      : summary.periodStarts.toString() +
            ' starts · average recorded interval ' +
            summary.averageCycleDays.toString() +
            ' days (estimate).';
}

String _duration(int minutes) {
  final int hours = minutes ~/ 60;
  final int rest = minutes % 60;
  if (hours == 0) return rest.toString() + ' min';
  if (rest == 0) return hours.toString() + 'h';
  return hours.toString() + 'h ' + rest.toString() + 'm';
}

String _money(int minor, String currency) => NumberFormat.currency(
  name: currency,
  symbol: currency == 'INR' ? '₹' : currency + ' ',
).format(minor / 100);

String _recordTitle(ActivityRecord row) {
  if (row.kind == 'journal') return 'Journal entry';
  if (row.kind == 'mood' && row.value != null) {
    return 'Mood ' + row.value.toString() + '/10';
  }
  return row.title.isEmpty ? _kindLabel(row.kind) : row.title;
}

String _recordSubtitle(ActivityRecord row) {
  if (row.kind == 'money' && row.value != null) {
    return (row.status ?? 'Transaction') + ' · ' + _money(row.value!, 'INR');
  }
  final List<String> parts = <String>[
    if (row.status != null && row.status!.isNotEmpty) row.status!,
    if (row.value != null && row.kind != 'mood')
      row.value.toString() + ' ' + (row.unit ?? ''),
  ];
  return parts.isEmpty ? _kindLabel(row.kind) : parts.join(' · ');
}

String _trackerRoute(String kind) =>
    kind == 'screentime' ? '/screen-time' : '/' + kind;

String _kindLabel(String kind) => switch (kind) {
  'screentime' => 'Screen time',
  'gym' => 'Gym',
  'study' => 'Study',
  'sleep' => 'Sleep',
  'period' => 'Period',
  'money' => 'Money',
  'journal' => 'Journal',
  'tasks' => 'Tasks & Goals',
  'mood' => 'Mood',
  _ => kind,
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

IconData _metricIcon(AnalyticsMetric metric) => switch (metric) {
  AnalyticsMetric.habits => Icons.check_circle_outline_rounded,
  AnalyticsMetric.study => Icons.auto_stories_outlined,
  AnalyticsMetric.gym => Icons.fitness_center_rounded,
  AnalyticsMetric.mood => Icons.mood_rounded,
  AnalyticsMetric.sleep => Icons.nightlight_round,
  AnalyticsMetric.spending => Icons.account_balance_wallet_outlined,
  AnalyticsMetric.screenTime => Icons.devices_rounded,
  AnalyticsMetric.journal => Icons.menu_book_rounded,
  AnalyticsMetric.tasks => Icons.flag_outlined,
  AnalyticsMetric.period => Icons.water_drop_outlined,
};
