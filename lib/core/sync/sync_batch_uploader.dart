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
    var totalEvents = 0;
    var totalAudits = 0;

    while (true) {
      final pEv = await outbox.readPendingEvents(limit: 500);
      final pAu = await outbox.readPendingAudits(limit: 500);
      if (pEv.isEmpty && pAu.isEmpty) break;

      final ack = await gateway.uploadBatch(
        actorUserId: actor.userId,
        actorRole: actor.role,
        allowedTeamIds: scope.teamIds,
        allowedHousingIds: scope.housingIds,
        events: pEv,
        audits: pAu,
      );

      if (ack.acceptedEventIds.isEmpty && ack.acceptedAuditIds.isEmpty) {
        break;
      }

      await outbox.markEventsSynced(ack.acceptedEventIds);
      await outbox.markAuditsSynced(ack.acceptedAuditIds);
      totalEvents += ack.acceptedEventIds.length;
      totalAudits += ack.acceptedAuditIds.length;
    }

    return (events: totalEvents, audits: totalAudits);
  }
}
