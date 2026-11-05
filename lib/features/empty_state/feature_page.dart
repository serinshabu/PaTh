import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../app/app_providers.dart';
import '../../app/navigation/destinations.dart';
import '../../app/theme/life_os_palette.dart';
import '../../data/database/life_os_database.dart';
import '../../data/records/records_repository.dart';
import '../../data/records/tracking_calculations.dart';
import '../device/device_feature_bridge.dart';

class FeaturePage extends ConsumerWidget {
  const FeaturePage({
    required this.destination,
    this.openQuickAdd = false,
    super.key,
  });
  final LifeOsDestination destination;
  final bool openQuickAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (destination.path == '/habits') {
      return openQuickAdd ? const _QuickAddHabitPage() : const HabitsPage();
    }
    final String kind = destination.path.substring(1).replaceAll('-', '');
    return RecordsPage(
      kind: kind,
      title: destination.title,
      description: destination.description,
      icon: destination.icon,
      currency: ref.watch(preferencesProvider).value?.currencyCode ?? 'INR',
      openQuickAdd: openQuickAdd,
    );
  }
}

class RecordsPage extends ConsumerStatefulWidget {
  const RecordsPage({
    required this.kind,
    required this.title,
    required this.description,
    required this.icon,
    required this.currency,
    this.openQuickAdd = false,
    super.key,
  });
  final String kind;
  final String title;
  final String description;
  final IconData icon;
  final String currency;
  final bool openQuickAdd;

  @override
  ConsumerState<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends ConsumerState<RecordsPage> {
  String search = '';

  @override
  void initState() {
    super.initState();
    if (widget.openQuickAdd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _editRecord(context, ref, widget.kind, widget.currency);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LifeOsPalette palette = LifeOsPalette.fromId(
      ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose',
    );
    final RecordsRepository repository = ref.watch(recordsRepositoryProvider);
    return StreamBuilder<List<ActivityRecord>>(
      stream: repository.watch(widget.kind),
      builder:
          (BuildContext context, AsyncSnapshot<List<ActivityRecord>> snapshot) {
            final List<ActivityRecord> all =
                snapshot.data ?? <ActivityRecord>[];
            final List<ActivityRecord> records = all
                .where(
                  (ActivityRecord r) => '${r.title} ${r.notes}'
                      .toLowerCase()
                      .contains(search.toLowerCase()),
                )
                .toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: <Widget>[
                _SummaryBanner(
                  title: widget.title,
                  description: widget.description,
                  icon: widget.icon,
                  palette: palette,
                  count: all.length,
                  summary: _summary(widget.kind, all, widget.currency),
                ),
                const SizedBox(height: 12),
                _RecentTrend(
                  records: all,
                  kind: widget.kind,
                  currency: widget.currency,
                  palette: palette,
                ),
                if (widget.kind == 'screentime') ...<Widget>[
                  const SizedBox(height: 14),
                  _ScreenTimeDevicePanel(records: all),
                ],
                if (widget.kind == 'tasks') ...<Widget>[
                  const SizedBox(height: 18),
                  const GoalsPanel(),
                ],
                if (widget.kind == 'money') ...<Widget>[
                  const SizedBox(height: 18),
                  BudgetsPanel(currency: widget.currency),
                ],
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Your records',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _editRecord(
                        context,
                        ref,
                        widget.kind,
                        widget.currency,
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (widget.kind == 'journal') ...<Widget>[
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search your entries',
                    ),
                    onChanged: (String value) => setState(() => search = value),
                  ),
                ],
                const SizedBox(height: 12),
                if (snapshot.hasError)
                  const _EmptyCard(
                    icon: Icons.error_outline,
                    title: 'Records could not be loaded',
                    message: 'Your local database reported a problem.',
                  ),
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (records.isEmpty && !snapshot.hasError)
                  _EmptyCard(
                    icon: widget.icon,
                    title: search.isEmpty
                        ? 'A fresh start'
                        : 'No matching entries',
                    message: search.isEmpty
                        ? 'Your ${widget.title.toLowerCase()} records will appear here after you add them.'
                        : 'Try another search.',
                  ),
                for (final ActivityRecord record in records)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RecordTile(
                      record: record,
                      kind: widget.kind,
                      currency: widget.currency,
                      onEdit: () => _editRecord(
                        context,
                        ref,
                        widget.kind,
                        widget.currency,
                        record: record,
                      ),
                      onDelete: () => _confirmDelete(context, ref, record),
                    ),
                  ),
              ],
            );
          },
    );
  }

  String _summary(String kind, List<ActivityRecord> records, String currency) {
    if (records.isEmpty) return 'No data recorded yet';
    switch (kind) {
      case 'study':
        final int minutes = records.fold<int>(
          0,
          (int s, ActivityRecord r) => s + (r.value ?? 0),
        );
        return '${minutes ~/ 60}h ${minutes % 60}m recorded';
      case 'mood':
        final List<int> values = records
            .where((ActivityRecord r) => r.value != null)
            .map((ActivityRecord r) => r.value!)
            .toList();
        return values.isEmpty
            ? 'No ratings recorded'
            : 'Average ${((values.reduce((int a, int b) => a + b) / values.length) * 10).round() / 10} / 10';
      case 'money':
        final int minor = records.fold<int>(
          0,
          (int s, ActivityRecord r) => s + (r.value ?? 0),
        );
        return '${NumberFormat.currency(name: currency, symbol: currency == 'INR' ? '₹' : '$currency ').format(minor / 100)} across ${records.length} entries';
      case 'gym':
        return '${records.where((ActivityRecord r) => r.status == 'Attended').length} attendance days';
      case 'period':
        return _cycleSummary(records);
      default:
        return '${records.length} ${records.length == 1 ? 'entry' : 'entries'}';
    }
  }

  String _cycleSummary(List<ActivityRecord> records) {
    final List<DateTime> starts =
        records
            .where((ActivityRecord r) => r.status == 'Period start')
            .map((ActivityRecord r) => r.recordDate)
            .toList()
          ..sort();
    if (starts.length < 2)
      return 'Cycle estimates appear after two recorded starts';
    final List<int> lengths = <int>[];
    for (int i = 1; i < starts.length; i++) {
      final int days = starts[i].difference(starts[i - 1]).inDays;
      if (days >= 15 && days <= 60) lengths.add(days);
    }
    if (lengths.isEmpty) return 'Cycle estimate unavailable';
    final int average =
        lengths.reduce((int a, int b) => a + b) ~/ lengths.length;
    final DateTime next = starts.last.add(Duration(days: average));
    return 'Estimated next start ${DateFormat('d MMM').format(next)} · about $average days';
  }
}

