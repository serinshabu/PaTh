import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'backup_restore_panel.dart';

import '../../app/app_providers.dart';
import '../../app/theme/life_os_palette.dart';
import '../../data/database/life_os_database.dart';
import '../../data/settings/settings_repository.dart';
import 'sync_settings_panel.dart';
import 'reminder_settings_panel.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LifeOsPalette palette = LifeOsPalette.fromId(
      ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose',
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Make this space yours.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your preferences are saved on this device.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
              ),
              const SizedBox(height: 24),
              _SettingsSection(
                title: 'Appearance',
                subtitle: 'Choose the look that feels right for you.',
                palette: palette,
                child: Column(
                  children: <Widget>[
                    _ThemeChoices(palette: palette),
                    const Divider(height: 24),
                    _AccentChoices(palette: palette),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'Formats',
                subtitle: 'Set how dates, times, and money appear.',
                palette: palette,
                child: const _FormatChoices(),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'Dashboard layout',
                subtitle:
                    'Show, hide, and arrange the cards on your dashboard.',
                palette: palette,
                trailing: TextButton.icon(
                  onPressed: () => _confirmReset(context, ref),
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('Reset'),
                ),
                child: const _DashboardLayoutEditor(),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'Reminders & device features',
                subtitle:
                    'Choose local reminders and screen-time permissions for this device.',
                palette: palette,
                child: const ReminderSettingsPanel(),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'Privacy and sync',
                subtitle:
                    'Your health, journal, and financial records are personal.',
                palette: palette,
                child: SyncSettingsPanel(palette: palette),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'Backup, restore & export',
                subtitle: 'Keep a portable copy of your PaTh records.',
                palette: palette,
                child: const BackupRestorePanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reset dashboard layout?'),
        content: const Text(
          'This restores the default card order, visibility, and sizes.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset layout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _save(
        context,
        ref.read(settingsRepositoryProvider).resetDashboard(),
      );
    }
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final LifeOsPalette palette;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ThemeChoices extends ConsumerWidget {
  const _ThemeChoices({required this.palette});

  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String selected =
        ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose';
    final List<LifeOsPalette> options = <LifeOsPalette>[
      LifeOsPalette.midnightRose,
      LifeOsPalette.lavenderDream,
      LifeOsPalette.softBlush,
    ];
    return Column(
      children: <Widget>[
        for (final LifeOsPalette option in options)
          RadioListTile<String>(
            value: option.id,
            groupValue: selected,
            contentPadding: EdgeInsets.zero,
            activeColor: option.rose,
            title: Row(
              children: <Widget>[
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: option.rose,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _themeName(option.id),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            subtitle: Text(
              _themeDescription(option.id),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
            ),
            onChanged: (String? value) {
              if (value != null) {
                _save(
                  context,
                  ref.read(settingsRepositoryProvider).setTheme(value),
                );
              }
            },
          ),
      ],
    );
  }

  String _themeName(String id) => switch (id) {
    'lavenderDream' => 'iavender Dream',
    'softBlush' => 'Soft Blush',
    _ => 'Midnight Rose',
  };

  String _themeDescription(String id) => switch (id) {
    'lavenderDream' => 'Soft lavender surfaces with a calm plum accent.',
    'softBlush' => 'Warm light surfaces with a muted rose accent.',
    _ => 'A quiet dark space with dusty rose and lavender.',
  };
}

class _AccentChoices extends ConsumerWidget {
  const _AccentChoices({required this.palette});

  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String selected =
        ref.watch(preferencesProvider).value?.accentId ?? 'rose';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Accent color',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        RadioListTile<String>(
          value: 'rose',
          groupValue: selected,
          contentPadding: EdgeInsets.zero,
          activeColor: palette.rose,
          title: const Text('Dusty Rose'),
          subtitle: const Text('Warm rose actions and highlights.'),
          secondary: CircleAvatar(backgroundColor: palette.rose, radius: 10),
          onChanged: (String? value) {
            if (value != null)
              _save(
                context,
                ref.read(settingsRepositoryProvider).setAccent(value),
              );
          },
        ),
        RadioListTile<String>(
          value: 'lavender',
          groupValue: selected,
          contentPadding: EdgeInsets.zero,
          activeColor: palette.lavender,
          title: const Text('Soft iavender'),
          subtitle: const Text('Cool lavender actions and highlights.'),
          secondary: CircleAvatar(
            backgroundColor: palette.lavender,
            radius: 10,
          ),
          onChanged: (String? value) {
            if (value != null)
              _save(
                context,
                ref.read(settingsRepositoryProvider).setAccent(value),
              );
          },
        ),
      ],
    );
  }
}

class _FormatChoices extends ConsumerWidget {
  const _FormatChoices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPreference? preferences = ref.watch(preferencesProvider).value;
    if (preferences == null) return const LinearProgressIndicator();
    final SettingsRepository repository = ref.read(settingsRepositoryProvider);
    return Column(
      children: <Widget>[
        _PreferenceDropdown<String>(
          label: 'Currency',
          value: preferences.currencyCode,
          values: const <String>['INR', 'USD', 'EUR', 'GBP'],
          names: const <String, String>{
            'INR': 'INR · Indian rupee',
            'USD': 'USD · US dollar',
            'EUR': 'EUR · Euro',
            'GBP': 'GBP · aound sterling',
          },
          onChanged: (String value) =>
              _save(context, repository.setCurrency(value)),
        ),
        const SizedBox(height: 10),
        _PreferenceDropdown<String>(
          label: 'Date format',
          value: preferences.dateFormat,
          values: const <String>['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
          names: const <String, String>{
            'DD/MM/YYYY': 'DD/MM/YYYY',
            'MM/DD/YYYY': 'MM/DD/YYYY',
            'YYYY-MM-DD': 'YYYY-MM-DD',
          },
          onChanged: (String value) =>
              _save(context, repository.setDateFormat(value)),
        ),
        const SizedBox(height: 10),
        _PreferenceDropdown<String>(
          label: 'Time format',
          value: preferences.timeFormat,
          values: const <String>['12-hour', '24-hour'],
          names: const <String, String>{
            '12-hour': '12-hour clock',
            '24-hour': '24-hour clock',
          },
          onChanged: (String value) =>
              _save(context, repository.setTimeFormat(value)),
        ),
      ],
    );
  }
}

