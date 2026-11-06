import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart';

abstract final class EventDomainMapper {
  static LocalEvent toDomain(Event row) {
    final payloadMap = decodePayload(row.payload);
    return LocalEvent(
      eventId: row.eventId,
      deviceSeq: row.deviceSeq,
      type: EventType.values.byName(row.type),
      action: EventAction.values.byName(row.action),
      businessDate: row.businessDate,
      employeeUid: row.employeeUid,
      teamId: row.teamId,
      housingId: row.housingId,
      userId: row.userId,
      receivedAtUtc: row.receivedAt?.toUtc(),
      deviceTimeUtc: row.deviceTime.toUtc(),
      delivery: parseDelivery(row.syncStatus),
      isLate: row.late,
      resolutionKind: ResolutionKind.fromKey(payloadMap['kind']),
      employmentType: payloadMap['employmentType'] as String?,
      jobCategory: payloadMap['jobCategory'] as String?,
      deviceId: row.deviceId,
      serverSeq: row.serverSeq,
    );
  }

  static Map<String, Object?> decodePayload(String payload) {
    if (payload.isEmpty) return const {};
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map<String, Object?> ? decoded : const {};
    } on FormatException catch (e) {
      debugPrint('EventDomainMapper.decodePayload malformed JSON: ${e.message}');
      return const {};
    }
  }

  static EventDelivery parseDelivery(String syncStatus) {
    if (syncStatus == 'synced' || syncStatus == 'acked') {
      return EventDelivery.acked;
    }
    try {
      return EventDelivery.values.byName(syncStatus);
    } on ArgumentError catch (e) {
      debugPrint('EventDomainMapper.parseDelivery unknown status ($syncStatus): ${e.message}');
      return EventDelivery.pending;
    }
  }
}
