import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../database/life_os_database.dart';
import 'sync_api_client.dart';
import 'sync_credentials.dart';
import 'sync_crypto.dart';

class SyncEngine {
  SyncEngine(this._db);
  final LifeOsDatabase _db;

  Stream<List<SyncConflict>> watchOpenConflicts() =>
      (_db.select(_db.syncConflicts)
            ..where((SyncConflicts t) => t.resolution.isNull())
            ..orderBy(<OrderClauseGenerator<SyncConflicts>>[
              (SyncConflicts t) => OrderingTerm.desc(t.detectedAt),
            ]))
          .watch();

  Future<int> pendingCount() async =>
      (await _db.select(_db.syncPendingChanges).get()).length;

  Future<String?> lastSuccessfulSync() async => _getMeta('lastSuccessfulSync');

  Future<void> synchronize(SyncCredentials credentials) async {
    final SyncApiClient api = SyncApiClient(
      credentials.serverUrl,
      token: credentials.deviceToken,
    );
    try {
      final Map<String, dynamic> config = await api.config();
      final SyncCrypto crypto = await SyncCrypto.fromRecoverySecret(
        recoverySecret: credentials.recoverySecret,
        saltBase64: config['keySalt'] as String,
        iterations: config['kdfIterations'] as int,
      );
      await _push(api, crypto);
      await _pull(api, crypto);
      await _setMeta(
        'lastSuccessfulSync',
        DateTime.now().toUtc().toIso8601String(),
      );
    } finally {
      api.close();
    }
  }

  Future<void> _push(SyncApiClient api, SyncCrypto crypto) async {
    final List<SyncPendingChange> pending =
        await (_db.select(_db.syncPendingChanges)
              ..orderBy(<OrderClauseGenerator<SyncPendingChanges>>[
                (SyncPendingChanges t) => OrderingTerm.asc(t.enqueuedAt),
              ]))
            .get();
    for (int offset = 0; offset < pending.length; offset += 100) {
      final List<SyncPendingChange> batch = pending
          .skip(offset)
          .take(100)
          .toList();
      final List<Map<String, dynamic>> outgoing = <Map<String, dynamic>>[];
      for (final SyncPendingChange change in batch) {
        outgoing.add(<String, dynamic>{
          'changeId': change.changeId.isEmpty ? change.id : change.changeId,
          'entityType': change.entityType,
          'entityId': change.entityId,
          'operation': change.operation,
          'baseRevision': change.baseRevision,
          if (change.operation != 'delete')
            'payload': await crypto.encrypt(
              jsonDecode(change.payloadJson) as Map<String, dynamic>,
            ),
        });
      }
      final Map<String, dynamic> response = await api.push(outgoing);
      for (final dynamic raw
          in response['acknowledgements'] as List<dynamic>? ?? <dynamic>[]) {
        final Map<String, dynamic> ack = raw as Map<String, dynamic>;
        final String changeId = ack['changeId'] as String;
        final SyncPendingChange? change = batch
            .where(
              (SyncPendingChange item) =>
                  (item.changeId.isEmpty ? item.id : item.changeId) == changeId,
            )
            .firstOrNull;
        if (change == null) continue;
        await _db.transaction(() async {
          await (_db.delete(_db.syncPendingChanges)..where(
                (SyncPendingChanges t) =>
                    t.id.equals(change.id) & t.changeId.equals(change.changeId),
              ))
              .go();
          final int revision = int.parse(ack['revision'].toString());
          final SyncPendingChange? newer =
              await (_db.select(_db.syncPendingChanges)
                    ..where((SyncPendingChanges t) => t.id.equals(change.id)))
                  .getSingleOrNull();
          if (newer != null && newer.changeId != change.changeId) {
            await (_db.update(
              _db.syncPendingChanges,
            )..where((SyncPendingChanges t) => t.id.equals(newer.id))).write(
              SyncPendingChangesCompanion(baseRevision: Value<int?>(revision)),
            );
          }
          await _setMeta(
            'revision:${change.entityType}:${change.entityId}',
            revision.toString(),
          );
        });
      }
      for (final dynamic raw
          in response['conflicts'] as List<dynamic>? ?? <dynamic>[]) {
        final Map<String, dynamic> conflict = raw as Map<String, dynamic>;
        final String type = conflict['entityType'] as String;
        final String entityId = conflict['entityId'] as String;
        final SyncPendingChange? change = batch
            .where(
              (SyncPendingChange item) =>
                  item.entityType == type && item.entityId == entityId,
            )
            .firstOrNull;
        if (change != null)
          await _saveConflict(
            change,
            conflict['remotePayload'] as String?,
            (conflict['remoteRevision'] as num?)?.toInt() ?? 0,
          );
      }
    }
  }