class _RecentTrend extends StatelessWidget {
  const _RecentTrend({
    required this.records,
    required this.kind,
    required this.currency,
    required this.palette,
  });

  final List<ActivityRecord> records;
  final String kind;
  final String currency;
  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context) {
    final List<ActivityRecord> recent = records
        .take(7)
        .toList()
        .reversed
        .toList();
    if (recent.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                labelForKind(kind),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'No recent entries yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
              ),
            ],
          ),
        ),
      );
    }
    final List<double> values = recent.map((ActivityRecord record) {
      if (kind == 'gym') return record.status == 'Attended' ? 1.0 : 0.0;
      if (kind == 'tasks' || kind == 'habits')
        return record.status == 'Completed' ? 1.0 : 0.0;
      return (record.value ?? 1).abs().toDouble();
    }).toList();
    final double maximum = values.fold<double>(
      1,
      (double a, double b) => a > b ? a : b,
    );
    final String label = labelForKind(kind);
    return Semantics(
      container: true,
      label: '$label, ${recent.length} most recent records',
      child: Card(
        margin: EdgeInsets.zero,
        color: palette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 64,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    for (int i = 0; i < recent.length; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Tooltip(
                            message:
                                '${recent[i].title}: ${recent[i].value ?? recent[i].status ?? 'recorded'} · ${DateFormat('d MMM').format(recent[i].recordDate)}',
                            child: Semantics(
                              label:
                                  '${DateFormat('d MMM').format(recent[i].recordDate)}: ${recent[i].title}, ${recent[i].value == null ? recent[i].status ?? 'recorded' : '${recent[i].value} ${recent[i].unit ?? ''}'}',
                              child: ExcludeSemantics(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      _trendCaption(recent[i]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 9,
                                            color: palette.secondaryText,
                                          ),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      height: (8 + 40 * (values[i] / maximum))
                                          .clamp(8, 48),
                                      decoration: BoxDecoration(
                                        color: palette.rose.withValues(
                                          alpha:
                                              .35 + .65 * (values[i] / maximum),
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  for (final ActivityRecord record in recent)
                    Expanded(
                      child: Text(
                        DateFormat('d MMM').format(record.recordDate),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: palette.secondaryText,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _trendCaption(ActivityRecord record) {
    if (kind == 'mood' && record.value != null) return '${record.value}/10';
    if (kind == 'money' && record.value != null) {
      return NumberFormat.compactCurrency(
        name: currency,
        decimalDigits: 0,
      ).format(record.value! / 100);
    }
    if (kind == 'gym' || kind == 'tasks') {
      return record.status == 'Attended' || record.status == 'Completed'
          ? '✓'
          : '—';
    }
    if (record.value != null) return '${record.value}${record.unit ?? ''}';
    return record.status ?? '✓';
  }
}

String labelForKind(String kind) => switch (kind) {
  'study' => 'Recent study minutes',
  'mood' => 'Recent mood ratings',
  'money' => 'Recent transaction amounts',
  'gym' => 'Recent attendance',
  _ => 'Recent activity',
};

class _ScreenTimeDevicePanel extends ConsumerStatefulWidget {
  const _ScreenTimeDevicePanel({required this.records});

  final List<ActivityRecord> records;

  @override
  ConsumerState<_ScreenTimeDevicePanel> createState() =>
      _ScreenTimeDevicePanelState();
}

class _ScreenTimeDevicePanelState
    extends ConsumerState<_ScreenTimeDevicePanel> {
  final DeviceFeatureBridge _bridge = const DeviceFeatureBridge();
  bool _busy = false;
  late Future<bool> _usageAccessFuture;

  late final WidgetsBindingObserver _lifecycleObserver =
      _ScreenTimeLifecycleObserver(
        onResume: () {
          if (mounted) {
            setState(() => _usageAccessFuture = _bridge.hasUsageAccess());
          }
        },
      );

  @override
  void initState() {
    super.initState();
    _usageAccessFuture = _bridge.hasUsageAccess();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_bridge.supportsAndroidUsageImport) {
      return const _EmptyCard(
        icon: Icons.devices_rounded,
        title: 'Manual tracking on this device',
        message:
            'Automatic usage import is available on Android when you grant Usage access. On Windows, add a manual screen-time record below.',
      );
    }
    return FutureBuilder<bool>(
      future: _usageAccessFuture,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final bool granted = snapshot.data ?? false;
        return _EmptyCard(
          icon: Icons.phone_android_rounded,
          title: granted
              ? 'Android usage access is ready'
              : 'Connect Android usage access',
          message: granted
              ? 'Import today’s aggregate foreground app time. Only total minutes are saved; app names are not stored or synced.'
              : 'Allow Usage access in Android Settings, then return here to import today’s total. You can keep using manual records instead.',
          action: FilledButton.tonalIcon(
            onPressed:
                _busy || snapshot.connectionState == ConnectionState.waiting
                ? null
                : () => granted ? _importToday() : _requestAccess(),
            icon: _busy
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    granted ? Icons.download_rounded : Icons.security_rounded,
                  ),
            label: Text(
              granted ? 'Import today’s usage' : 'Open usage access settings',
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestAccess() async {
    try {
      await _bridge.requestUsageAccess();
      if (mounted) setState(() {});
    } on PlatformException {
      _message('Android could not open Usage access settings.');
    }
  }

  Future<void> _importToday() async {
    setState(() => _busy = true);
    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final String installationId = await ref
          .read(settingsRepositoryProvider)
          .installationId();
      final List<ActivityRecord> todayRows = widget.records
          .where(
            (ActivityRecord row) =>
                row.recordDate.year == today.year &&
                row.recordDate.month == today.month &&
                row.recordDate.day == today.day,
          )
          .toList();
      final ActivityRecord? previousImport = todayRows.where((
        ActivityRecord row,
      ) {
        try {
          final Map<String, dynamic> metadata =
              jsonDecode(row.metadataJson) as Map<String, dynamic>;
          return metadata['source'] == 'android_usage_stats' &&
              metadata['deviceInstallationId'] == installationId;
        } catch (_) {
          return false;
        }
      }).firstOrNull;
      final List<ActivityRecord> otherTodayRows = todayRows.where((
        ActivityRecord row,
      ) {
        try {
          return (jsonDecode(row.metadataJson)
                  as Map<String, dynamic>)['source'] !=
              'android_usage_stats';
        } catch (_) {
          return true;
        }
      }).toList();
      if (otherTodayRows.isNotEmpty) {
        _message(
          'You already have screen-time records for today. Review or remove them before importing, to avoid double-counting.',
        );
        return;
      }
      final int minutes = await _bridge.todayUsageMinutes();
      await ref
          .read(recordsRepositoryProvider)
          .save(
            kind: 'screentime',
            title: 'Android usage total',
            date: today,
            value: minutes,
            unit: 'min',
            notes: 'Imported as an aggregate; app names are not stored.',
            metadataJson: jsonEncode(<String, String>{
              'source': 'android_usage_stats',
              'deviceInstallationId': installationId,
              'aggregation': 'foreground_minutes',
            }),
            id: previousImport?.id,
          );
      _message('Imported $minutes minutes for today.');
    } on PlatformException {
      _message(
        'Usage data could not be read. Check Android Usage access and try again.',
      );
    } catch (_) {
      _message(
        'Screen time could not be imported. Your existing records are safe.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String message) {
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ScreenTimeLifecycleObserver extends WidgetsBindingObserver {
  _ScreenTimeLifecycleObserver({required this.onResume});
  final VoidCallback onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}

class GoalsPanel extends ConsumerWidget {
  const GoalsPanel({super.key});
  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) => StreamBuilder<List<Goal>>(
    stream: ref.watch(recordsRepositoryProvider).watchGoals(),
    builder: (BuildContext context, AsyncSnapshot<List<Goal>> snapshot) {
      final List<Goal> goals = snapshot.data ?? <Goal>[];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Goals',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _editGoal(context, ref),
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Add goal'),
              ),
            ],
          ),
          if (goals.isEmpty)
            const _EmptyCard(
              icon: Icons.flag_outlined,
              title: 'Make room for a bigger intention',
              message:
                  'Create a weekly, monthly, or long-term goal. Progress is optional and can be updated as you go.',
            ),
          for (final Goal goal in goals) _GoalTile(goal: goal),
        ],
      );
    },
  );
}

class BudgetsPanel extends ConsumerWidget {
  const BudgetsPanel({required this.currency, super.key});
  final String currency;
  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) => StreamBuilder<List<Budget>>(
    stream: ref.watch(recordsRepositoryProvider).watchBudgets(),
    builder: (BuildContext context, AsyncSnapshot<List<Budget>> budgetSnap) =>
        StreamBuilder<List<ActivityRecord>>(
          stream: ref.watch(recordsRepositoryProvider).watch('money'),
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<ActivityRecord>> recordSnap,
              ) {
                final List<Budget> budgets = budgetSnap.data ?? <Budget>[];
                final List<ActivityRecord> records =
                    recordSnap.data ?? <ActivityRecord>[];
                final DateTime now = DateTime.now();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Monthly budgets',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _editBudget(context, ref, currency),
                          icon: const Icon(Icons.add),
                          label: const Text('Add budget'),
                        ),
                      ],
                    ),
                    if (budgets.isEmpty)
                      const _EmptyCard(
                        icon: Icons.savings_outlined,
                        title: 'Set a spending limit if helpful',
                        message:
                            'Budgets are optional and never block a transaction.',
                      ),
                    for (final Budget budget in budgets)
                      _BudgetTile(
                        budget: budget,
                        records: records
                            .where(
                              (ActivityRecord r) =>
                                  r.status == 'Expense' &&
                                  r.title.trim().toLowerCase() ==
                                      budget.category.toLowerCase() &&
                                  r.recordDate.year == now.year &&
                                  r.recordDate.month == now.month,
                            )
                            .toList(),
                        currency: currency,
                        onEdit: () =>
                            _editBudget(context, ref, currency, budget: budget),
                        onDelete: () => ref
                            .read(recordsRepositoryProvider)
                            .deleteBudget(budget),
                      ),
                  ],
                );
              },
        ),
  );
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.budget,
    required this.records,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });
  final Budget budget;
  final List<ActivityRecord> records;
  final String currency;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final int spent = records.fold<int>(
      0,
      (int sum, ActivityRecord r) => sum + (r.value ?? 0),
    );
    final double progress = (spent / budget.amountMinor).clamp(0, 1).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    budget.category,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${NumberFormat.currency(name: currency, symbol: currency == 'INR' ? '₹' : '$currency ').format(spent / 100)} / ${NumberFormat.currency(name: currency, symbol: currency == 'INR' ? '₹' : '$currency ').format(budget.amountMinor / 100)}',
                ),
                PopupMenuButton<String>(
                  onSelected: (String a) => a == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const <PopupMenuEntry<String>>[
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            LinearProgressIndicator(
              value: progress,
              color: spent > budget.amountMinor
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _editBudget(
  BuildContext context,
  WidgetRef ref,
  String currency, {
  Budget? budget,
}) async {
  final TextEditingController category = TextEditingController(
    text: budget?.category ?? '',
  );
  final TextEditingController amount = TextEditingController(
    text: budget == null ? '' : (budget.amountMinor / 100).toStringAsFixed(2),
  );
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (BuildContext c) => AlertDialog(
      title: Text(budget == null ? 'Add monthly budget' : 'Edit budget'),
      content: Form(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: category,
              decoration: const InputDecoration(
                labelText: 'Category (match transaction description)',
              ),
              validator: (String? v) =>
                  v == null || v.trim().isEmpty ? 'Add a category' : null,
            ),
            TextFormField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Monthly limit',
                suffixText: currency,
              ),
              validator: (String? v) =>
                  v == null ||
                      !RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(v.trim()) ||
                      TrackingCalculations.parseMoneyMinorUnits(v) <= 0
                  ? 'Enter a positive amount with up to two decimals'
                  : null,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (!(key.currentState?.validate() ?? false)) return;
            await ref
                .read(recordsRepositoryProvider)
                .saveBudget(
                  id: budget?.id,
                  category: category.text,
                  amountMinor: TrackingCalculations.parseMoneyMinorUnits(
                    amount.text,
                  ),
                );
            if (c.mounted) Navigator.pop(c);
          },
          child: const Text('Save budget'),
        ),
      ],
    ),
  );
}

