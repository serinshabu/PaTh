import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_providers.dart';
import '../../app/theme/life_os_palette.dart';
import '../../data/database/life_os_database.dart';
import '../../data/records/tracking_calculations.dart';
import '../../data/sync/sync_runtime.dart';
import 'quick_add_sheet.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LifeOsPalette palette = LifeOsPalette.fromId(
      ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose',
    );
    final AsyncValue<List<DashboardCardSetting>> cards = ref.watch(
      dashboardCardsProvider,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontalPadding = constraints.maxWidth < 600 ? 16 : 28;
        final double contentWidth = math.min(
          math.max(0, constraints.maxWidth - (horizontalPadding * 2)),
          1440,
        );
        final int columns = contentWidth >= 1320
            ? 4
            : contentWidth >= 760
            ? 2
            : 1;
        const double gap = 16;
        final double cardWidth =
            (contentWidth - (gap * (columns - 1))) / columns;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: horizontalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _WelcomePanel(palette: palette),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Your day, at a glance',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/settings'),
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text('Arrange'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  cards.when(
                    data: (List<DashboardCardSetting> rows) {
                      final List<DashboardCardSetting> visible = rows
                          .where((DashboardCardSetting row) => row.visible)
                          .toList();
                      if (visible.isEmpty) {
                        return _NoVisibleCards(palette: palette);
                      }
                      final List<DashboardCardSetting> primary = visible
                          .take(4)
                          .toList();
                      final List<DashboardCardSetting> secondary = visible
                          .skip(4)
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _DashboardCardSection(
                            title: 'Today',
                            cards: primary,
                            columns: columns,
                            cardWidth: cardWidth,
                            gap: gap,
                            palette: palette,
                          ),
                          if (secondary.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 24),
                            Text(
                              'More from your trackers',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            _DashboardCardSection(
                              cards: secondary,
                              columns: columns,
                              cardWidth: cardWidth,
                              gap: gap,
                              palette: palette,
                            ),
                          ],
                        ],
                      );
                    },
                    error: (Object error, StackTrace stack) => _ErrorCard(
                      message: 'Dashboard preferences could not be loaded.',
                      palette: palette,
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _PrivacyNote(palette: palette),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardCardSection extends StatelessWidget {
  const _DashboardCardSection({
    this.title,
    required this.cards,
    required this.columns,
    required this.cardWidth,
    required this.gap,
    required this.palette,
  });

  final String? title;
  final List<DashboardCardSetting> cards;
  final int columns;
  final double cardWidth;
  final double gap;
  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null) ...<Widget>[
          Text(title!, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final DashboardCardSetting setting in cards)
              SizedBox(
                width: _itemWidth(cardWidth, columns, setting.desktopSpan, gap),
                height: 190,
                child: _DashboardCard(
                  setting: setting,
                  compact: setting.position < 4,
                  palette: palette,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

double _itemWidth(double width, int columns, int span, double gap) {
  if (columns == 1) return width;
  final int safeSpan = span.clamp(1, columns).toInt();
  return (width * safeSpan) + (gap * (safeSpan - 1));
}

class _WelcomePanel extends ConsumerWidget {
  const _WelcomePanel({required this.palette});

  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 620;
        final SyncStatus sync = ref.watch(syncStatusProvider);
        final TextTheme textTheme = Theme.of(context).textTheme;
        final Widget actions = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: () => context.go('/daily-review'),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Daily review'),
            ),
          ],
        );
        final Widget heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: palette.rose.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'YOUR aERSONAi SPACE',
                style: textTheme.labelSmall?.copyWith(
                  color: palette.highlight,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Make room for what matters.',
              style: textTheme.headlineSmall?.copyWith(
                color: palette.text,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'A calm place to plan, reflect, and notice your progress—one day at a time.',
              style: textTheme.bodyMedium?.copyWith(
                color: palette.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                Icon(
                  Icons.calendar_today_rounded,
                  size: 15,
                  color: palette.lavender,
                ),
                Text(
                  DateFormat('EEEE, d MMMM').format(DateTime.now()),
                  style: textTheme.labelLarge?.copyWith(
                    color: palette.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (MediaQuery.sizeOf(context).width < 1000) ...<Widget>[
              const SizedBox(height: 12),
              _SyncDetailChip(status: sync, palette: palette),
            ],
          ],
        );

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[palette.elevated, palette.card],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: palette.border),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: compact ? -65 : 52,
                  top: -94,
                  child: ExcludeSemantics(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: palette.rose.withValues(alpha: 0.09),
                          width: 26,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(compact ? 20 : 28),
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            heading,
                            const SizedBox(height: 20),
                            actions,
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            Expanded(child: heading),
                            const SizedBox(width: 24),
                            actions,
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SyncDetailChip extends StatelessWidget {
  const _SyncDetailChip({required this.status, required this.palette});

  final SyncStatus status;
  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context) {
    final (String label, IconData icon, Color tint) = switch (status.phase) {
      SyncPhase.notConfigured => (
        'Local only',
        Icons.cloud_off_outlined,
        palette.secondaryText,
      ),
      SyncPhase.synced => (
        status.lastSyncedAt == null
            ? 'Synced'
            : 'Synced ${_relativeTime(status.lastSyncedAt!)}',
        Icons.cloud_done_outlined,
        palette.positive,
      ),
      SyncPhase.syncing => (
        'Syncing changes',
        Icons.sync_rounded,
        palette.lavender,
      ),
      SyncPhase.offline => (
        'Offline · changes saved here',
        Icons.cloud_off_outlined,
        palette.warning,
      ),
      SyncPhase.pending => (
        '${status.pending} change${status.pending == 1 ? '' : 's'} waiting',
        Icons.cloud_upload_outlined,
        palette.warning,
      ),
      SyncPhase.error => (
        'Sync needs attention',
        Icons.error_outline_rounded,
        palette.negative,
      ),
      SyncPhase.conflict => (
        'Review ${status.conflicts} conflict${status.conflicts == 1 ? '' : 's'}',
        Icons.sync_problem_rounded,
        palette.negative,
      ),
    };
    return Semantics(
      label: 'Sync status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: palette.card,
          border: Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: tint),
            const SizedBox(width: 7),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

String _relativeTime(DateTime time) {
  final Duration age = DateTime.now().difference(time.toLocal());
  if (age.inSeconds < 60) return 'just now';
  if (age.inMinutes < 60) return '${age.inMinutes}m ago';
  if (age.inHours < 24) return '${age.inHours}h ago';
  return DateFormat('d MMM').format(time.toLocal());
}

class _DashboardCard extends ConsumerWidget {
  const _DashboardCard({
    required this.setting,
    required this.compact,
    required this.palette,
  });

  final DashboardCardSetting setting;
  final bool compact;
  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _CardContent content = _cardContent(setting.cardId);
    final _CardMetric? metric = _metricFor(ref, setting.cardId);
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(content.path),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: content.tint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(content.icon, size: 18, color: content.tint),
                  ),
                  const Spacer(),
                  if (setting.cardId == 'habits')
                    IconButton(
                      tooltip: "Open today's habit checklist",
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showHabitChecklist(context, ref),
                      icon: Icon(Icons.checklist_rounded, color: palette.rose),
                    ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 16,
                    color: palette.secondaryText,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                content.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                metric?.headline ?? 'Loading your records…',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (metric?.progress != null) ...<Widget>[
                const SizedBox(height: 7),
                Semantics(
                  label: '${content.title} progress',
                  value: '${(metric!.progress! * 100).round()} percent',
                  child: LinearProgressIndicator(
                    value: metric.progress,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
              if (!compact || metric?.detail.isNotEmpty == true) ...<Widget>[
                const Spacer(),
                Text(
                  metric?.detail ?? content.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _CardContent _cardContent(String cardId) {
    switch (cardId) {
      case 'habits':
        return _CardContent(
          'Habits',
          'No habits yet',
          'Create a routine when you are ready.',
          '/habits',
          Icons.check_circle_outline_rounded,
          palette.rose,
        );
      case 'study':
        return _CardContent(
          'Study',
          'No sessions yet',
          'Study time will appear here.',
          '/study',
          Icons.auto_stories_outlined,
          palette.lavender,
        );
      case 'tasks':
        return _CardContent(
          'Tasks',
          'No tasks planned',
          'Your priorities will appear here.',
          '/tasks',
          Icons.flag_outlined,
          palette.warning,
        );
      case 'mood':
        return _CardContent(
          'Mood',
          'Not recorded',
          'Mood check-ins stay private.',
          '/mood',
          Icons.mood_rounded,
          palette.positive,
        );
      case 'schedule':
        return _CardContent(
          "Today's schedule",
          'Nothing scheduled',
          'Deadlines and plans will appear here.',
          '/tasks',
          Icons.schedule_rounded,
          palette.lavender,
        );
      case 'wellness':
        return _CardContent(
          'Mood & sleep',
          'No entries yet',
          'Wellness patterns grow from your records.',
          '/sleep',
          Icons.nightlight_round,
          palette.rose,
        );
      case 'gym-study':
        return _CardContent(
          'Gym & study',
          'No activity yet',
          'See attendance and learning together.',
          '/gym',
          Icons.fitness_center_rounded,
          palette.positive,
        );
      case 'money':
        return _CardContent(
          'Money',
          'No transactions yet',
          'Spending and budgets stay on your terms.',
          '/money',
          Icons.account_balance_wallet_outlined,
          palette.warning,
        );
      case 'screen-time':
        return _CardContent(
          'Screen time',
          'No usage logged',
          'Manual tracking will always be available.',
          '/screen-time',
          Icons.devices_rounded,
          palette.lavender,
        );
      case 'journal':
        return _CardContent(
          'Journal',
          'No entry yet',
          'Your reflections are yours alone.',
          '/journal',
          Icons.menu_book_rounded,
          palette.rose,
        );
      case 'calendar':
        return _CardContent(
          'Calendar',
          'No activity yet',
          'Your history remains available over time.',
          '/calendar',
          Icons.calendar_month_rounded,
          palette.lavender,
        );
      default:
        return _CardContent(
          'Life area',
          'No data yet',
          'Your records will appear here.',
          '/dashboard',
          Icons.circle_outlined,
          palette.rose,
        );
    }
  }

  _CardMetric? _metricFor(WidgetRef ref, String cardId) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    List<ActivityRecord>? records(String kind) =>
        ref.watch(activityRecordsProvider(kind)).value;
    List<ActivityRecord> forDay(List<ActivityRecord> rows, DateTime day) => rows
        .where((ActivityRecord row) => _sameDay(row.recordDate, day))
        .toList();
    String duration(int minutes) {
      if (minutes <= 0) return '0 min';
      final int hours = minutes ~/ 60;
      final int remainder = minutes % 60;
      return hours == 0 ? '$remainder min' : '${hours}h ${remainder}m';
    }

    switch (cardId) {
      case 'habits':
        final List<Habit>? habits = ref.watch(activeHabitsProvider).value;
        final List<HabitOccurrence>? occurrences = ref
            .watch(todayHabitOccurrencesProvider(today))
            .value;
        if (habits == null || occurrences == null) return null;
        final List<Habit> scheduled = habits.where((Habit habit) {
          final Set<int> days = habit.scheduleDays
              .split(',')
              .map(int.tryParse)
              .whereType<int>()
              .toSet();
          return !DateTime(
                habit.startDate.year,
                habit.startDate.month,
                habit.startDate.day,
              ).isAfter(today) &&
              days.contains(today.weekday);
        }).toList();
        final Set<String> eligibleIds = scheduled
            .map((Habit h) => h.id)
            .toSet();
        final List<HabitOccurrence> recorded = occurrences
            .where(
              (HabitOccurrence row) =>
                  eligibleIds.contains(row.habitId) &&
                  (row.status == 'Completed' || row.status == 'Missed'),
            )
            .toList();
        final int completed = recorded
            .where((HabitOccurrence row) => row.status == 'Completed')
            .length;
        final double? percent = TrackingCalculations.habitCompletionPercent(
          recorded,
        );
        return _CardMetric(
          headline: percent == null
              ? 'No data'
              : '$completed / ${recorded.length} recorded · ${percent.round()}%',
          detail: scheduled.isEmpty
              ? 'No habits scheduled today.'
              : percent == null
              ? '${scheduled.length} scheduled · not yet recorded'
              : '${scheduled.length} scheduled occurrence${scheduled.length == 1 ? '' : 's'}',
          progress: percent == null ? null : percent / 100,
        );
      case 'study':
        final List<ActivityRecord>? rows = records('study');
        if (rows == null) return null;
        final List<ActivityRecord> todayRows = forDay(rows, today);
        final int minutes = TrackingCalculations.studyMinutes(todayRows);
        return _CardMetric(
          headline: todayRows.isEmpty ? 'No data' : duration(minutes),
          detail: todayRows.isEmpty
              ? 'No study sessions recorded today.'
              : '${todayRows.length} session${todayRows.length == 1 ? '' : 's'} today',
        );
      case 'tasks':
        final List<ActivityRecord>? rows = records('tasks');
        if (rows == null) return null;
        final List<ActivityRecord> dayRows = forDay(rows, today);
        final int completed = dayRows
            .where((ActivityRecord row) => row.status == 'Completed')
            .length;
        return _CardMetric(
          headline: dayRows.isEmpty
              ? 'No data'
              : '$completed / ${dayRows.length} complete',
          detail: dayRows.isEmpty
              ? 'No tasks recorded for today.'
              : '${dayRows.length - completed} still open',
          progress: dayRows.isEmpty ? null : completed / dayRows.length,
        );
      case 'mood':
        final List<ActivityRecord>? rows = records('mood');
        if (rows == null) return null;
        final List<ActivityRecord> dayRows = forDay(rows, today)
          ..sort(
            (ActivityRecord a, ActivityRecord b) =>
                b.recordDate.compareTo(a.recordDate),
          );
        if (dayRows.isEmpty) {
          return const _CardMetric(
            headline: 'No check-in',
            detail: 'Mood is optional; no entry recorded today.',
          );
        }
        final int? latest = dayRows.first.value;
        return _CardMetric(
          headline: latest == null ? 'Recorded' : '$latest / 10',
          detail:
              '${dayRows.length} mood check-in${dayRows.length == 1 ? '' : 's'} today',
        );
      case 'schedule':
        final List<ActivityRecord>? rows = records('tasks');
        if (rows == null) return null;
        final List<ActivityRecord> upcoming =
            rows
                .where(
                  (ActivityRecord row) =>
                      !row.recordDate.isBefore(today) &&
                      row.status != 'Completed',
                )
                .toList()
              ..sort(
                (ActivityRecord a, ActivityRecord b) =>
                    a.recordDate.compareTo(b.recordDate),
              );
        if (upcoming.isEmpty) {
          return const _CardMetric(
            headline: 'Nothing scheduled',
            detail: 'No upcoming open tasks recorded.',
          );
        }
        final ActivityRecord next = upcoming.first;
        return _CardMetric(
          headline: next.title,
          detail: _sameDay(next.recordDate, today)
              ? 'Due today'
              : 'Due ${DateFormat('d MMM').format(next.recordDate)}',
        );
      case 'wellness':
        final List<ActivityRecord>? sleepRows = records('sleep');
        final List<ActivityRecord>? moodRows = records('mood');
        if (sleepRows == null || moodRows == null) return null;
        final List<ActivityRecord> recentSleep =
            sleepRows
                .where(
                  (ActivityRecord row) =>
                      !row.recordDate.isAfter(now) &&
                      row.recordDate.isAfter(
                        now.subtract(const Duration(days: 7)),
                      ),
                )
                .toList()
              ..sort(
                (ActivityRecord a, ActivityRecord b) =>
                    b.recordDate.compareTo(a.recordDate),
              );
        final String sleep = recentSleep.isEmpty
            ? 'Sleep: no data'
            : 'Sleep: ${duration(recentSleep.first.value ?? 0)}';
        final List<ActivityRecord> recentMood = moodRows
            .where(
              (ActivityRecord row) =>
                  row.recordDate.isAfter(now.subtract(const Duration(days: 7))),
            )
            .toList();
        final double? average = TrackingCalculations.averageMood(recentMood);
        return _CardMetric(
          headline: sleep,
          detail: average == null
              ? 'Mood: no recent check-ins'
              : '7-day recorded mood average · ${average.toStringAsFixed(1)} / 10',
        );
      case 'gym-study':
        final List<ActivityRecord>? gymRows = records('gym');
        final List<ActivityRecord>? studyRows = records('study');
        if (gymRows == null || studyRows == null) return null;
        final DateTime weekStart = today.subtract(
          Duration(days: today.weekday - 1),
        );
        final List<ActivityRecord> gymWeek = gymRows
            .where(
              (ActivityRecord row) =>
                  !row.recordDate.isBefore(weekStart) &&
                  row.status == 'Attended',
            )
            .toList();
        final List<ActivityRecord> studyWeek = studyRows
            .where(
              (ActivityRecord row) =>
                  !row.recordDate.isBefore(weekStart) &&
                  row.recordDate.isBefore(today.add(const Duration(days: 1))),
            )
            .toList();
        final int minutes = TrackingCalculations.studyMinutes(studyWeek);
        return _CardMetric(
          headline: gymWeek.isEmpty
              ? 'Gym: no data'
              : 'Gym: ${gymWeek.length} attendance day${gymWeek.length == 1 ? '' : 's'}',
          detail: studyWeek.isEmpty
              ? 'Study: no sessions this week'
              : 'Study: ${duration(minutes)} this week',
        );
      case 'money':
        final List<ActivityRecord>? rows = records('money');
        if (rows == null) return null;
        final int daily = TrackingCalculations.moneyMinorUnits(
          forDay(rows, today),
          status: 'Expense',
        );
        final int monthly = TrackingCalculations.moneyMinorUnits(
          rows.where(
            (ActivityRecord row) =>
                row.recordDate.year == today.year &&
                row.recordDate.month == today.month,
          ),
          status: 'Expense',
        );
        final String currency =
            ref.watch(preferencesProvider).value?.currencyCode ?? 'INR';
        String money(int minor) => NumberFormat.currency(
          name: currency,
          decimalDigits: 2,
        ).format(minor / 100);
        final bool hasDaily = forDay(
          rows,
          today,
        ).any((ActivityRecord row) => row.status == 'Expense');
        final bool hasMonthly = rows.any(
          (ActivityRecord row) =>
              row.recordDate.year == today.year &&
              row.recordDate.month == today.month &&
              row.status == 'Expense',
        );
        return _CardMetric(
          headline: hasDaily ? money(daily) : 'No data today',
          detail: hasMonthly
              ? 'This month · ${money(monthly)}'
              : 'No expenses recorded this month.',
        );
      case 'screen-time':
        final List<ActivityRecord>? rows = records('screentime');
        if (rows == null) return null;
        final List<ActivityRecord> dayRows = forDay(rows, today);
        final int minutes = dayRows.fold<int>(
          0,
          (int sum, ActivityRecord row) => sum + (row.value ?? 0),
        );
        return _CardMetric(
          headline: dayRows.isEmpty ? 'No data' : duration(minutes),
          detail: dayRows.isEmpty
              ? 'No screen-time records today.'
              : '${dayRows.length} device record${dayRows.length == 1 ? '' : 's'} today',
        );
      case 'journal':
        final List<ActivityRecord>? rows = records('journal');
        if (rows == null) return null;
        final List<ActivityRecord> dayRows = forDay(rows, today)
          ..sort(
            (ActivityRecord a, ActivityRecord b) =>
                b.updatedAt.compareTo(a.updatedAt),
          );
        if (dayRows.isEmpty) {
          return const _CardMetric(
            headline: 'No entry today',
            detail: 'Your journal is ready when you are.',
          );
        }
        final ActivityRecord entry = dayRows.first;
        final String preview = entry.notes.trim().replaceAll('\n', ' ');
        return _CardMetric(
          headline: entry.title,
          detail: preview.isEmpty ? 'Open today’s reflection.' : preview,
        );
      case 'calendar':
        final DateTime monthStart = DateTime(today.year, today.month);
        const List<String> kinds = <String>[
          'journal',
          'mood',
          'study',
          'tasks',
          'gym',
          'sleep',
          'period',
          'money',
          'screentime',
        ];
        final List<List<ActivityRecord>?> sets = kinds
            .map(records)
            .toList(growable: false);
        if (sets.any((List<ActivityRecord>? rows) => rows == null)) return null;
        final int activeDays = <DateTime>{
          for (final List<ActivityRecord>? rows in sets)
            for (final ActivityRecord row in rows!)
              if (row.recordDate.year == monthStart.year &&
                  row.recordDate.month == monthStart.month)
                DateTime(
                  row.recordDate.year,
                  row.recordDate.month,
                  row.recordDate.day,
                ),
        }.length;
        return _CardMetric(
          headline: activeDays == 0
              ? 'No activity yet'
              : '$activeDays active days',
          detail: DateFormat('MMMM yyyy').format(today),
        );
      default:
        return const _CardMetric(headline: 'No data', detail: '');
    }
  }

  Future<void> _showHabitChecklist(BuildContext context, WidgetRef ref) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<Habit> habits = await ref.read(activeHabitsProvider.future);
    final List<Habit> scheduled = habits.where((Habit habit) {
      final Set<int> days = habit.scheduleDays
          .split(',')
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
      return !DateTime(
            habit.startDate.year,
            habit.startDate.month,
            habit.startDate.day,
          ).isAfter(today) &&
          days.contains(today.weekday);
    }).toList();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Today's habits"),
        content: SizedBox(
          width: 420,
          child: scheduled.isEmpty
              ? const Text(
                  'Nothing is scheduled for today. You can add a habit whenever you are ready.',
                )
              : StreamBuilder<List<HabitOccurrence>>(
                  stream: ref
                      .read(recordsRepositoryProvider)
                      .watchTodayOccurrences(today),
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<List<HabitOccurrence>> snapshot,
                      ) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final Map<String, HabitOccurrence> byHabit =
                            <String, HabitOccurrence>{
                              for (final HabitOccurrence row in snapshot.data!)
                                row.habitId: row,
                            };
                        return ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            for (final Habit habit in scheduled)
                              CheckboxListTile(
                                value: byHabit[habit.id]?.status == 'Completed',
                                title: Text(habit.name),
                                subtitle: Text(
                                  byHabit[habit.id]?.status ?? 'Not recorded',
                                ),
                                onChanged: (bool? completed) async {
                                  await ref
                                      .read(recordsRepositoryProvider)
                                      .recordHabitOnDate(
                                        habit,
                                        today,
                                        completed == true
                                            ? 'Completed'
                                            : 'Skipped',
                                      );
                                },
                              ),
                          ],
                        );
                      },
                ),
        ),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/habits');
            },
            icon: const Icon(Icons.add),
            label: const Text('Manage habits'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _CardMetric {
  const _CardMetric({
    required this.headline,
    required this.detail,
    this.progress,
  });
  final String headline;
  final String detail;
  final double? progress;
}

class _CardContent {
  const _CardContent(
    this.title,
    this.status,
    this.description,
    this.path,
    this.icon,
    this.tint,
  );

  final String title;
  final String status;
  final String description;
  final String path;
  final IconData icon;
  final Color tint;
}

class _NoVisibleCards extends StatelessWidget {
  const _NoVisibleCards({required this.palette});

  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context) => _MessageCard(
    icon: Icons.dashboard_customize_outlined,
    title: 'Your dashboard is clear',
    message: 'Show a card from Settings → Dashboard layout whenever you want.',
    palette: palette,
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.palette});

  final String message;
  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context) => _MessageCard(
    icon: Icons.error_outline_rounded,
    title: 'Could not load this view',
    message: message,
    palette: palette,
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.palette,
  });

  final IconData icon;
  final String title;
  final String message;
  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: palette.secondaryText, size: 24),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
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
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.palette});

  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.lock_outline_rounded,
          size: 17,
          color: palette.secondaryText,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Your records are stored locally. When sync is configured, PaTh encrypts record contents on this device before upload.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
          ),
        ),
      ],
    );
  }
}
