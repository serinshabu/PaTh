import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/database/life_os_database.dart';
import 'package:life_os/data/sync/sync_conflict_presentation.dart';

void main() {
  test('identifies a conflict by record type, title, and record date', () {
    final SyncConflict conflict = _conflict(
      payload: '{"kind":"mood","title":"Calm","recordDate":"2026-10-24"}',
      detectedAt: DateTime(2026, 10, 26),
    );

    expect(syncConflictTitle(conflict), 'mood · Calm · 24 Oct 2026');
  });

  test('malformed payload falls back to record type and conflict date', () {
    final SyncConflict conflict = _conflict(
      payload: '{invalid',
      detectedAt: DateTime(2026, 10, 27),
    );

    expect(
      syncConflictTitle(conflict),
      'activity · Conflict detected 27 Oct 2026',
    );
    expect(syncConflictTitle(conflict), isNot(contains('opaque-record-id')));
  });
}

SyncConflict _conflict({
  required String payload,
  required DateTime detectedAt,
}) => SyncConflict(
  id: 'conflict-1',
  entityType: 'activity',
  entityId: 'opaque-record-id',
  localPayloadJson: payload,
  remotePayloadJson: '{}',
  remoteRevision: 2,
  detectedAt: detectedAt,
);
