import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/database/life_os_database.dart';
import 'package:life_os/data/records/records_repository.dart';
import 'package:life_os/data/sync/sync_credentials.dart';
import 'package:life_os/data/sync/sync_engine.dart';
import 'package:life_os/data/sync/sync_crypto.dart';

void main() {
  late HttpServer server;
  late LifeOsDatabase laptop;
  late LifeOsDatabase phone;
  late SyncEngine laptopSync;
  late SyncEngine phoneSync;
  final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
  final Map<String, Map<String, dynamic>> records =
      <String, Map<String, dynamic>>{};
  final Map<String, Map<String, dynamic>> processed =
      <String, Map<String, dynamic>>{};
  int cursor = 0;
  bool dropNextPushResponse = false;

  setUp(() async {
    events.clear();
    records.clear();
    processed.clear();
    cursor = 0;
    dropNextPushResponse = false;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((HttpRequest request) async {
      try {
        if (request.method == 'GET' &&
            request.uri.path == '/v1/sync/config') {
          _respond(request.response, 200, <String, dynamic>{
            'keySalt': base64.encode(List<int>.generate(16, (int i) => i)),
            'kdfIterations': 1000,
          });
          return;
        }
        if (request.method == 'POST' && request.uri.path == '/v1/changes') {
          final Map<String, dynamic> input = jsonDecode(
            await utf8.decoder.bind(request).join(),
          ) as Map<String, dynamic>;
          final List<Map<String, dynamic>> acknowledgements =
              <Map<String, dynamic>>[];
          final List<Map<String, dynamic>> conflicts =
              <Map<String, dynamic>>[];
          final List<dynamic> changes = input['changes'] as List<dynamic>;
          for (final dynamic value in changes) {
            final Map<String, dynamic> change = value as Map<String, dynamic>;
            final Map<String, dynamic>? priorAck =
                processed[change['changeId'] as String];
            if (priorAck != null) {
              acknowledgements.add(priorAck);
              continue;
            }
            final String key = '${change['entityType']}:${change['entityId']}';
            final Map<String, dynamic>? current = records[key];
            final int? currentRevision = (current?['revision'] as num?)?.toInt();
            if (currentRevision != change['baseRevision']) {
              conflicts.add(<String, dynamic>{
                'changeId': change['changeId'],
                'entityType': change['entityType'],
                'entityId': change['entityId'],
                'remoteRevision': currentRevision,
                'remotePayload': current?['payload'],
                'remoteDeleted': current?['operation'] == 'delete',
              });
              continue;
            }
            final int revision = (currentRevision ?? 0) + 1;
            cursor++;
            final Map<String, dynamic> event = <String, dynamic>{
              'cursor': '$cursor',
              'changeId': change['changeId'],
              'entityType': change['entityType'],
              'entityId': change['entityId'],
              'revision': revision,
              'operation': change['operation'],
              'payload': change['payload'],
            };
            records[key] = <String, dynamic>{...event, 'revision': revision};
            events.add(event);
            final Map<String, dynamic> ack = <String, dynamic>{
              'changeId': change['changeId'],
              'revision': '$revision',
              'cursor': '$cursor',
            };
            processed[change['changeId'] as String] = ack;
            acknowledgements.add(ack);
          }
          if (dropNextPushResponse) {
            dropNextPushResponse = false;
            final Socket socket = await request.response.detachSocket(
              writeHeaders: false,
            );
            socket.destroy();
            return;
          }
          _respond(request.response, 200, <String, dynamic>{
            'acknowledgements': acknowledgements,
            'conflicts': conflicts,
          });
          return;
        }
        if (request.method == 'GET' && request.uri.path == '/v1/changes') {
          final int after = int.parse(request.uri.queryParameters['cursor']!);
          final List<Map<String, dynamic>> changes = events
              .where((Map<String, dynamic> event) =>
                  int.parse(event['cursor'] as String) > after)
              .toList();
          _respond(request.response, 200, <String, dynamic>{
            'changes': changes,
            'nextCursor': changes.isEmpty ? '$after' : changes.last['cursor'],
            'hasMore': false,
          });
          return;
        }
        _respond(request.response, 404, <String, dynamic>{'error': 'Not found'});
      } catch (error) {
        _respond(request.response, 500, <String, dynamic>{
          'error': error.toString(),
        });
      }
    });
    laptop = LifeOsDatabase.forTesting(NativeDatabase.memory());
    phone = LifeOsDatabase.forTesting(NativeDatabase.memory());
    laptopSync = SyncEngine(laptop);
    phoneSync = SyncEngine(phone);
  });

  tearDown(() async {
    await laptop.close();
    await phone.close();
    await server.close(force: true);
  });

  test('encrypted changes sync in both directions without duplicate records',
      () async {
    final SyncCredentials localCredentials = _credentials(server.port);
    final RecordsRepository laptopRecords = RecordsRepository(laptop);
    await laptopRecords.save(
      kind: 'journal',
      title: 'Laptop note',
      date: DateTime(2026, 10, 18),
      notes: 'Created offline on laptop',
      id: 'shared-journal',
    );

    await laptopSync.synchronize(localCredentials);
    expect(await laptopSync.pendingCount(), 0);
    await phoneSync.synchronize(localCredentials);
    ActivityRecord phoneRecord =
        (await RecordsRepository(phone).watch('journal').first).single;
    expect(phoneRecord.id, 'shared-journal');
    expect(phoneRecord.notes, 'Created offline on laptop');

    await RecordsRepository(phone).save(
      kind: 'journal',
      title: 'Edited on phone',
      date: phoneRecord.recordDate,
      notes: 'Edited offline on phone',
      id: phoneRecord.id,
    );
    await phoneSync.synchronize(localCredentials);
    await laptopSync.synchronize(localCredentials);

    final List<ActivityRecord> laptopRecordsAfterSync =
        await RecordsRepository(laptop).watch('journal').first;
    expect(laptopRecordsAfterSync, hasLength(1));
    expect(laptopRecordsAfterSync.single.title, 'Edited on phone');
    expect(laptopRecordsAfterSync.single.notes, 'Edited offline on phone');
    expect(await laptopSync.pendingCount(), 0);
    expect(await phoneSync.pendingCount(), 0);
  });

  test('simultaneous edits preserve both versions until local resolution',
      () async {
    final SyncCredentials credentials = _credentials(server.port);
    final RecordsRepository laptopRecords = RecordsRepository(laptop);
    final RecordsRepository phoneRecords = RecordsRepository(phone);
    await laptopRecords.save(
      kind: 'journal',
      title: 'Original',
      date: DateTime(2026, 10, 18),
      notes: 'Shared version',
      id: 'conflicting-journal',
    );
    await laptopSync.synchronize(credentials);
    await phoneSync.synchronize(credentials);
    final ActivityRecord laptopEntry =
        (await laptopRecords.watch('journal').first).single;
    final ActivityRecord phoneEntry =
        (await phoneRecords.watch('journal').first).single;
    await laptopRecords.save(
      kind: 'journal',
      title: 'Laptop edit',
      date: laptopEntry.recordDate,
      notes: 'Laptop version',
      id: laptopEntry.id,
    );
    await phoneRecords.save(
      kind: 'journal',
      title: 'Phone edit',
      date: phoneEntry.recordDate,
      notes: 'Phone version',
      id: phoneEntry.id,
    );
    await laptopSync.synchronize(credentials);
    await phoneSync.synchronize(credentials);

    final SyncConflict conflict =
        (await phoneSync.watchOpenConflicts().first).single;
    expect(jsonDecode(conflict.localPayloadJson)['notes'], 'Phone version');
    expect((await phoneRecords.watch('journal').first).single.notes,
        'Laptop version');
    await phoneSync.resolveConflict(conflict, 'local', await _crypto());
    await phoneSync.synchronize(credentials);
    await laptopSync.synchronize(credentials);

    expect((await laptopRecords.watch('journal').first).single.notes,
        'Phone version');
    expect(await phoneSync.watchOpenConflicts().first, isEmpty);
  });

  test('deletion propagates as a tombstone to the other device', () async {
    final SyncCredentials credentials = _credentials(server.port);
    final RecordsRepository laptopRecords = RecordsRepository(laptop);
    final RecordsRepository phoneRecords = RecordsRepository(phone);
    await laptopRecords.save(
      kind: 'journal',
      title: 'Remove me',
      date: DateTime(2026, 10, 18),
      id: 'deleted-journal',
    );
    await laptopSync.synchronize(credentials);
    await phoneSync.synchronize(credentials);
    await laptopRecords.delete(
      (await laptopRecords.watch('journal').first).single,
    );
    await laptopSync.synchronize(credentials);
    await phoneSync.synchronize(credentials);

    expect(await phoneRecords.watch('journal').first, isEmpty);
    expect(
      (await phone.select(phone.activityRecords).get()).single.isDeleted,
      isTrue,
    );
    expect(events.last['operation'], 'delete');
  });

  test('interrupted push retries idempotently without duplicate server rows',
      () async {
    final SyncCredentials credentials = _credentials(server.port);
    await RecordsRepository(laptop).save(
      kind: 'journal',
      title: 'Retry safely',
      date: DateTime(2026, 10, 18),
      id: 'retry-journal',
    );
    dropNextPushResponse = true;
    await expectLater(laptopSync.synchronize(credentials), throwsA(anything));
    expect(await laptopSync.pendingCount(), 1);
    await laptopSync.synchronize(credentials);

    expect(await laptopSync.pendingCount(), 0);
    expect(events, hasLength(1));
    expect(records, hasLength(1));
  });
}

SyncCredentials _credentials(int port) => SyncCredentials(
  serverUrl: 'http://127.0.0.1:$port',
  deviceToken: 'test-token',
  recoverySecret: 'violet river moonlight recovery phrase',
  deviceId: 'test-device',
);

Future<SyncCrypto> _crypto() => SyncCrypto.fromRecoverySecret(
  recoverySecret: 'violet river moonlight recovery phrase',
  saltBase64: base64.encode(List<int>.generate(16, (int i) => i)),
  iterations: 1000,
);

void _respond(HttpResponse response, int status, Map<String, dynamic> value) {
  response.statusCode = status;
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(value));
  response.close();
}
