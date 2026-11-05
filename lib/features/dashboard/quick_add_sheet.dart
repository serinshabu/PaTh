import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showQuickAddSheet(BuildContext context) async {
  const List<(String, String, IconData)> actions = <(String, String, IconData)>[
    ('Habit', '/habits', Icons.check_circle_outline_rounded),
    ('Task or goal', '/tasks', Icons.flag_outlined),
    ('Study session', '/study', Icons.auto_stories_outlined),
    ('Mood check-in', '/mood', Icons.mood_rounded),
    ('Gym visit', '/gym', Icons.fitness_center_rounded),
    ('Journal entry', '/journal', Icons.menu_book_rounded),
    ('Expense', '/money', Icons.account_balance_wallet_outlined),
    ('Sleep record', '/sleep', Icons.nightlight_round),
    ('Period record', '/period', Icons.water_drop_outlined),
    ('Screen-time record', '/screen-time', Icons.devices_rounded),
  ];
  final String? route = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      final double height = math.min(
        MediaQuery.sizeOf(sheetContext).height * .72,
        620,
      );
      return SafeArea(
        child: SizedBox(
          height: height,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            children: <Widget>[
              Text(
                'Quick add',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a record to add. The entry form opens right away.',
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              for (final (String label, String path, IconData icon) in actions)
                ListTile(
                  leading: Icon(icon),
                  title: Text(label),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  minVerticalPadding: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () =>
                      Navigator.of(sheetContext).pop('$path?quickAdd=1'),
                ),
            ],
          ),
        ),
      );
    },
  );
  if (route != null && context.mounted) context.go(route);
}
