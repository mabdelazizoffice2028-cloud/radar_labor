import 'package:flutter/foundation.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseEventsUploader {
  static Future<RemoteUploadAck> upload(
    SupabaseClient client, {
    required String actorUserId,
    required List<LocalEvent> events,
    required List<AuditEntry> audits,
  }) async {
    try {
      final payload = [
        for (final e in events)
          <String, dynamic>{
            'event_id': e.eventId,
            'user_id': actorUserId,
            'event_type': e.type.name,
            'action': e.action.name,
            'business_date': e.businessDate,
            'device_seq': e.deviceSeq,
            if (e.employeeUid != null) 'employee_uid': e.employeeUid,
            if (e.teamId != null) 'team_id': e.teamId,
            if (e.housingId != null) 'housing_id': e.housingId,
            if (e.deviceTimeUtc != null)
              'device_time_utc': e.deviceTimeUtc!.toIso8601String(),
            if (e.resolutionKind != null)
              'resolution_kind': e.resolutionKind!.key,
          },
      ];

      final dynamic res =
          await client.rpc('ingest_events', params: {'p_events': payload});
      final accepted = <String>{};
      final rejected = <String, String>{};
      if (res is List) {
        for (final item in res) {
          if (item is Map) {
            final id = item['event_id']?.toString();
            final status = item['status']?.toString();
            if (id != null) {
              if (status == 'rejected' || item['rejected'] == true) {
                rejected[id] = item['reject_reason']?.toString() ??
                    'rejected_by_server';
              } else if (status == 'acked' ||
                  status == 'duplicate' ||
                  item['accepted'] == true) {
                accepted.add(id);
              }
            }
          } else if (item is String) {
            accepted.add(item);
          }
        }
      }

      return RemoteUploadAck(
        acceptedEventIds:
            res == null ? events.map((e) => e.eventId).toSet() : accepted,
        acceptedAuditIds: audits.map((a) => a.auditId).toSet(),
        rejectedEvents: rejected,
      );
    } on OperationException {
      rethrow;
    } catch (error) {
      debugPrint('Supabase upload error: $error');
      throw const OperationException(DatabaseBusy());
    }
  }
}
