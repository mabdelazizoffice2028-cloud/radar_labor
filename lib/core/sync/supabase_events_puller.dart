import 'package:flutter/foundation.dart';
import 'package:radar_labor/core/events/event_domain_mapper.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseEventsPuller {
  static Future<RemoteSyncPullResult> pull(
    SupabaseClient client, {
    required int sinceServerSeq,
    int limit = 200,
  }) async {
    try {
      final rows = await client
          .from('events')
          .select()
          .gt('server_seq', sinceServerSeq)
          .order('server_seq', ascending: true)
          .limit(limit);
      final events = <LocalEvent>[];
      var maxSeq = sinceServerSeq;
      for (final row in rows) {
        final ev = parseEvent(row);
        if (ev != null) {
          events.add(ev);
          final sSeq = row['server_seq'] as int?;
          if (sSeq != null && sSeq > maxSeq) maxSeq = sSeq;
        }
      }
      return RemoteSyncPullResult(events: events, lastServerSeq: maxSeq);
    } catch (error) {
      debugPrint('Supabase pullEvents error: $error');
      return RemoteSyncPullResult(
        events: const [],
        lastServerSeq: sinceServerSeq,
      );
    }
  }

  static LocalEvent? parseEvent(Map data) {
    try {
      final rawPayload = data['payload'];
      final payloadMap = rawPayload is Map
          ? rawPayload.map((k, v) => MapEntry(k.toString(), v as Object?))
          : (rawPayload is String
              ? EventDomainMapper.decodePayload(rawPayload)
              : const <String, Object?>{});
      final kindRaw = data['resolution_kind'] ?? payloadMap['kind'];
      final empType = (data['employment_type'] ?? payloadMap['employmentType'])?.toString();
      final jobCat = (data['job_category'] ?? payloadMap['jobCategory'])?.toString();
      final devTimeStr = (data['device_time_utc'] ?? data['device_time'])?.toString();
      final recTimeStr = data['received_at']?.toString();
      return LocalEvent(
        eventId: data['event_id'].toString(),
        type: EventType.values.byName((data['event_type'] ?? data['type']).toString()),
        action: EventAction.values.byName(data['action'].toString()),
        businessDate: data['business_date'].toString(),
        deviceSeq: int.tryParse(data['device_seq']?.toString() ?? '1') ?? 1,
        employeeUid: data['employee_uid']?.toString(),
        teamId: data['team_id']?.toString(),
        housingId: data['housing_id']?.toString(),
        userId: data['user_id']?.toString(),
        serverSeq: data['server_seq'] as int?,
        deviceId: data['device_id']?.toString() ?? 'server',
        deviceTimeUtc: devTimeStr != null ? DateTime.tryParse(devTimeStr)?.toUtc() : null,
        receivedAtUtc: recTimeStr != null ? DateTime.tryParse(recTimeStr)?.toUtc() : null,
        delivery: EventDelivery.acked,
        isLate: data['late'] == true,
        resolutionKind: ResolutionKind.fromKey(kindRaw),
        employmentType: empType,
        jobCategory: jobCat,
      );
    } on Object catch (error) {
      debugPrint('Failed to parse remote event: $error');
      return null;
    }
  }
}
