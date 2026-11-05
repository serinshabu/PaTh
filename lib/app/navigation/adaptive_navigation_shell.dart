import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app_providers.dart';
import '../../data/database/life_os_database.dart';
import '../../data/sync/sync_runtime.dart';
import '../theme/life_os_palette.dart';
import '../../features/dashboard/quick_add_sheet.dart';
import 'destinations.dart';

class AdaptiveNavigationShell extends ConsumerWidget {
  const AdaptiveNavigationShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LifeOsDestination? destination = destinationForPath(location);
    final bool isDashboard = location == '/dashboard';
    final double width = MediaQuery.sizeOf(context).width;
    final bool desktop = width >= 1000;
    final bool showSidebar = width >= 760;
    final AppPreference? preferences = ref.watch(preferencesProvider).value;
    final SyncStatus syncStatus = ref.watch(syncStatusProvider);
    final bool collapsed = preferences?.sidebarCollapsed ?? false;
    final String title = isDashboard
        ? _greeting()
        : destination?.title ?? 'PaTh';
    final String subtitle = isDashboard
        ? DateFormat(
            _datePattern(preferences?.dateFormat ?? 'DD/MM/YYYY'),
          ).format(DateTime.now())
        : destination?.description ?? 'Your personal space';

    final PreferredSizeWidget header = AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: LifeOsPalette.fromId(
                ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose',
              ).secondaryText,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        if (desktop)
          TextButton.icon(
            onPressed: () => showQuickAddSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Quick add'),
          ),
        if (desktop)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Tooltip(
                message: _syncTooltip(syncStatus),
                child: _SyncStatusChip(
                  status: syncStatus,
                  palette: LifeOsPalette.fromId(
                    preferences?.themeId ?? 'midnightRose',
                  ),
                ),
              ),
            ),
          ),
        if (!desktop)
          if (!showSidebar)
            IconButton(
              tooltip: 'Browse trackers',
              onPressed: () => _showTrackerMenu(context),
              icon: const Icon(Icons.grid_view_rounded),
            ),
        if (!desktop)
          IconButton(
            tooltip:
                '${_syncLabel(syncStatus)}; open privacy and sync settings',
            onPressed: () => context.go('/settings'),
            icon: Icon(_syncIcon(syncStatus.phase)),
          ),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
        const SizedBox(width: 8),
      ],
    );

    if (showSidebar) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: <Widget>[
              _LifeOsSidebar(
                location: location,
                collapsed: desktop ? collapsed : true,
                canCollapse: desktop,
              ),
              Expanded(
                child: Scaffold(
                  appBar: header,
                  body: SafeArea(child: child),
                  floatingActionButton: desktop
                      ? null
                      : FloatingActionButton.extended(
                          onPressed: () => showQuickAddSheet(context),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Quick add'),
                          tooltip: 'Quick add a record',
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final int selectedIndex = primaryDestinations.indexWhere(
      (LifeOsDestination item) => item.path == location,
    );
    return Scaffold(
      appBar: header,
      body: SafeArea(child: child),
      floatingActionButton: width < 1000
          ? FloatingActionButton.extended(
              onPressed: () => showQuickAddSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Quick add'),
              tooltip: 'Quick add a record',
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        onDestinationSelected: (int index) =>
            context.go(primaryDestinations[index].path),
        destinations: primaryDestinations
            .map(
              (LifeOsDestination item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
                tooltip: item.label,
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Future<void> _showTrackerMenu(BuildContext context) async {
    final String? path = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .6,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Text(
                  'Your trackers',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              for (final LifeOsDestination tracker in trackerDestinations)
                ListTile(
                  leading: Icon(tracker.icon),
                  title: Text(tracker.label),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(sheetContext).pop(tracker.path),
                ),
            ],
          ),
        ),
      ),
    );
    if (path != null && context.mounted) context.go(path);
  }

  String _datePattern(String format) => switch (format) {
    'MM/DD/YYYY' => 'MM/dd/yyyy',
    'YYYY-MM-DD' => 'yyyy-MM-dd',
    _ => 'dd/MM/yyyy',
  };

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _LifeOsSidebar extends ConsumerWidget {
  const _LifeOsSidebar({
    required this.location,
    required this.collapsed,
    required this.canCollapse,
  });

  final String location;
  final bool collapsed;
  final bool canCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LifeOsPalette palette = LifeOsPalette.fromId(
      ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose',
    );
    final SyncStatus syncStatus = ref.watch(syncStatusProvider);
    final double width = collapsed ? 76 : 248;
    final bool disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return AnimatedContainer(
      duration: disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: width,
      color: palette.sidebar,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(collapsed ? 8 : 18, 20, 10, 14),
            child: Row(
              children: <Widget>[
                if (!collapsed) ...<Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: palette.rose.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: palette.rose,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'PaTh',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Your personal space',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: palette.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ] else
                  const Spacer(),
                if (canCollapse)
                  IconButton(
                    tooltip: collapsed
                        ? 'Expand navigation'
                        : 'Collapse navigation',
                    onPressed: () async => ref
                        .read(settingsRepositoryProvider)
                        .setSidebarCollapsed(!collapsed),
                    icon: Icon(
                      collapsed
                          ? Icons.keyboard_double_arrow_right_rounded
                          : Icons.keyboard_double_arrow_left_rounded,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 12),
              children: <Widget>[
                for (final LifeOsDestination item in primaryDestinations)
                  _SidebarItem(
                    destination: item,
                    selected: location == item.path,
                    collapsed: collapsed,
                  ),
                if (!collapsed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 22, 12, 8),
                    child: Text(
                      'YOUR TRACKERS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: palette.secondaryText,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                for (final LifeOsDestination item in trackerDestinations)
                  _SidebarItem(
                    destination: item,
                    selected: location == item.path,
                    collapsed: collapsed,
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: palette.border),
          _SidebarItem(
            destination: settingsDestination,
            selected: location == settingsDestination.path,
            collapsed: collapsed,
          ),
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: <Widget>[
                  Icon(
                    _syncIcon(syncStatus.phase),
                    size: 15,
                    color: _syncColor(syncStatus.phase, palette),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${_syncLabel(syncStatus)} · v0.1.0',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SidebarItem extends ConsumerWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.collapsed,
  });

  final LifeOsDestination destination;
  final bool selected;
  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LifeOsPalette palette = LifeOsPalette.fromId(
      ref.watch(preferencesProvider).value?.themeId ?? 'midnightRose',
    );
    final Color accent = Theme.of(context).colorScheme.primary;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Tooltip(
        message: destination.label,
        child: Material(
          color: selected ? accent.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.go(destination.path),
            child: SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: collapsed ? 0 : 14,
                    child: selected
                        ? Container(
                            width: 3,
                            height: 22,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          )
                        : null,
                  ),
                  if (!collapsed) const SizedBox(width: 8),
                  Icon(
                    destination.icon,
                    size: 19,
                    color: selected ? accent : palette.secondaryText,
                  ),
                  if (!collapsed) ...<Widget>[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected ? textColor : palette.secondaryText,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SyncStatusChip extends StatelessWidget {
  const _SyncStatusChip({required this.status, required this.palette});

  final SyncStatus status;
  final LifeOsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            _syncIcon(status.phase),
            size: 16,
            color: _syncColor(status.phase, palette),
          ),
          const SizedBox(width: 6),
          Text(
            _syncLabel(status),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

String _syncLabel(SyncStatus status) => switch (status.phase) {
  SyncPhase.notConfigured => 'Local only',
  SyncPhase.synced =>
    status.lastSyncedAt == null
        ? 'Synced'
        : 'Synced ${_relativeSyncTime(status.lastSyncedAt!)}',
  SyncPhase.syncing => 'Syncing',
  SyncPhase.offline => 'Offline',
  SyncPhase.pending =>
    '${status.pending} change${status.pending == 1 ? '' : 's'} waiting',
  SyncPhase.error => 'Sync error',
  SyncPhase.conflict =>
    'Review ${status.conflicts} conflict${status.conflicts == 1 ? '' : 's'}',
};

String _relativeSyncTime(DateTime value) {
  final Duration elapsed = DateTime.now().difference(value.toLocal());
  if (elapsed.inSeconds < 60) return 'just now';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
  if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
  return DateFormat('d MMM').format(value.toLocal());
}

String _syncTooltip(SyncStatus status) => switch (status.phase) {
  SyncPhase.notConfigured => 'Pair a device in Settings → Privacy and sync.',
  SyncPhase.synced =>
    status.lastSyncedAt == null
        ? 'All changes are synced.'
        : 'Last successful sync: ${status.lastSyncedAt!.toLocal()}',
  SyncPhase.syncing => 'PaTh is synchronizing your changes.',
  SyncPhase.offline => 'Offline. Changes are saved locally and will retry.',
  SyncPhase.pending => '${status.pending} local changes are waiting to sync.',
  SyncPhase.error => status.message ?? 'Sync failed. Open Settings to retry.',
  SyncPhase.conflict => status.message ?? 'Review sync conflicts in Settings.',
};

IconData _syncIcon(SyncPhase phase) => switch (phase) {
  SyncPhase.notConfigured => Icons.cloud_off_outlined,
  SyncPhase.synced => Icons.cloud_done_outlined,
  SyncPhase.syncing => Icons.sync_rounded,
  SyncPhase.offline => Icons.cloud_off_outlined,
  SyncPhase.pending => Icons.cloud_upload_outlined,
  SyncPhase.error => Icons.cloud_off_outlined,
  SyncPhase.conflict => Icons.sync_problem_rounded,
};

Color _syncColor(SyncPhase phase, LifeOsPalette palette) => switch (phase) {
  SyncPhase.notConfigured => palette.secondaryText,
  SyncPhase.synced => palette.positive,
  SyncPhase.syncing => palette.lavender,
  SyncPhase.offline => palette.warning,
  SyncPhase.pending => palette.warning,
  SyncPhase.error => palette.negative,
  SyncPhase.conflict => palette.negative,
};
