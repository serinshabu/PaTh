import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app/app_providers.dart';
import '../database/life_os_database.dart';
import 'sync_credentials.dart';
import 'sync_engine.dart';

enum SyncPhase {
  notConfigured,
  synced,
  syncing,
  offline,
  pending,
  error,
  conflict,
}

class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.notConfigured,
    this.pending = 0,
    this.conflicts = 0,
    this.lastSyncedAt,
    this.message,
  });
  final SyncPhase phase;
  final int pending;
  final int conflicts;
  final DateTime? lastSyncedAt;
  final String? message;
}

class SyncStatusController extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => const SyncStatus();
  void setStatus(SyncStatus value) => state = value;
}

final NotifierProvider<SyncStatusController, SyncStatus> syncStatusProvider =
    NotifierProvider<SyncStatusController, SyncStatus>(
      SyncStatusController.new,
    );

final Provider<SyncCredentialsStore> syncCredentialsStoreProvider =
    Provider<SyncCredentialsStore>(
      (Ref ref) => const SyncCredentialsStore(FlutterSecureStorage()),
    );

final Provider<SyncEngine> syncEngineProvider = Provider<SyncEngine>(
  (Ref ref) => SyncEngine(ref.watch(lifeOsDatabaseProvider)),
);

final Provider<SyncRunner> syncRunnerProvider = Provider<SyncRunner>((Ref ref) {
  final SyncRunner runner = SyncRunner(
    engine: ref.watch(syncEngineProvider),
    credentials: ref.watch(syncCredentialsStoreProvider),
    onStatus: (SyncStatus status) =>
        ref.read(syncStatusProvider.notifier).setStatus(status),
  )..start();
  ref.onDispose(runner.dispose);
  return runner;
});

class SyncRunner with WidgetsBindingObserver {
  SyncRunner({
    required this.engine,
    required this.credentials,
    required this.onStatus,
  });
  final SyncEngine engine;
  final SyncCredentialsStore credentials;
  final void Function(SyncStatus) onStatus;
  Timer? _timer;
  bool _running = false;
  bool _disposed = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    unawaited(runNow());
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(runNow()),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(runNow());
  }

  Future<void> runNow() async {
    if (_running || _disposed) return;
    _running = true;
    try {
      final SyncCredentials? configured = await credentials.read();
      if (configured == null) {
        onStatus(const SyncStatus(phase: SyncPhase.notConfigured));
        return;
      }
      final int pendingBefore = await engine.pendingCount();
      onStatus(
        SyncStatus(
          phase: pendingBefore > 0 ? SyncPhase.pending : SyncPhase.syncing,
          pending: pendingBefore,
        ),
      );
      try {
        await engine.synchronize(configured);
        final int pending = await engine.pendingCount();
        final String? last = await engine.lastSuccessfulSync();
        final List<SyncConflict> conflicts = await engine
            .watchOpenConflicts()
            .first;
        onStatus(
          SyncStatus(
            phase: conflicts.isNotEmpty
                ? SyncPhase.conflict
                : (pending > 0 ? SyncPhase.pending : SyncPhase.synced),
            pending: pending,
            conflicts: conflicts.length,
            lastSyncedAt: last == null ? null : DateTime.tryParse(last),
            message: conflicts.isEmpty
                ? null
                : '${conflicts.length} conflict${conflicts.length == 1 ? '' : 's'} need review.',
          ),
        );
      } on SocketException {
        onStatus(
          SyncStatus(
            phase: SyncPhase.offline,
            pending: await engine.pendingCount(),
          ),
        );
      } on HttpException {
        onStatus(
          SyncStatus(
            phase: SyncPhase.offline,
            pending: await engine.pendingCount(),
          ),
        );
      } on TimeoutException {
        onStatus(
          SyncStatus(
            phase: SyncPhase.offline,
            pending: await engine.pendingCount(),
          ),
        );
      } catch (error) {
        onStatus(
          SyncStatus(
            phase: SyncPhase.error,
            pending: await engine.pendingCount(),
            message: error.toString(),
          ),
        );
      }
    } finally {
      _running = false;
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}

String syncPhaseLabel(SyncPhase phase) => switch (phase) {
  SyncPhase.notConfigured => 'Sync not configured',
  SyncPhase.synced => 'Synced',
  SyncPhase.syncing => 'Syncing',
  SyncPhase.offline => 'Offline',
  SyncPhase.pending => 'Pending changes',
  SyncPhase.error => 'Sync error',
  SyncPhase.conflict => 'Conflict needs attention',
};
