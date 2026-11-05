import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_providers.dart';
import '../../data/database/life_os_database.dart';
import '../../data/records/records_repository.dart';

class DailyReviewPage extends ConsumerStatefulWidget {
  const DailyReviewPage({super.key});

  @override
  ConsumerState<DailyReviewPage> createState() => _DailyReviewPageState();
}

class _DailyReviewPageState extends ConsumerState<DailyReviewPage> {
  DateTime _date = DateTime.now();

  static const Map<String, String> _areas = <String, String>{
    'habits': 'Habits',
    'tasks': 'Tasks',
    'study': 'Study',
    'gym': 'Gym',
    'mood': 'Mood',
    'sleep': 'Sleep',
    'period': 'Period',
    'money': 'Spending',
    'screenTime': 'Screen time',
    'journal': 'Journal',
    'review': 'Review',
  };

  @override
  Widget build(BuildContext context) {
    final RecordsRepository repo = ref.watch(recordsRepositoryProvider);
    final DateTime day = DateTime(_date.year, _date.month, _date.day);
    final String key =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return FutureBuilder<List<List<ActivityRecord>>>(
      future: Future.wait(
        _areas.keys.map((String kind) => repo.watch(kind).first),
      ),
      builder: (BuildContext context, AsyncSnapshot<List<List<ActivityRecord>>> snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final Map<String, List<ActivityRecord>> byKind =
            <String, List<ActivityRecord>>{
              for (int i = 0; i < _areas.length; i++)
                _areas.keys.elementAt(i): snapshot.data![i]
                    .where(
                      (ActivityRecord row) =>
                          row.recordDate.year == day.year &&
                          row.recordDate.month == day.month &&
                          row.recordDate.day == day.day,
                    )
                    .toList(),
            };
        final bool reviewed = byKind['review']!.any(
          (ActivityRecord row) => row.status == 'Completed',
        );
        return ListView(
          padding: const EdgeInsets.all(22),
          children: <Widget>[
            Text(
              'Daily review',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'A gentle summary of what you recorded. Missing information stays simply unrecorded.',
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(
                  '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}',
                ),
                subtitle: const Text('Choose a day to reflect on'),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () async {
                  final DateTime? chosen = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    initialDate: day,
                  );
                  if (chosen != null) setState(() => _date = chosen);
                },
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<HabitOccurrence>>(
              future: repo.watchTodayOccurrences(day).first,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<HabitOccurrence>> habits,
                  ) => Card(
                    child: ListTile(
                      leading: Icon(
                        habits.data?.isNotEmpty == true
                            ? Icons.check_circle_outline
                            : Icons.remove_circle_outline,
                      ),
                      title: const Text('Habits'),
                      subtitle: Text(
                        habits.data?.isNotEmpty == true
                            ? '${habits.data!.length} occurrence records saved'
                            : 'No habit occurrences recorded for this day',
                      ),
                      trailing: Text(
                        habits.data?.isNotEmpty == true
                            ? 'Recorded'
                            : 'Not recorded',
                      ),
                    ),
                  ),
            ),
            for (final MapEntry<String, String> area in _areas.entries)
              if (area.key != 'review' && area.key != 'habits')
                Card(
                  child: ListTile(
                    leading: Icon(
                      byKind[area.key]!.isEmpty
                          ? Icons.remove_circle_outline
                          : Icons.check_circle_outline,
                    ),
                    title: Text(area.value),
                    subtitle: Text(
                      byKind[area.key]!.isEmpty
                          ? 'No records for this day'
                          : '${byKind[area.key]!.length} ${byKind[area.key]!.length == 1 ? 'record' : 'records'} saved',
                    ),
                    trailing: byKind[area.key]!.isEmpty
                        ? const Text('Not recorded')
                        : const Text('Recorded'),
                  ),
                ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: reviewed
                  ? null
                  : () async {
                      await repo.save(
                        kind: 'review',
                        title: 'Daily review',
                        date: day,
                        status: 'Completed',
                        id: 'daily-review-$key',
                      );
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review saved on this device.'),
                          ),
                        );
                      setState(() {});
                    },
              icon: const Icon(Icons.auto_awesome_outlined),
              label: Text(
                reviewed ? 'Review completed' : 'Mark review complete',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This review is optional. An incomplete day is not a failure.',
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