  Future<void> _pull(SyncApiClient api, SyncCrypto crypto) async {
    String cursor = await _getMeta('serverCursor') ?? '0';
    bool more = true;
    while (more) {
      final Map<String, dynamic> page = await api.pull(cursor: cursor);
      final List<dynamic> changes =
          page['changes'] as List<dynamic>? ?? <dynamic>[];
      for (final dynamic raw in changes) {
        final Map<String, dynamic> change = raw as Map<String, dynamic>;
        final String type = change['entityType'] as String;
        final String entityId = change['entityId'] as String;
        final String queueId = '$type:$entityId';
        final SyncPendingChange? local =
            await (_db.select(_db.syncPendingChanges)
                  ..where((SyncPendingChanges t) => t.id.equals(queueId)))
                .getSingleOrNull();
        final String? envelope = change['payload'] as String?;
        final Map<String, dynamic>? payload = envelope == null
            ? null
            : await crypto.decrypt(envelope);
        await _db.transaction(() async {
          final int incomingRevision = (change['revision'] as num).toInt();
          if (local != null &&
              local.changeId != change['changeId'] &&
              local.baseRevision != null &&
              incomingRevision <= local.baseRevision!) {
            // The server event is the accepted ancestor for a newer local edit.
            // Keep the newer local value and continue from this cursor.
          } else if (local != null && local.changeId != change['changeId']) {
            await _insertConflict(
              entityType: type,
              entityId: entityId,
              localJson: local.payloadJson,
              remoteJson: envelope ?? _deletedMarker,
              revision: incomingRevision,
            );
            await (_db.delete(
              _db.syncPendingChanges,
            )..where((SyncPendingChanges t) => t.id.equals(local.id))).go();
          } else {
            await _apply(
              type,
              entityId,
              change['operation'] as String,
              payload,
            );
          }
          await _setMeta(
            'revision:$type:$entityId',
            incomingRevision.toString(),
          );
          cursor = change['cursor'].toString();
          await _setMeta('serverCursor', cursor);
        });
      }
      more = page['hasMore'] == true && changes.isNotEmpty;
      if (changes.isEmpty) more = false;
    }
  }

  Future<void> _saveConflict(
    SyncPendingChange local,
    String? remote,
    int revision,
  ) async {
    await _db.transaction(() async {
      await _insertConflict(
        entityType: local.entityType,
        entityId: local.entityId,
        localJson: local.payloadJson,
        remoteJson: remote ?? _deletedMarker,
        revision: revision,
      );
      await (_db.delete(_db.syncPendingChanges)..where(
            (SyncPendingChanges t) =>
                t.id.equals(local.id) & t.changeId.equals(local.changeId),
          ))
          .go();
      await _setMeta(
        'revision:${local.entityType}:${local.entityId}',
        revision.toString(),
      );
    });
  }

  static const String _deletedMarker = '{"_lifeosDeleted":true}';

