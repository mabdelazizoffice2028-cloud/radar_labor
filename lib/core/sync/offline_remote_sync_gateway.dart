import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';

final class OfflineRemoteSyncGateway implements RemoteSyncGateway {
  const OfflineRemoteSyncGateway();

  @override
  Future<bool> isReachable() async => false;

  @override
  Future<RemoteUploadAck> uploadBatch({
    required String actorUserId,
    required AuthRole actorRole,
    required Set<String> allowedTeamIds,
    required Set<String> allowedHousingIds,
    required List<LocalEvent> events,
    required List<AuditEntry> audits,
  }) async =>
      const RemoteUploadAck(
        acceptedEventIds: <String>{},
        acceptedAuditIds: <String>{},
      );

  @override
  Future<RemoteSyncPullResult> pullEvents({
    required int sinceServerSeq,
    int limit = 200,
  }) async =>
      RemoteSyncPullResult(events: const [], lastServerSeq: sinceServerSeq);

  @override
  Future<RemoteRosterSnapshot> fetchSnapshot({
    required String actorUserId,
  }) async =>
      const RemoteRosterSnapshot(rosterEpoch: 1);
}