class _GoalTile extends ConsumerWidget {
  const _GoalTile({required this.goal});
  final Goal goal;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double? progress = goal.target == null || goal.target == 0
        ? null
        : (goal.progress / goal.target!).clamp(0, 1).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    goal.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(goal.timeframe),
                PopupMenuButton<String>(
                  onSelected: (String v) {
                    if (v == 'edit') _editGoal(context, ref, goal: goal);
                    if (v == 'delete') _deleteGoal(context, ref, goal);
                  },
                  itemBuilder: (_) => const <PopupMenuEntry<String>>[
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (progress != null) ...<Widget>[
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 5),
              Text('${goal.progress} / ${goal.target} ${goal.unit}'),
            ],
            if (goal.dueDate != null)
              Text('Due ${DateFormat('d MMM yyyy').format(goal.dueDate!)}'),
            if (goal.notes.isNotEmpty)
              Text(goal.notes, maxLines: 2, overflow: TextOverflow.ellipsis),
            Row(
              children: <Widget>[
                Text(goal.status),
                const Spacer(),
                if (goal.target != null)
                  TextButton.icon(
                    onPressed: () => ref
                        .read(recordsRepositoryProvider)
                        .saveGoal(
                          id: goal.id,
                          name: goal.name,
                          timeframe: goal.timeframe,
                          target: goal.target,
                          progress: goal.progress + 1,
                          unit: goal.unit,
                          dueDate: goal.dueDate,
                          status: goal.status,
                          notes: goal.notes,
                        ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add progress'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _editGoal(
  BuildContext context,
  WidgetRef ref, {
  Goal? goal,
}) async {
  final TextEditingController name = TextEditingController(
        text: goal?.name ?? '',
      ),
      target = TextEditingController(text: goal?.target?.toString() ?? ''),
      progress = TextEditingController(text: goal?.progress.toString() ?? '0'),
      unit = TextEditingController(text: goal?.unit ?? 'steps'),
      notes = TextEditingController(text: goal?.notes ?? '');
  String timeframe = goal?.timeframe ?? 'Long-term',
      status = goal?.status ?? 'Active';
  DateTime? dueDate = goal?.dueDate;
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (BuildContext c) => StatefulBuilder(
      builder: (BuildContext c, StateSetter set) => AlertDialog(
        title: Text(goal == null ? 'Create a goal' : 'Edit goal'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Goal'),
                    validator: (String? v) => v == null || v.trim().isEmpty
                        ? 'Add a goal name'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: timeframe,
                    decoration: const InputDecoration(labelText: 'Timeframe'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                        value: 'Monthly',
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: 'Long-term',
                        child: Text('Long-term'),
                      ),
                    ],
                    onChanged: (String? v) =>
                        set(() => timeframe = v ?? timeframe),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: target,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Optional target',
                          ),
                          validator: (String? v) =>
                              v != null &&
                                  v.isNotEmpty &&
                                  (int.tryParse(v) == null || int.parse(v) <= 0)
                              ? 'Target must be positive'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: progress,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Progress',
                          ),
                          validator: (String? v) =>
                              v == null ||
                                  int.tryParse(v) == null ||
                                  int.parse(v) < 0
                              ? 'Enter a non-negative number'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: unit,
                    decoration: const InputDecoration(
                      labelText: 'Progress unit',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'On hold',
                        child: Text('On hold'),
                      ),
                      DropdownMenuItem(
                        value: 'Completed',
                        child: Text('Completed'),
                      ),
                    ],
                    onChanged: (String? v) => set(() => status = v ?? status),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final DateTime? d = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) set(() => dueDate = d);
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        dueDate == null
                            ? 'Optional deadline'
                            : DateFormat('d MMM yyyy').format(dueDate!),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: notes,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!(key.currentState?.validate() ?? false)) return;
              await ref
                  .read(recordsRepositoryProvider)
                  .saveGoal(
                    id: goal?.id,
                    name: name.text,
                    timeframe: timeframe,
                    target: int.tryParse(target.text),
                    progress: int.parse(progress.text),
                    unit: unit.text.isEmpty ? 'steps' : unit.text,
                    dueDate: dueDate,
                    status: status,
                    notes: notes.text,
                  );
              if (c.mounted) Navigator.pop(c);
            },
            child: Text(goal == null ? 'Save goal' : 'Update goal'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _deleteGoal(BuildContext context, WidgetRef ref, Goal goal) async {
  final bool? yes = await showDialog<bool>(
    context: context,
    builder: (BuildContext c) => AlertDialog(
      title: const Text('Delete this goal?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (yes == true) await ref.read(recordsRepositoryProvider).deleteGoal(goal);
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.title,
    required this.description,
    required this.icon,
    required this.palette,
    required this.count,
    required this.summary,
  });
  final String title, description, summary;
  final IconData icon;
  final LifeOsPalette palette;
  final int count;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: palette.card,
      border: Border.all(color: palette.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: palette.rose.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: palette.rose),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
              ),
              const SizedBox(height: 8),
              Text(
                summary,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: palette.lavender),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.kind,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });
  final ActivityRecord record;
  final String kind, currency;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final LifeOsPalette palette = LifeOsPalette.fromId(
      Theme.of(context).brightness == Brightness.dark
          ? 'midnightRose'
          : 'softBlush',
    );
    String detail = DateFormat(
      'EEE, d MMM yyyy · h:mm a',
    ).format(record.recordDate);
    if (kind == 'money' && record.value != null)
      detail +=
          ' · ${NumberFormat.currency(name: currency, symbol: currency == 'INR' ? '₹' : '$currency ').format(record.value! / 100)}';
    if (kind == 'study' && record.value != null)
      detail += ' · ${record.value} min';
    if (kind == 'screenTime' && record.value != null)
      detail += ' · ${record.value! ~/ 60}h ${record.value! % 60}m';
    if (kind == 'mood' && record.value != null)
      detail += ' · ${record.value}/10';
    if (kind == 'sleep' && record.value != null)
      detail += ' · ${record.value! ~/ 60}h ${record.value! % 60}m';
    if (record.status != null) detail += ' · ${record.status}';
    if (kind == 'tasks') detail += ' · ${_recordPriority(record)} priority';
    return Card(
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    record.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                  if (record.notes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 7),
                    Text(
                      record.notes,
                      maxLines: kind == 'journal' ? 5 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Record actions',
              onSelected: (String action) =>
                  action == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const <PopupMenuEntry<String>>[
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final LifeOsPalette p = LifeOsPalette.fromId(
      Theme.of(context).brightness == Brightness.dark
          ? 'midnightRose'
          : 'softBlush',
    );
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: p.lavender, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: p.secondaryText),
          ),
          if (action != null) ...<Widget>[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

Future<void> _editRecord(
  BuildContext context,
  WidgetRef ref,
  String kind,
  String currency, {
  ActivityRecord? record,
}) async {
  final _RecordFormConfig config = _RecordFormConfig.forKind(kind, currency);
  final TextEditingController title = TextEditingController(
    text: record?.title ?? config.defaultTitle,
  );
  final TextEditingController value = TextEditingController(
    text: _initialValue(kind, record),
  );
  final TextEditingController notes = TextEditingController(
    text: record?.notes ?? '',
  );
  final TextEditingController category = TextEditingController(
    text: kind == 'money' ? _moneyCategory(record) : '',
  );
  final TextEditingController quality = TextEditingController(
    text: record == null ? '' : _quality(record, kind),
  );
  final TextEditingController pain = TextEditingController(
    text: record == null ? '' : _periodField(record, 'painRating'),
  );
  final TextEditingController energy = TextEditingController(
    text: record == null ? '' : _periodField(record, 'energyRating'),
  );
  DateTime date = record?.recordDate ?? DateTime.now();
  final Map<String, dynamic> priorSleep = kind == 'sleep'
      ? _sleepMetadata(record)
      : <String, dynamic>{};
  TimeOfDay bedtime = TimeOfDay(
    hour: ((priorSleep['bedMinute'] as int?) ?? 1320) ~/ 60,
    minute: ((priorSleep['bedMinute'] as int?) ?? 1320) % 60,
  );
  TimeOfDay wakeTime = TimeOfDay(
    hour: ((priorSleep['wakeMinute'] as int?) ?? 360) ~/ 60,
    minute: ((priorSleep['wakeMinute'] as int?) ?? 360) % 60,
  );
  String? status = record?.status ?? config.statuses.firstOrNull;
  String priority = _recordPriority(record);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => AlertDialog(
        title: Text(
          record == null ? 'Add ${config.noun}' : 'Edit ${config.noun}',
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: title,
                    decoration: InputDecoration(labelText: config.titleLabel),
                    validator: (String? v) => (v == null || v.trim().isEmpty)
                        ? 'Please add a name'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  if (config.valueLabel != null && kind != 'sleep')
                    TextFormField(
                      controller: value,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: config.valueLabel,
                        suffixText: config.unit,
                      ),
                      validator: (String? v) => _validateValue(kind, v),
                    ),
                  if (kind == 'money') ...<Widget>[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: category,
                      decoration: const InputDecoration(
                        labelText: 'Category (optional)',
                        hintText: 'For example, groceries or transport',
                      ),
                    ),
                  ],
                  if (kind == 'sleep')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _timePicker(
                          context,
                          'Bedtime',
                          bedtime,
                          (TimeOfDay t) => setState(() => bedtime = t),
                        ),
                        _timePicker(
                          context,
                          'Wake-up',
                          wakeTime,
                          (TimeOfDay t) => setState(() => wakeTime = t),
                        ),
                        TextFormField(
                          controller: quality,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Sleep quality (1–5)',
                          ),
                          validator: (String? v) =>
                              v != null &&
                                  v.isNotEmpty &&
                                  (int.tryParse(v) == null ||
                                      int.parse(v) < 1 ||
                                      int.parse(v) > 5)
                              ? 'Enter a number from 1 to 5'
                              : null,
                        ),
                      ],
                    ),
                  if (kind == 'period') ...<Widget>[
                    TextFormField(
                      controller: pain,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Pain rating (optional, 1–5)',
                      ),
                      validator: (String? raw) =>
                          _validateOptionalRating(raw, 5),
                    ),
                    TextFormField(
                      controller: energy,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Energy rating (optional, 1–5)',
                      ),
                      validator: (String? raw) =>
                          _validateOptionalRating(raw, 5),
                    ),
                  ],
                  if (config.statuses.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: config.statuses
                          .map(
                            (String s) => DropdownMenuItem<String>(
                              value: s,
                              child: Text(s),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) => setState(() => status = v),
                    ),
                  ],
                  if (kind == 'tasks')
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'Normal',
                          child: Text('Normal'),
                        ),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (String? v) =>
                          setState(() => priority = v ?? priority),
                    ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final DateTime? selected = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selected != null)
                          setState(
                            () => date = DateTime(
                              selected.year,
                              selected.month,
                              selected.day,
                              date.hour,
                              date.minute,
                            ),
                          );
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(DateFormat('EEE, d MMM yyyy').format(date)),
                    ),
                  ),
                  if (kind == 'journal')
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: <Widget>[
                        for (final String prompt in const <String>[
                          'What went well today?',
                          'What affected my mood?',
                          'What am I grateful for?',
                          "Tomorrow's priority?",
                        ])
                          ActionChip(
                            label: Text(prompt),
                            onPressed: () {
                              final String spacer = notes.text.isEmpty
                                  ? ''
                                  : '\n\n';
                              notes.text = '${notes.text}$spacer$prompt\n';
                              notes.selection = TextSelection.collapsed(
                                offset: notes.text.length,
                              );
                            },
                          ),
                      ],
                    ),
                  TextFormField(
                    controller: notes,
                    minLines: kind == 'journal' ? 5 : 2,
                    maxLines: kind == 'journal' ? 12 : 4,
                    decoration: InputDecoration(
                      labelText: kind == 'journal'
                          ? 'Write your reflection'
                          : 'Notes (optional)',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              int? parsed;
              if (kind == 'sleep') {
                parsed = TrackingCalculations.sleepMinutes(
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    bedtime.hour,
                    bedtime.minute,
                  ),
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    wakeTime.hour,
                    wakeTime.minute,
                  ),
                );
              } else if (value.text.trim().isNotEmpty) {
                parsed = kind == 'money'
                    ? TrackingCalculations.parseMoneyMinorUnits(value.text)
                    : int.tryParse(value.text) ??
                          double.parse(value.text).round();
              }
              String metadata = '{}';
              if (kind == 'screentime') {
                metadata = jsonEncode(<String, String>{'source': 'manual'});
              }
              if (kind == 'sleep')
                metadata = jsonEncode(<String, int>{
                  if (quality.text.isNotEmpty)
                    'quality': int.parse(quality.text),
                  'bedMinute': bedtime.hour * 60 + bedtime.minute,
                  'wakeMinute': wakeTime.hour * 60 + wakeTime.minute,
                });
              if (kind == 'tasks')
                metadata = jsonEncode(<String, String>{'priority': priority});
              if (kind == 'period')
                metadata = jsonEncode(<String, int>{
                  if (pain.text.isNotEmpty) 'painRating': int.parse(pain.text),
                  if (energy.text.isNotEmpty)
                    'energyRating': int.parse(energy.text),
                });
              if (kind == 'money')
                metadata = jsonEncode(<String, String>{
                  if (category.text.trim().isNotEmpty)
                    'category': category.text.trim(),
                });
              final String finalTitle =
                  kind == 'journal' && title.text.trim().isEmpty
                  ? 'Journal entry'
                  : title.text;
              await ref
                  .read(recordsRepositoryProvider)
                  .save(
                    kind: kind,
                    title: finalTitle,
                    date: date,
                    value: parsed,
                    unit: config.unit,
                    status: status,
                    notes: notes.text,
                    metadataJson: metadata,
                    id: record?.id,
                  );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