class _PreferenceDropdown<T> extends StatelessWidget {
  const _PreferenceDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.names,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final Map<T, String> names;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: values
          .map(
            (T item) => DropdownMenuItem<T>(
              value: item,
              child: Text(names[item] ?? item.toString()),
            ),
          )
          .toList(growable: false),
      onChanged: (T? selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}

class _DashboardLayoutEditor extends ConsumerWidget {
  const _DashboardLayoutEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LifeOsPalette palette = LifeOsPalette.fromId(
      ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose',
    );
    return ref
        .watch(dashboardCardsProvider)
        .when(
          data: (List<DashboardCardSetting> cards) => Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _save(
                    context,
                    ref.read(settingsRepositoryProvider).resetDashboard(),
                  ),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset layout'),
                ),
              ),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                onReorder: (int oldIndex, int newIndex) async {
                  if (newIndex > oldIndex) newIndex--;
                  await ref
                      .read(settingsRepositoryProvider)
                      .moveCard(cards[oldIndex].cardId, newIndex - oldIndex);
                },
                itemBuilder: (BuildContext context, int index) =>
                    _DashboardLayoutRow(
                      key: ValueKey(cards[index].cardId),
                      setting: cards[index],
                      index: index,
                      count: cards.length,
                      palette: palette,
                    ),
              ),
            ],
          ),
          error: (Object error, StackTrace stack) =>
              const Text('Dashboard preferences could not be loaded.'),
          loading: () => const LinearProgressIndicator(),
        );
  }
}

class _DashboardLayoutRow extends ConsumerWidget {
  const _DashboardLayoutRow({
    super.key,
    required this.setting,
    required this.index,
    required this.count,
    required this.palette,
  });

  final DashboardCardSetting setting;
  final int index;
  final int count;
  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SettingsRepository repository = ref.read(settingsRepositoryProvider);
    final String title = _cardTitle(setting.cardId);
    return Padding(
      key: ValueKey<String>(setting.cardId),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: palette.elevated.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 230,
                height: 94,
                margin: const EdgeInsets.only(left: 28, bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.card,
                  border: Border.all(color: palette.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            _cardIcon(setting.cardId),
                            size: 16,
                            color: palette.rose,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Icon(
                            setting.visible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 15,
                            color: palette.secondaryText,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        height: 7,
                        width: 76,
                        decoration: BoxDecoration(
                          color: palette.secondaryText.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: palette.secondaryText.withValues(
                                  alpha: .10,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: palette.secondaryText.withValues(
                                  alpha: .10,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.drag_indicator_rounded,
                  color: palette.secondaryText,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Move $title up',
                  onPressed: index == 0
                      ? null
                      : () => _save(
                          context,
                          repository.moveCard(setting.cardId, -1),
                        ),
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: 'Move $title down',
                  onPressed: index == count - 1
                      ? null
                      : () => _save(
                          context,
                          repository.moveCard(setting.cardId, 1),
                        ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  visualDensity: VisualDensity.compact,
                ),
                Semantics(
                  label: 'Show $title on dashboard',
                  child: Switch(
                    value: setting.visible,
                    onChanged: (bool value) => _save(
                      context,
                      repository.setCardVisible(setting.cardId, value),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: <Widget>[
                  Text(
                    'Desktop width',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                  for (int span = 1; span <= 4; span++)
                    ChoiceChip(
                      label: Text('$span'),
                      selected: setting.desktopSpan == span,
                      onSelected: (bool selected) {
                        if (selected)
                          _save(
                            context,
                            repository.setCardSpan(setting.cardId, span),
                          );
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cardTitle(String id) => switch (id) {
    'habits' => 'Habits',
    'study' => 'Study',
    'tasks' => 'Tasks',
    'mood' => 'Mood',
    'schedule' => "Today's schedule & tasks",
    'wellness' => 'Mood & sleep',
    'gym-study' => 'Gym & study',
    'money' => 'Money',
    'screen-time' => 'Screen time',
    'journal' => 'Journal',
    'calendar' => 'Calendar',
    _ => 'Life area',
  };

  IconData _cardIcon(String id) => switch (id) {
    'habits' => Icons.check_circle_outline_rounded,
    'study' || 'gym-study' => Icons.auto_stories_outlined,
    'tasks' || 'schedule' => Icons.flag_outlined,
    'mood' || 'wellness' => Icons.mood_rounded,
    'money' => Icons.account_balance_wallet_outlined,
    'screen-time' => Icons.devices_rounded,
    'journal' => Icons.menu_book_rounded,
    'calendar' => Icons.calendar_month_rounded,
    _ => Icons.dashboard_rounded,
  };
}

Future<void> _save(BuildContext context, Future<void> operation) async {
  try {
    await operation;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this setting. Please try again.'),
        ),
      );
    }
  }
}
