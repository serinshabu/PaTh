import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/dashboard_page.dart';
import '../../features/dashboard/daily_review_page.dart';
import '../../features/calendar/calendar_page.dart';
import '../../features/analytics/analytics_page.dart';
import '../../features/empty_state/feature_page.dart';
import '../../features/settings/settings_page.dart';
import 'adaptive_navigation_shell.dart';
import 'destinations.dart';

final Provider<GoRouter> lifeOsRouterProvider = Provider<GoRouter>((Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        redirect: (BuildContext context, GoRouterState state) => '/dashboard',
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            AdaptiveNavigationShell(location: state.uri.path, child: child),
        routes: <RouteBase>[
          GoRoute(
            path: '/dashboard',
            builder: (BuildContext context, GoRouterState state) =>
                const DashboardPage(),
          ),
          GoRoute(
            path: '/daily-review',
            builder: (BuildContext context, GoRouterState state) =>
                const DailyReviewPage(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (BuildContext context, GoRouterState state) =>
                const CalendarPage(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (BuildContext context, GoRouterState state) =>
                const AnalyticsPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (BuildContext context, GoRouterState state) =>
                const SettingsPage(),
          ),
          for (final LifeOsDestination destination in <LifeOsDestination>[
            ...primaryDestinations
                .skip(1)
                .where(
                  (LifeOsDestination destination) =>
                      destination.path != '/calendar' &&
                      destination.path != '/analytics',
                ),
            ...trackerDestinations,
          ])
            GoRoute(
              path: destination.path,
              builder: (BuildContext context, GoRouterState state) =>
                  FeaturePage(
                    destination: destination,
                    openQuickAdd: state.uri.queryParameters['quickAdd'] == '1',
                  ),
            ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