String _initialValue(String kind, ActivityRecord? record) {
  if (record?.value == null) return '';
  if (kind == 'money') return (record!.value! / 100).toStringAsFixed(2);
  if (kind == 'sleep') return (record!.value! / 60).toStringAsFixed(1);
  return record!.value.toString();
}

String _quality(ActivityRecord record, String kind) {
  if (kind != 'sleep') return '';
  try {
    return (jsonDecode(record.metadataJson) as Map<String, dynamic>)['quality']
            ?.toString() ??
        '';
  } catch (_) {
    return '';
  }
}

String _moneyCategory(ActivityRecord? record) {
  if (record == null) return '';
  try {
    final dynamic parsed = jsonDecode(record.metadataJson);
    if (parsed is Map<String, dynamic>) {
      return parsed['category']?.toString() ?? '';
    }
  } on FormatException {
    return '';
  }
  return '';
}

String _periodField(ActivityRecord record, String key) {
  try {
    return (jsonDecode(record.metadataJson) as Map<String, dynamic>)[key]
            ?.toString() ??
        '';
  } catch (_) {
    return '';
  }
}

String? _validateOptionalRating(String? raw, int max) {
  if (raw == null || raw.trim().isEmpty) return null;
  final int? rating = int.tryParse(raw.trim());
  if (rating == null || rating < 1 || rating > max)
    return 'Enter a number from 1 to $max';
  return null;
}

