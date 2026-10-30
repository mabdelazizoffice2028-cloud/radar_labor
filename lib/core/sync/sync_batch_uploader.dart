import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/sync/outbox_repository.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';

final class SyncBatchUploader {
  const SyncBatchUploader({required this.outbox, required this.gateway});

  final OutboxRepository outbox;
  final RemoteSyncGateway gateway;

  Future<({int events, int audits})> upload({
    required ActorContext actor,
    required ScopeSnapshot scope,
  }) async {
    final pEv = await outbox.readPendingEvents(limit: 500);
    final pAu = await outbox.readPendingAudits(limit: 500);
    if (pEv.isEmpty && pAu.isEmpty) return (events: 0, audits: 0);

    final ack = await gateway.uploadBatch(
      actorUserId: actor.userId,
      actorRole: actor.role,
      allowedTeamIds: scope.teamIds,
      allowedHousingIds: scope.housingIds,
      events: pEv,
      audits: pAu,
    );
    await outbox.markEventsSynced(ack.acceptedEventIds);
    await outbox.markAuditsSynced(ack.acceptedAuditIds);
    return (events: ack.acceptedEventIds.length, audits: ack.acceptedAuditIds.length);
  }
}
