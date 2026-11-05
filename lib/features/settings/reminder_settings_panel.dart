import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_providers.dart';
import '../../data/settings/settings_repository.dart';
import '../device/device_feature_bridge.dart';

class ReminderSettingsPanel extends ConsumerWidget {
  const ReminderSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DeviceFeaturePreferences> settings = ref.watch(
      deviceFeaturePreferencesProvider,
    );
    return settings.when(
      loading: () => const LinearProgressIndicator(),
      error: (Object error, StackTrace stack) =>
          const Text('Reminder preferences could not be loaded.'),
      data: (DeviceFeaturePreferences value) => _ReminderControls(
        value: value,
        save: (DeviceFeaturePreferences next) => _save(context, ref, next),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    DeviceFeaturePreferences value,
  ) async {
    try {
      await ref
          .read(settingsRepositoryProvider)
          .saveDeviceFeaturePreferences(value);
      await const DeviceFeatureBridge().configureReminders(value);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder settings could not be saved.'),
          ),
        );
      }
    }
  }
}

class _ReminderControls extends ConsumerWidget {
  const _ReminderControls({required this.value, required this.save});

  final DeviceFeaturePreferences value;
  final ValueChanged<DeviceFeaturePreferences> save;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceFeatureBridge bridge = const DeviceFeatureBridge();
    final bool android = bridge.supportsAndroidNotifications;
    return Column(
      children: <Widget>[
        if (android)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () async {
                final bool granted = await bridge
                    .requestNotificationPermission();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        granted
                            ? 'Notifications are enabled on this device.'
                            : 'Notifications remain off. You can enable them in Android Settings.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Allow notifications'),
            ),
          )
        else
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Windows reminder support'),
            subtitle: Text(
              'Windows reminders appear inside PaTh while it is open. Android can deliver scheduled system notifications even when the app is closed.',
            ),
          ),
        _ReminderRow(
          title: 'Habit reminder',
          subtitle: 'A gentle nudge for today’s routines.',
          enabled: value.habitEnabled,
          time: TimeOfDay(hour: value.habitHour, minute: value.habitMinute),
          onEnabled: (bool enabled) =>
              save(value.copyWith(habitEnabled: enabled)),
          onTime: (TimeOfDay time) => save(
            value.copyWith(habitHour: time.hour, habitMinute: time.minute),
          ),
          showTime: true,
        ),
        _ReminderRow(
          title: 'Task reminder',
          subtitle: 'Check deadlines and what is next.',
          enabled: value.taskEnabled,
          time: TimeOfDay(hour: value.taskHour, minute: value.taskMinute),
          onEnabled: (bool enabled) =>
              save(value.copyWith(taskEnabled: enabled)),
          onTime: (TimeOfDay time) => save(
            value.copyWith(taskHour: time.hour, taskMinute: time.minute),
          ),
          showTime: true,
        ),
        _ReminderRow(
          title: 'Evening review',
          subtitle: 'Reflect on the day you actually had.',
          enabled: value.reviewEnabled,
          time: TimeOfDay(hour: value.reviewHour, minute: value.reviewMinute),
          onEnabled: (bool enabled) =>
              save(value.copyWith(reviewEnabled: enabled)),
          onTime: (TimeOfDay time) => save(
            value.copyWith(reviewHour: time.hour, reviewMinute: time.minute),
          ),
          showTime: true,
        ),
        _ReminderRow(
          title: 'Morning planning',
          subtitle: 'Set a kind intention for the day.',
          enabled: value.planningEnabled,
          time: TimeOfDay(
            hour: value.planningHour,
            minute: value.planningMinute,
          ),
          onEnabled: (bool enabled) =>
              save(value.copyWith(planningEnabled: enabled)),
          onTime: (TimeOfDay time) => save(
            value.copyWith(
              planningHour: time.hour,
              planningMinute: time.minute,
            ),
          ),
          showTime: true,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Quiet hours'),
          subtitle: const Text('Suppress reminders overnight.'),
          value: value.quietHoursEnabled,
          onChanged: (bool enabled) =>
              save(value.copyWith(quietHoursEnabled: enabled)),
        ),
        if (value.quietHoursEnabled)
          Wrap(
            spacing: 8,
            children: <Widget>[
              _QuietTimeButton(
                label: 'Quiet starts',
                value: TimeOfDay(hour: value.quietStartHour, minute: 0),
                onChanged: (TimeOfDay time) =>
                    save(value.copyWith(quietStartHour: time.hour)),
              ),
              _QuietTimeButton(
                label: 'Quiet ends',
                value: TimeOfDay(hour: value.quietEndHour, minute: 0),
                onChanged: (TimeOfDay time) =>
                    save(value.copyWith(quietEndHour: time.hour)),
              ),
            ],
          ),
        if (!android && !kIsWeb)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Windows in-app reminders need PaTh to remain open. Android is required for scheduled system alerts while the app is closed.',
            ),
          ),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.time,
    required this.onEnabled,
    required this.onTime,
    required this.showTime,
  });

  final String title;
  final String subtitle;
  final bool enabled;
  final TimeOfDay time;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<TimeOfDay> onTime;
  final bool showTime;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: Text(subtitle),
        value: enabled,
        onChanged: onEnabled,
      ),
      if (enabled && showTime)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () async {
              final TimeOfDay? selected = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (selected != null) onTime(selected);
            },
            icon: const Icon(Icons.schedule_rounded),
            label: Text('Daily at ${time.format(context)}'),
          ),
        ),
    ],
  );
}

class _QuietTimeButton extends StatelessWidget {
  const _QuietTimeButton({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () async {
      final TimeOfDay? selected = await showTimePicker(
        context: context,
        initialTime: value,
      );
      if (selected != null) onChanged(selected);
    },
    icon: const Icon(Icons.bedtime_outlined),
    label: Text('$label · ${value.format(context)}'),
  );
}
