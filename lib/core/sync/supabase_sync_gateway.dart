import 'package:flutter/foundation.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/sync/supabase_events_puller.dart';
import 'package:radar_labor/core/sync/supabase_events_uploader.dart';
import 'package:radar_labor/core/sync/supabase_snapshot_fetcher.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    required String actorUserId,
    required AuthRole actorRole,
    required Set<String> allowedTeamIds,
    required Set<String> allowedHousingIds,
    required List<LocalEvent> events,
    required List<AuditEntry> audits,
  }) async {
    try {
      return await SupabaseEventsUploader.upload(
        _resolvedClient,
        actorUserId: actorUserId,
        events: events,
        audits: audits,
      );
    } on OperationException {
      rethrow;
    } catch (error) {
      debugPrint('Supabase uploadBatch error: $error');
      throw const OperationException(DatabaseBusy());
    }
  }

  @override
  Future<RemoteSyncPullResult> pullEvents({
    required int sinceServerSeq,
    int limit = 200,
  }) async {
    try {
      return await SupabaseEventsPuller.pull(
        _resolvedClient,
        sinceServerSeq: sinceServerSeq,
        limit: limit,
      );
    } catch (error) {
      debugPrint('Supabase pullEvents error: $error');
      return RemoteSyncPullResult(
        events: const [],
        lastServerSeq: sinceServerSeq,
      );
    }
  }

  @override
  Future<RemoteRosterSnapshot> fetchSnapshot({
    required String actorUserId,
  }) async {
    try {
      return await SupabaseSnapshotFetcher.fetch(
        _resolvedClient,
        actorUserId: actorUserId,
      );
    } on OperationException {
      rethrow;
    } catch (error) {
      debugPrint('Supabase fetchSnapshot error: $error');
      throw const OperationException(DatabaseBusy());
    }
  }
}