String _recordPriority(ActivityRecord? record) {
  if (record == null) return 'Normal';
  try {
    return (jsonDecode(record.metadataJson) as Map<String, dynamic>)['priority']
            as String? ??
        'Normal';
  } catch (_) {
    return 'Normal';
  }
}

Map<String, dynamic> _sleepMetadata(ActivityRecord? record) {
  if (record == null) return <String, dynamic>{};
  try {
    return jsonDecode(record.metadataJson) as Map<String, dynamic>;
  } catch (_) {
    return <String, dynamic>{};
  }
}

Widget _timePicker(
  BuildContext context,
  String label,
  TimeOfDay value,
  ValueChanged<TimeOfDay> onChanged,
) => Align(
  alignment: Alignment.centerLeft,
  child: TextButton.icon(
    onPressed: () async {
      final TimeOfDay? selected = await showTimePicker(
        context: context,
        initialTime: value,
      );
      if (selected != null) onChanged(selected);
    },
    icon: const Icon(Icons.schedule_outlined),
    label: Text('$label · ${value.format(context)}'),
  ),
);

String? _validateValue(String kind, String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'Please enter a value';
  if (kind == 'money') {
    final RegExp moneyPattern = RegExp(r'^\d+(?:\.\d{1,2})?$');
    if (!moneyPattern.hasMatch(raw.trim()) ||
        TrackingCalculations.parseMoneyMinorUnits(raw) <= 0)
      return 'Enter an amount greater than zero with up to two decimal places';
    return null;
  }
  final num? n = num.tryParse(raw);
  if (n == null || !n.isFinite || n < 0)
    return 'Enter a valid non-negative number';
  if ((kind == 'mood' && (n < 1 || n > 10)) ||
      (kind == 'sleep' && n > 24) ||
      (kind == 'gym' && n > 1))
    return 'Value is outside the allowed range';
  if (kind != 'money' && kind != 'sleep' && n != n.roundToDouble())
    return 'Enter a whole number';
  return null;
}

