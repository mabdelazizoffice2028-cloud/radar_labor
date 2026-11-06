import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/sync/outbox_repository.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/sync/sync_activator.dart';
import 'package:radar_labor/core/sync/sync_batch_uploader.dart';
import 'package:radar_labor/core/sync/sync_cycle_result.dart';
import 'package:radar_labor/core/sync/sync_events_applier.dart';
import 'package:radar_labor/core/sync/sync_snapshot_applier.dart';
import 'package:radar_labor/core/time/clock.dart';

export 'package:radar_labor/core/sync/sync_cycle_result.dart';

final class SyncEngine {
  SyncEngine({
    required this.database,
    required this.outbox,
    required this.gateway,
    Clock clock = const SystemClock(),
  })  : _activator = SyncActivator(database: database, gateway: gateway),
        _uploader = SyncBatchUploader(outbox: outbox, gateway: gateway),
        _applier = SyncSnapshotApplier(database: database, clock: clock),
        _eventsApplier = SyncEventsApplier(database: database, clock: clock);

  final AppDatabase database;
  final OutboxRepository outbox;
  final RemoteSyncGateway gateway;
  final SyncActivator _activator;
  final SyncBatchUploader _uploader;
  final SyncSnapshotApplier _applier;
  final SyncEventsApplier _eventsApplier;

  static Duration backoffForAttempt(int attempt) =>
      Duration(seconds: 1 << attempt.clamp(1, 6));

  Future<void> ensureActivated({required ActorContext actor}) =>
      _activator.ensureActivated(actor: actor);

  Future<int> _readLastServerSeq() async {
    final row = await (database.select(database.settings)
          ..where((s) => s.key.equals(AppSettingKeys.lastSyncedServerSeq)))
        .getSingleOrNull();
    return int.tryParse(row?.value ?? '0') ?? 0;
  }

  Future<void> _writeLastServerSeq(int seq) => database
      .into(database.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(
        key: AppSettingKeys.lastSyncedServerSeq,
        value: seq.toString(),
      ));

  Future<SyncCycleResult> synchronize({
    required ActorContext actor,
    required ScopeSnapshot scope,
  }) async {
    await ensureActivated(actor: actor);
    if (!await gateway.isReachable()) {
      return SyncCycleResult(
        uploadedEventsCount: 0,
        uploadedAuditsCount: 0,
        pendingRemaining: await outbox.readPendingCount(),
        rosterEpoch: await _activator.readLocalEpoch(),
        offline: true,
      );
    }

    final uploaded = await _uploader.upload(actor: actor, scope: scope);
    final lastSeq = await _readLastServerSeq();
    final pull = await gateway.pullEvents(sinceServerSeq: lastSeq);
    if (pull.events.isNotEmpty) {
      await _eventsApplier.applyInboundEvents(pull.events);
      await _writeLastServerSeq(pull.lastServerSeq);
    }

    final snap = await gateway.fetchSnapshot(actorUserId: actor.userId);
    final localEpoch = await _activator.readLocalEpoch();
    final epochChanged = snap.rosterEpoch > localEpoch;
    await _applier.apply(snap, epochChanged: epochChanged);
    await _activator.markActivated();

    final isStaff =
        actor.role != AuthRole.projectManager && actor.role != AuthRole.hr;
    return SyncCycleResult(
      uploadedEventsCount: uploaded.events,
      uploadedAuditsCount: uploaded.audits,
      pendingRemaining: await outbox.readPendingCount(),
      rosterEpoch: snap.rosterEpoch,
      sessionRevoked: !snap.accountActive || (epochChanged && isStaff),
    );
  }
}
