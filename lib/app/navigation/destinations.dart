import 'package:flutter/material.dart';

@immutable
class LifeOsDestination {
  const LifeOsDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String path;
  final String label;
  final IconData icon;
  final String title;
  final String description;
}

const List<LifeOsDestination> primaryDestinations = <LifeOsDestination>[
  LifeOsDestination(
    path: '/dashboard',
    label: 'Dashboard',
    icon: Icons.dashboard_rounded,
    title: 'Dashboard',
    description: 'Your personal command center.',
  ),
  LifeOsDestination(
    path: '/calendar',
    label: 'Calendar',
    icon: Icons.calendar_month_rounded,
    title: 'Calendar',
    description: 'A calm view of your days and activity.',
  ),
  LifeOsDestination(
    path: '/analytics',
    label: 'Analytics',
    icon: Icons.insights_rounded,
    title: 'Analytics',
    description:
        'Patterns, comparisons, and progress across your recorded life.',
  ),
  LifeOsDestination(
    path: '/journal',
    label: 'Journal',
    icon: Icons.menu_book_rounded,
    title: 'Journal',
    description: 'A private space for your reflections.',
  ),
];

const List<LifeOsDestination> trackerDestinations = <LifeOsDestination>[
  LifeOsDestination(
    path: '/habits',
    label: 'Habits',
    icon: Icons.check_circle_outline_rounded,
    title: 'Habits',
    description: 'Routines and habits, recorded at your pace.',
  ),
  LifeOsDestination(
    path: '/tasks',
    label: 'Tasks & Goals',
    icon: Icons.flag_outlined,
    title: 'Tasks & Goals',
    description: 'Keep plans and longer-term goals together.',
  ),
  LifeOsDestination(
    path: '/study',
    label: 'Study',
    icon: Icons.auto_stories_outlined,
    title: 'Study',
    description: 'Sessions, subjects, and learning progress.',
  ),
  LifeOsDestination(
    path: '/gym',
    label: 'Gym',
    icon: Icons.fitness_center_rounded,
    title: 'Gym',
    description: 'Attendance and personal consistency.',
  ),
  LifeOsDestination(
    path: '/mood',
    label: 'Mood',
    icon: Icons.mood_rounded,
    title: 'Mood',
    description: 'Gentle check-ins and personal context.',
  ),
  LifeOsDestination(
    path: '/sleep',
    label: 'Sleep',
    icon: Icons.nightlight_round,
    title: 'Sleep',
    description: 'Rest patterns and sleep quality.',
  ),
  LifeOsDestination(
    path: '/period',
    label: 'Period',
    icon: Icons.water_drop_outlined,
    title: 'Period',
    description: 'Private cycle and symptom history.',
  ),
  LifeOsDestination(
    path: '/money',
    label: 'Money',
    icon: Icons.account_balance_wallet_outlined,
    title: 'Money',
    description: 'Spending, budgets, and savings goals.',
  ),
  LifeOsDestination(
    path: '/screen-time',
    label: 'Screen Time',
    icon: Icons.devices_rounded,
    title: 'Screen Time',
    description: 'Manual and supported device usage records.',
  ),
];

const LifeOsDestination settingsDestination = LifeOsDestination(
  path: '/settings',
  label: 'Settings',
  icon: Icons.settings_outlined,
  title: 'Settings',
  description: 'Make PaTh feel like your own space.',
);

LifeOsDestination? destinationForPath(String path) {
  for (final LifeOsDestination destination in <LifeOsDestination>[
    ...primaryDestinations,
    ...trackerDestinations,
    settingsDestination,
  ]) {
    if (destination.path == path) {
      return destination;
    }
  }
  return null;
}
