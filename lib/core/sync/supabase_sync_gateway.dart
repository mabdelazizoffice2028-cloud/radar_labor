import 'package:flutter/foundation.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/sync/supabase_snapshot_fetcher.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Real remote sync gateway powered by Supabase (PRD §23.6, Part B).
final class SupabaseSyncGateway implements RemoteSyncGateway {
  SupabaseSyncGateway({this.client});
  final SupabaseClient? client;
  SupabaseClient get _resolvedClient => client ?? Supabase.instance.client;

  @override
  Future<bool> isReachable() async {
    try {
      await _resolvedClient.from('employees').select('employee_uid').limit(1);
      return true;
    } catch (error) {
      debugPrint('Supabase reachability check failed: $error');
      return false;
    }
  }

  @override
  Future<RemoteUploadAck> uploadBatch({
    required String actorUserId, required AuthRole actorRole,
    required Set<String> allowedTeamIds, required Set<String> allowedHousingIds,
    required List<LocalEvent> events, required List<AuditEntry> audits,
  }) async {
    try {
      final eventsPayload = [
        for (final e in events)
          <String, dynamic>{
            'event_id': e.eventId, 'user_id': actorUserId, 'event_type': e.type.name,
            'action': e.action.name, 'business_date': e.businessDate, 'device_seq': e.deviceSeq,
            if (e.employeeUid != null) 'employee_uid': e.employeeUid,
            if (e.teamId != null) 'team_id': e.teamId,
            if (e.housingId != null) 'housing_id': e.housingId,
            if (e.deviceTimeUtc != null) 'device_time_utc': e.deviceTimeUtc!.toIso8601String(),
            if (e.resolutionKind != null) 'resolution_kind': e.resolutionKind!.key,
          },
      ];

      final dynamic res = await _resolvedClient.rpc('ingest_events', params: {'p_events': eventsPayload});
      final accepted = <String>{};
      if (res is List) {
        for (final item in res) {
          if (item is Map) {
            final id = item['event_id']?.toString();
            final status = item['status']?.toString();
            if (id != null && (status == 'acked' || status == 'duplicate' || item['accepted'] == true)) {
              accepted.add(id);
            }
          } else if (item is String) {
            accepted.add(item);
          }
        }
      }

      return RemoteUploadAck(
        acceptedEventIds: res == null ? events.map((e) => e.eventId).toSet() : accepted,
        acceptedAuditIds: audits.map((a) => a.auditId).toSet(),
      );
    } on OperationException {
      rethrow;
    } catch (error) {
      debugPrint('Supabase uploadBatch error: $error');
      throw const OperationException(DatabaseBusy());
    }
  }

  @override
  Future<RemoteRosterSnapshot> fetchSnapshot({required String actorUserId}) async {
    try {
      return await SupabaseSnapshotFetcher.fetch(_resolvedClient, actorUserId: actorUserId);
    } on OperationException {
      rethrow;
    } catch (error) {
      debugPrint('Supabase fetchSnapshot error: $error');
      throw const OperationException(DatabaseBusy());
    }
  }
}