  Future<void> _insertConflict({
    required String entityType,
    required String entityId,
    required String localJson,
    required String remoteJson,
    required int revision,
  }) async {
    await _db
        .into(_db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: _id(),
            entityType: entityType,
            entityId: entityId,
            localPayloadJson: localJson,
            remotePayloadJson: remoteJson,
            remoteRevision: revision,
            detectedAt: DateTime.now(),
          ),
        );
  }

  Future<void> resolveConflict(
    SyncConflict conflict,
    String resolution,
    SyncCrypto crypto,
  ) async {
    if (resolution != 'local' && resolution != 'remote' && resolution != 'both')
      throw ArgumentError.value(resolution, 'resolution');
    final bool remoteDeleted = conflict.remotePayloadJson == _deletedMarker;
    final Map<String, dynamic>? remotePayload = remoteDeleted
        ? null
        : await crypto.decrypt(conflict.remotePayloadJson);
    final Map<String, dynamic> localPayload =
        jsonDecode(conflict.localPayloadJson) as Map<String, dynamic>;
    if (resolution == 'both' &&
        conflict.entityType == 'activity' &&
        localPayload['kind'] == 'journal' &&
        remotePayload != null) {
      await _db.transaction(() async {
        await _apply(
          conflict.entityType,
          conflict.entityId,
          'upsert',
          remotePayload,
        );
        final Map<String, dynamic> copy = Map<String, dynamic>.from(
          localPayload,
        );
        copy['id'] = _id();
        copy['title'] = '${copy['title']} (conflict copy)';
        await _apply(conflict.entityType, copy['id'] as String, 'upsert', copy);
        await _queueResolvedLocal(
          conflict,
          copy,
          entityId: copy['id'] as String,
          baseRevision: null,
        );
        await _markResolved(conflict, 'both');
      });
      return;
    }
    await _db.transaction(() async {
      if (resolution == 'remote') {
        await _apply(
          conflict.entityType,
          conflict.entityId,
          remoteDeleted ? 'delete' : 'upsert',
          remotePayload,
        );
      } else {
        await _apply(
          conflict.entityType,
          conflict.entityId,
          'upsert',
          localPayload,
        );
        await _queueResolvedLocal(
          conflict,
          localPayload,
          baseRevision: conflict.remoteRevision,
        );
      }
      await _setMeta(
        'revision:${conflict.entityType}:${conflict.entityId}',
        conflict.remoteRevision.toString(),
      );
      await _markResolved(conflict, resolution);
    });
  }

  Future<void> _queueResolvedLocal(
    SyncConflict conflict,
    Map<String, dynamic> local, {
    String? entityId,
    int? baseRevision,
  }) async {
    final String targetId = entityId ?? conflict.entityId;
    final String id = '${conflict.entityType}:$targetId';
    await _db
        .into(_db.syncPendingChanges)
        .insertOnConflictUpdate(
          SyncPendingChangesCompanion.insert(
            id: id,
            entityType: conflict.entityType,
            entityId: targetId,
            operation: 'upsert',
            changeId: Value<String>(_id()),
            payloadJson: Value<String>(jsonEncode(local)),
            baseRevision: Value<int?>(baseRevision),
            enqueuedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _markResolved(SyncConflict conflict, String resolution) =>
      (_db.update(
        _db.syncConflicts,
      )..where((SyncConflicts t) => t.id.equals(conflict.id))).write(
        SyncConflictsCompanion(
          resolution: Value<String?>(resolution),
          resolvedAt: Value<DateTime?>(DateTime.now()),
        ),
      );

  Future<void> _apply(
    String type,
    String id,
    String operation,
    Map<String, dynamic>? p,
  ) async {
    if (operation == 'delete') {
      switch (type) {
        case 'activity':
          await (_db.update(
            _db.activityRecords,
          )..where((ActivityRecords t) => t.id.equals(id))).write(
            ActivityRecordsCompanion(
              isDeleted: const Value<bool>(true),
              updatedAt: Value<DateTime>(DateTime.now()),
            ),
          );
          break;
        case 'habit':
          await (_db.delete(
            _db.habits,
          )..where((Habits t) => t.id.equals(id))).go();
          break;
        case 'habitOccurrence':
          await (_db.delete(
            _db.habitOccurrences,
          )..where((HabitOccurrences t) => t.id.equals(id))).go();
          break;
        case 'goal':
          await (_db.update(_db.goals)..where((Goals t) => t.id.equals(id)))
              .write(const GoalsCompanion(isDeleted: Value<bool>(true)));
          break;
        case 'budget':
          await (_db.delete(
            _db.budgets,
          )..where((Budgets t) => t.id.equals(id))).go();
          break;
        default:
          throw FormatException('Unknown sync entity type: $type');
      }
      return;
    }
    if (p == null)
      throw const FormatException('Encrypted sync record was empty.');
    switch (type) {
      case 'activity':
        await _db
            .into(_db.activityRecords)
            .insertOnConflictUpdate(
              ActivityRecordsCompanion.insert(
                id: id,
                kind: p['kind'] as String,
                recordDate: DateTime.parse(p['recordDate'] as String),
                title: p['title'] as String,
                value: Value<int?>(p['value'] as int?),
                unit: Value<String?>(p['unit'] as String?),
                status: Value<String?>(p['status'] as String?),
                notes: Value<String>(p['notes'] as String? ?? ''),
                metadataJson: Value<String>(
                  p['metadataJson'] as String? ?? '{}',
                ),
                createdAt: DateTime.parse(p['createdAt'] as String),
                updatedAt: DateTime.parse(p['updatedAt'] as String),
                isDeleted: Value<bool>(p['isDeleted'] as bool? ?? false),
              ),
            );
        break;
      case 'habit':
        await _db
            .into(_db.habits)
            .insertOnConflictUpdate(
              HabitsCompanion.insert(
                id: id,
                name: p['name'] as String,
                description: Value<String>(p['description'] as String? ?? ''),
                category: Value<String>(p['category'] as String? ?? 'Personal'),
                trackingType: Value<String>(
                  p['trackingType'] as String? ?? 'completion',
                ),
                unit: Value<String>(p['unit'] as String? ?? ''),
                scheduleDays: Value<String>(
                  p['scheduleDays'] as String? ?? '1,2,3,4,5,6,7',
                ),
                target: Value<int?>(p['target'] as int?),
                isReduction: Value<bool>(p['isReduction'] as bool? ?? false),
                isArchived: Value<bool>(p['isArchived'] as bool? ?? false),
                startDate: DateTime.parse(p['startDate'] as String),
                createdAt: DateTime.parse(p['createdAt'] as String),
              ),
            );
        break;
      case 'habitOccurrence':
        await _db
            .into(_db.habitOccurrences)
            .insertOnConflictUpdate(
              HabitOccurrencesCompanion.insert(
                id: id,
                habitId: p['habitId'] as String,
                occurrenceDate: DateTime.parse(p['occurrenceDate'] as String),
                status: p['status'] as String,
                numericValue: Value<int?>(p['numericValue'] as int?),
                updatedAt: DateTime.parse(p['updatedAt'] as String),
              ),
            );
        break;
      case 'goal':
        await _db
            .into(_db.goals)
            .insertOnConflictUpdate(
              GoalsCompanion.insert(
                id: id,
                name: p['name'] as String,
                timeframe: Value<String>(
                  p['timeframe'] as String? ?? 'Long-term',
                ),
                target: Value<int?>(p['target'] as int?),
                progress: Value<int>(p['progress'] as int? ?? 0),
                unit: Value<String>(p['unit'] as String? ?? 'steps'),
                dueDate: Value<DateTime?>(
                  (p['dueDate'] as String?) == null
                      ? null
                      : DateTime.parse(p['dueDate'] as String),
                ),
                status: Value<String>(p['status'] as String? ?? 'Active'),
                notes: Value<String>(p['notes'] as String? ?? ''),
                createdAt: DateTime.parse(p['createdAt'] as String),
                updatedAt: DateTime.parse(p['updatedAt'] as String),
                isDeleted: Value<bool>(p['isDeleted'] as bool? ?? false),
              ),
            );
        break;
      case 'budget':
        await _db
            .into(_db.budgets)
            .insertOnConflictUpdate(
              BudgetsCompanion.insert(
                id: id,
                category: p['category'] as String,
                amountMinor: p['amountMinor'] as int,
                period: Value<String>(p['period'] as String? ?? 'Monthly'),
                createdAt: DateTime.parse(p['createdAt'] as String),
                updatedAt: DateTime.parse(p['updatedAt'] as String),
              ),
            );
        break;
      default:
        throw FormatException('Unknown sync entity type: $type');
    }
  }

  Future<String?> _getMeta(String key) async => (await (_db.select(
    _db.syncMetadata,
  )..where((SyncMetadata t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _setMeta(String key, String value) async => _db
      .into(_db.syncMetadata)
      .insertOnConflictUpdate(
        SyncMetadataCompanion.insert(key: key, value: value),
      );

  String _id() => List<String>.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
