import 'dart:convert';

import 'package:intl/intl.dart';

import '../database/life_os_database.dart';

String syncConflictTitle(SyncConflict conflict) {
  Map<String, dynamic> payload = <String, dynamic>{};
  try {
    final Object? decoded = jsonDecode(conflict.localPayloadJson);
    if (decoded is Map<String, dynamic>) payload = decoded;
  } catch (_) {
    // The conflict still has a type and detected date when its payload is bad.
  }

  final Object? kindValue = payload['kind'];
  final String type = conflict.entityType == 'activity'
      ? (kindValue is String && kindValue.trim().isNotEmpty
            ? kindValue.trim()
            : 'activity')
      : conflict.entityType;
  final Object? titleValue = payload['title'];
  final String title = titleValue is String ? titleValue.trim() : '';
  final Object? rawRecordDate = payload['recordDate'];
  final Object? updatedAt = payload['updatedAt'];
  final String? recordDateValue = rawRecordDate is String
      ? rawRecordDate
      : updatedAt is String
      ? updatedAt
      : null;
  final DateTime? recordDate = recordDateValue == null
      ? null
      : DateTime.tryParse(recordDateValue);
  final DateFormat format = DateFormat('d MMM yyyy');
  final String dateLabel = recordDate == null
      ? 'Conflict detected ${format.format(conflict.detectedAt.toLocal())}'
      : format.format(recordDate.toLocal());

  return '$type${title.isEmpty ? '' : ' · $title'} · $dateLabel';
}