class _RecordFormConfig {
  const _RecordFormConfig(
    this.noun,
    this.titleLabel,
    this.defaultTitle,
    this.valueLabel,
    this.unit,
    this.statuses,
  );
  final String noun, titleLabel, defaultTitle;
  final String? valueLabel;
  final String unit;
  final List<String> statuses;
  static _RecordFormConfig forKind(String kind, String currency) =>
      switch (kind) {
        'tasks' => const _RecordFormConfig(
          'task',
          'Task',
          '',
          null,
          '',
          <String>['Planned', 'In progress', 'Completed', 'Rescheduled'],
        ),
        'study' => const _RecordFormConfig(
          'study session',
          'Subject (optional)',
          'Study session',
          'Duration',
          'min',
          <String>[],
        ),
        'gym' => const _RecordFormConfig(
          'gym record',
          'Activity (optional)',
          'Gym',
          null,
          '',
          <String>['Attended', 'Not attended'],
        ),
        'mood' => const _RecordFormConfig(
          'mood check-in',
          'Context (optional)',
          'Mood check-in',
          'Mood rating',
          '/10',
          <String>[],
        ),
        'sleep' => const _RecordFormConfig(
          'sleep record',
          'Sleep',
          'Sleep',
          'Duration',
          'hours',
          <String>[],
        ),
        'period' => const _RecordFormConfig(
          'cycle record',
          'Record label',
          'Period',
          null,
          '',
          <String>['Period start', 'Period end', 'Symptom'],
        ),
        'money' => _RecordFormConfig(
          'transaction',
          'Description',
          '',
          'Amount',
          currency,
          const <String>['Expense', 'Income'],
        ),
        'screentime' => const _RecordFormConfig(
          'screen-time record',
          'Device or activity',
          'Screen time',
          'Duration',
          'min',
          <String>[],
        ),
        'journal' => const _RecordFormConfig(
          'journal entry',
          'Title',
          'Journal entry',
          null,
          '',
          <String>[],
        ),
        _ => const _RecordFormConfig('entry', 'Name', '', null, '', <String>[]),
      };
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  ActivityRecord row,
) async {
  final bool? yes = await showDialog<bool>(
    context: context,
    builder: (BuildContext c) => AlertDialog(
      title: const Text('Delete this record?'),
      content: const Text(
        'It will be removed from this device. This action cannot be undone here.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Keep'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (yes == true) await ref.read(recordsRepositoryProvider).delete(row);
}

class _QuickAddHabitPage extends ConsumerStatefulWidget {
  const _QuickAddHabitPage();

  @override
  ConsumerState<_QuickAddHabitPage> createState() => _QuickAddHabitPageState();
}

class _QuickAddHabitPageState extends ConsumerState<_QuickAddHabitPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _addHabit(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) => const HabitsPage();
}

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RecordsRepository repo = ref.watch(recordsRepositoryProvider);
    final DateTime today = DateTime.now();
    final LifeOsPalette palette = LifeOsPalette.fromId(
      ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose',
    );
    return StreamBuilder<List<Habit>>(
      stream: repo.watchHabits(),
      builder: (BuildContext context, AsyncSnapshot<List<Habit>> habitsSnap) =>
          StreamBuilder<List<HabitOccurrence>>(
            stream: repo.watchTodayOccurrences(today),
            builder: (BuildContext context, AsyncSnapshot<List<HabitOccurrence>> occSnap) {
              final List<Habit> habits = habitsSnap.data ?? <Habit>[];
              final Map<String, HabitOccurrence> occurrences =
                  <String, HabitOccurrence>{
                    for (final HabitOccurrence o
                        in occSnap.data ?? <HabitOccurrence>[])
                      o.habitId: o,
                  };
              final List<Habit> due = habits
                  .where(
                    (Habit h) => h.scheduleDays
                        .split(',')
                        .contains(today.weekday.toString()),
                  )
                  .toList();
              final int completed = due
                  .where((Habit h) => occurrences[h.id]?.status == 'Completed')
                  .length;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  _SummaryBanner(
                    title: 'Habits',
                    description:
                        'Scheduled routines, tracked gently and on your terms.',
                    icon: Icons.check_circle_outline_rounded,
                    palette: palette,
                    count: habits.length,
                    summary: due.isEmpty
                        ? 'No habits scheduled today'
                        : '$completed of ${due.length} scheduled habits completed today',
                  ),
                  const SizedBox(height: 12),
                  _RecentHabitTrend(repository: repo, palette: palette),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Your routines',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _addHabit(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Add habit'),
                      ),
                    ],
                  ),
                  if (habits.isEmpty)
                    const _EmptyCard(
                      icon: Icons.spa_outlined,
                      title: 'Start with what matters to you',
                      message:
                          'Create a habit when you are ready. Planned rest days are simply not scheduled.',
                    ),
                  for (final Habit h in habits)
                    _HabitTile(
                      habit: h,
                      occurrence: occurrences[h.id],
                      due: due.contains(h),
                      onStatus: (String status) => repo.recordHabit(h, status),
                      onArchive: () => repo.archiveHabit(h, true),
                      onEdit: () => _addHabit(context, ref, existing: h),
                      onDelete: () => _confirmDeleteHabit(context, ref, h),
                      onNumeric: () =>
                          _recordNumericHabit(context, ref, repo, h),
                      repository: repo,
                    ),
                  const SizedBox(height: 18),
                  TextButton.icon(
                    onPressed: () async {
                      final List<Habit> archived = await repo
                          .watchHabits(archived: true)
                          .first;
                      if (!context.mounted) return;
                      await showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext c) => ListView(
                          shrinkWrap: true,
                          children: archived.isEmpty
                              ? const <Widget>[
                                  ListTile(title: Text('No archived habits')),
                                ]
                              : archived
                                    .map(
                                      (Habit h) => ListTile(
                                        title: Text(h.name),
                                        trailing: TextButton(
                                          onPressed: () {
                                            repo.archiveHabit(h, false);
                                            Navigator.pop(c);
                                          },
                                          child: const Text('Restore'),
                                        ),
                                      ),
                                    )
                                    .toList(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.archive_outlined),
                    label: const Text('Archived habits'),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _RecentHabitTrend extends StatelessWidget {
  const _RecentHabitTrend({required this.repository, required this.palette});

  final RecordsRepository repository;
  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<HabitOccurrence>>(
    stream: repository.watchRecentHabitOccurrences(),
    builder: (BuildContext context, AsyncSnapshot<List<HabitOccurrence>> snapshot) {
      final List<HabitOccurrence> rows = snapshot.data ?? <HabitOccurrence>[];
      return Semantics(
        container: true,
        label: rows.isEmpty
            ? 'Recent habit history. No occurrences recorded yet.'
            : 'Recent habit history. ${rows.length} latest occurrences.',
        child: Card(
          margin: EdgeInsets.zero,
          color: palette.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: palette.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Recent habit history',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                if (rows.isEmpty)
                  Text(
                    'Your recorded routine history will appear here.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.secondaryText,
                    ),
                  )
                else
                  for (final HabitOccurrence occurrence in rows.take(5))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            occurrence.status == 'Completed'
                                ? Icons.check_circle_outline_rounded
                                : occurrence.status == 'Missed'
                                ? Icons.cancel_outlined
                                : Icons.remove_circle_outline_rounded,
                            size: 18,
                            color: occurrence.status == 'Completed'
                                ? palette.positive
                                : palette.secondaryText,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${DateFormat('EEE, d MMM').format(occurrence.occurrenceDate)} · ${occurrence.status}${occurrence.numericValue == null ? '' : ' · ${occurrence.numericValue}'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.habit,
    required this.occurrence,
    required this.due,
    required this.onStatus,
    required this.onArchive,
    required this.onEdit,
    required this.onDelete,
    required this.onNumeric,
    required this.repository,
  });
  final Habit habit;
  final HabitOccurrence? occurrence;
  final bool due;
  final ValueChanged<String> onStatus;
  final VoidCallback onArchive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onNumeric;
  final RecordsRepository repository;
  @override
  Widget build(BuildContext context) {
    final String status = occurrence?.status ?? 'Not recorded';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              habit.trackingType == 'numeric'
                  ? Icons.straighten
                  : Icons.check_circle_outline,
              color: status == 'Completed'
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            title: Text(habit.name),
            subtitle: Text(
              '${habit.category} · ${due ? status : 'Rest day'}${habit.trackingType == 'numeric' ? ' · ${habit.target ?? 'No target'} ${habit.unit}' : ''}',
            ),
            trailing: PopupMenuButton<String>(
              tooltip: 'Habit actions',
              onSelected: (String v) {
                if (v == 'Archive') {
                  onArchive();
                } else if (v == 'Edit') {
                  onEdit();
                } else if (v == 'Delete') {
                  onDelete();
                } else if (v == 'Record value') {
                  onNumeric();
                } else {
                  onStatus(v);
                }
              },
              itemBuilder: (_) => <PopupMenuEntry<String>>[
                const PopupMenuItem(value: 'Edit', child: Text('Edit habit')),
                if (habit.trackingType ==
                    'completion') ...<PopupMenuEntry<String>>[
                  const PopupMenuItem(
                    value: 'Completed',
                    child: Text('Completed'),
                  ),
                  const PopupMenuItem(value: 'Missed', child: Text('Missed')),
                  const PopupMenuItem(value: 'Skipped', child: Text('Skipped')),
                ] else
                  const PopupMenuItem(
                    value: 'Record value',
                    child: Text('Record value'),
                  ),
                const PopupMenuItem(
                  value: 'Not applicable',
                  child: Text('Not applicable'),
                ),
                const PopupMenuItem(value: 'Archive', child: Text('Archive')),
                const PopupMenuItem(
                  value: 'Delete',
                  child: Text('Delete permanently'),
                ),
              ],
            ),
          ),
          ExpansionTile(
            leading: const Icon(Icons.history_rounded, size: 18),
            title: const Text('History'),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            children: <Widget>[
              StreamBuilder<List<HabitOccurrence>>(
                stream: repository.watchHabitHistory(habit.id),
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<List<HabitOccurrence>> snapshot,
                    ) {
                      final List<HabitOccurrence> rows =
                          snapshot.data ?? <HabitOccurrence>[];
                      if (rows.isEmpty)
                        return const ListTile(
                          title: Text('No recorded occurrences yet.'),
                        );
                      return Column(
                        children: rows
                            .map(
                              (HabitOccurrence row) => ListTile(
                                dense: true,
                                title: Text(
                                  '${row.occurrenceDate.day.toString().padLeft(2, '0')}/${row.occurrenceDate.month.toString().padLeft(2, '0')}/${row.occurrenceDate.year}',
                                ),
                                subtitle: Text(
                                  '${row.status}${row.numericValue == null ? '' : ' · ${row.numericValue} ${habit.unit}'}',
                                ),
                                trailing: PopupMenuButton<String>(
                                  tooltip: 'Edit historical occurrence',
                                  onSelected: (String status) =>
                                      repository.recordHabitOnDate(
                                        habit,
                                        row.occurrenceDate,
                                        status,
                                        value: row.numericValue,
                                      ),
                                  itemBuilder: (_) => <PopupMenuEntry<String>>[
                                    for (final String status in <String>[
                                      'Completed',
                                      'Missed',
                                      'Skipped',
                                      'Not applicable',
                                    ])
                                      PopupMenuItem<String>(
                                        value: status,
                                        child: Text(status),
                                      ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
              ),
              TextButton.icon(
                onPressed: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    firstDate: habit.startDate,
                    lastDate: DateTime.now(),
                    initialDate: DateTime.now(),
                  );
                  if (date == null || !context.mounted) return;
                  final String? status = await showDialog<String>(
                    context: context,
                    builder: (BuildContext dialogContext) => SimpleDialog(
                      title: const Text('Record this date'),
                      children:
                          <String>[
                                'Completed',
                                'Missed',
                                'Skipped',
                                'Not applicable',
                              ]
                              .map(
                                (String value) => SimpleDialogOption(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, value),
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                    ),
                  );
                  if (status != null)
                    await repository.recordHabitOnDate(habit, date, status);
                },
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Add or edit a past date'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmDeleteHabit(
  BuildContext context,
  WidgetRef ref,
  Habit habit,
) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext c) => AlertDialog(
      title: const Text('Delete this habit?'),
      content: const Text(
        'Its linked occurrence history will also be removed from this device.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed == true)
    await ref.read(recordsRepositoryProvider).deleteHabit(habit);
}

Future<void> _recordNumericHabit(
  BuildContext context,
  WidgetRef ref,
  RecordsRepository repo,
  Habit habit,
) async {
  final TextEditingController value = TextEditingController(text: '');
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  int? result;
  await showDialog<void>(
    context: context,
    builder: (BuildContext c) => AlertDialog(
      title: Text('Record ${habit.name}'),
      content: Form(
        key: key,
        child: TextFormField(
          controller: value,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Value',
            suffixText: habit.unit,
          ),
          validator: (String? v) =>
              v == null || int.tryParse(v) == null || int.parse(v) < 0
              ? 'Enter a non-negative whole number'
              : null,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (key.currentState?.validate() ?? false) {
              result = int.parse(value.text);
              Navigator.pop(c);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  if (result != null)
    await repo.recordHabit(
      habit,
      habit.target == null || result! >= habit.target!
          ? 'Completed'
          : 'Recorded',
      value: result,
    );
}

Future<void> _addHabit(
  BuildContext context,
  WidgetRef ref, {
  Habit? existing,
}) async {
  final TextEditingController name = TextEditingController(
        text: existing?.name ?? '',
      ),
      unit = TextEditingController(text: existing?.unit ?? ''),
      target = TextEditingController(text: existing?.target?.toString() ?? ''),
      description = TextEditingController(text: existing?.description ?? '');
  String type = existing?.trackingType ?? 'completion',
      category = existing?.category ?? 'Personal';
  final Set<int> days = existing == null
      ? <int>{1, 2, 3, 4, 5, 6, 7}
      : existing.scheduleDays
            .split(',')
            .map(int.tryParse)
            .whereType<int>()
            .toSet();
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (BuildContext c) => StatefulBuilder(
      builder: (BuildContext c, StateSetter set) => AlertDialog(
        title: Text(existing == null ? 'Create a habit' : 'Edit habit'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Habit name'),
                    validator: (String? v) =>
                        v == null || v.trim().isEmpty ? 'Add a name' : null,
                  ),
                  TextFormField(
                    controller: description,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(
                      labelText: 'Tracking type',
                    ),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        value: 'completion',
                        child: Text('Completion'),
                      ),
                      DropdownMenuItem(
                        value: 'numeric',
                        child: Text('Numerical'),
                      ),
                    ],
                    onChanged: (String? v) => set(() => type = v ?? type),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        value: 'Personal',
                        child: Text('Personal'),
                      ),
                      DropdownMenuItem(
                        value: 'Wellness',
                        child: Text('Wellness'),
                      ),
                      DropdownMenuItem(value: 'Study', child: Text('Study')),
                      DropdownMenuItem(
                        value: 'Fitness',
                        child: Text('Fitness'),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (String? v) =>
                        set(() => category = v ?? category),
                  ),
                  if (type == 'numeric') ...<Widget>[
                    TextFormField(
                      controller: unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      validator: (String? v) =>
                          type == 'numeric' && (v == null || v.trim().isEmpty)
                          ? 'Add a unit'
                          : null,
                    ),
                    TextFormField(
                      controller: target,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Optional target',
                      ),
                      validator: (String? v) =>
                          v != null &&
                              v.isNotEmpty &&
                              (int.tryParse(v) == null || int.parse(v) < 0)
                          ? 'Enter a non-negative whole number'
                          : null,
                    ),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 2,
                      children: <Widget>[
                        for (int d = 1; d <= 7; d++)
                          FilterChip(
                            label: Text(
                              const <String>[
                                'M',
                                'T',
                                'W',
                                'T',
                                'F',
                                'S',
                                'S',
                              ][d - 1],
                            ),
                            selected: days.contains(d),
                            onSelected: (bool selected) => set(
                              () => selected ? days.add(d) : days.remove(d),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose scheduled days. Unselected days are planned rest days.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!(key.currentState?.validate() ?? false)) return;
              final List<int> orderedDays = days.toList()..sort();
              await ref
                  .read(recordsRepositoryProvider)
                  .saveHabit(
                    id: existing?.id,
                    name: name.text,
                    description: description.text,
                    category: category,
                    trackingType: type,
                    unit: unit.text,
                    target: int.tryParse(target.text),
                    scheduledDays: orderedDays.join(','),
                    reduction: false,
                  );
              if (c.mounted) Navigator.pop(c);
            },
            child: Text(existing == null ? 'Save habit' : 'Update habit'),
          ),
        ],
      ),
    ),
  );
}
