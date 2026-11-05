import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:life_os/app/app_providers.dart';
import 'package:life_os/app/life_os_app.dart';
import 'package:life_os/app/navigation/life_os_router.dart';
import 'package:life_os/app/theme/life_os_palette.dart';
import 'package:life_os/data/database/life_os_database.dart';
import 'package:life_os/data/records/records_repository.dart';
import 'package:life_os/features/empty_state/feature_page.dart';

void main() {
  testWidgets('tracker recent trend reflects saved records', (
    WidgetTester tester,
  ) async {
    final LifeOsDatabase database = LifeOsDatabase.forTesting(
      NativeDatabase.memory(),
    );
    final RecordsRepository repository = RecordsRepository(database);
    await repository.save(
      kind: 'mood',
      title: 'Calm',
      date: DateTime(2026, 10, 22),
      value: 7,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lifeOsDatabaseProvider.overrideWith((Ref ref) => database),
          recordsRepositoryProvider.overrideWith((Ref ref) => repository),
          preferencesProvider.overrideWith(
            (Ref ref) => Stream<AppPreference>.value(
              const AppPreference(
                id: 1,
                themeId: 'midnightRose',
                accentId: 'rose',
                currencyCode: 'INR',
                dateFormat: 'DD/MM/YYYY',
                timeFormat: '12-hour',
                sidebarCollapsed: false,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: RecordsPage(
            kind: 'mood',
            title: 'Mood',
            description: 'Mood check-ins',
            icon: Icons.mood,
            currency: 'INR',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent mood ratings'), findsOneWidget);
    expect(find.text('Calm'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 2));
    await tester.runAsync(database.close);
    await tester.pump();
  });

  testWidgets('mobile quick add opens the selected tracker form directly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final LifeOsDatabase database = LifeOsDatabase.forTesting(
      NativeDatabase.memory(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lifeOsDatabaseProvider.overrideWith((Ref ref) => database),
          preferencesProvider.overrideWith(
            (Ref ref) => Stream<AppPreference>.value(
              const AppPreference(
                id: 1,
                themeId: 'midnightRose',
                accentId: 'rose',
                currencyCode: 'INR',
                dateFormat: 'DD/MM/YYYY',
                timeFormat: '12-hour',
                sidebarCollapsed: false,
              ),
            ),
          ),
          dashboardCardsProvider.overrideWith(
            (Ref ref) => Stream<List<DashboardCardSetting>>.value(
              const <DashboardCardSetting>[],
            ),
          ),
        ],
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) =>
              MaterialApp.router(
                routerConfig: ref.watch(lifeOsRouterProvider),
                theme: LifeOsPalette.midnightRose.toTheme(),
              ),
        ),
      ),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 2),
    );

    expect(find.byTooltip('Quick add a record'), findsOneWidget);
    expect(find.byTooltip('Browse trackers'), findsOneWidget);
    await tester.tap(find.byTooltip('Quick add a record'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 2),
    );
    expect(find.text('Mood check-in'), findsOneWidget);
    await tester.tap(find.text('Mood check-in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Add mood check-in'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.runAsync(database.close);
    await tester.pump();
  });

  testWidgets('Life OS opens on its real dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWith(
            (Ref ref) => Stream<AppPreference>.value(
              const AppPreference(
                id: 1,
                themeId: 'midnightRose',
                accentId: 'rose',
                currencyCode: 'INR',
                dateFormat: 'DD/MM/YYYY',
                timeFormat: '12-hour',
                sidebarCollapsed: false,
              ),
            ),
          ),
          dashboardCardsProvider.overrideWith(
            (Ref ref) => Stream<List<DashboardCardSetting>>.value(
              const <DashboardCardSetting>[],
            ),
          ),
        ],
        child: const LifeOsApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Your day, at a glance'), findsOneWidget);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });

  testWidgets('dashboard remains usable with enlarged text on a phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWith(
            (Ref ref) => Stream<AppPreference>.value(
              const AppPreference(
                id: 1,
                themeId: 'midnightRose',
                accentId: 'rose',
                currencyCode: 'INR',
                dateFormat: 'DD/MM/YYYY',
                timeFormat: '12-hour',
                sidebarCollapsed: false,
              ),
            ),
          ),
          dashboardCardsProvider.overrideWith(
            (Ref ref) => Stream<List<DashboardCardSetting>>.value(
              const <DashboardCardSetting>[],
            ),
          ),
        ],
        child: const MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: const LifeOsApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your day, at a glance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Analytics opens on live empty-state reports without fake data', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final LifeOsDatabase database = LifeOsDatabase.forTesting(
      NativeDatabase.memory(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lifeOsDatabaseProvider.overrideWith((Ref ref) => database),
          preferencesProvider.overrideWith(
            (Ref ref) => Stream<AppPreference>.value(
              const AppPreference(
                id: 1,
                themeId: 'midnightRose',
                accentId: 'rose',
                currencyCode: 'INR',
                dateFormat: 'DD/MM/YYYY',
                timeFormat: '12-hour',
                sidebarCollapsed: false,
              ),
            ),
          ),
          dashboardCardsProvider.overrideWith(
            (Ref ref) => Stream<List<DashboardCardSetting>>.value(
              const <DashboardCardSetting>[],
            ),
          ),
        ],
        child: const LifeOsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();

    expect(find.text('Each area is tracked separately'), findsOneWidget);
    expect(find.text('Period comparison'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 2));
    await tester.runAsync(database.close);
    await tester.pump();
  });
}
