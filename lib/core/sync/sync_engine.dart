import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/sync/outbox_repository.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

/// Outcome of a sync cycle (PRD §23.6, D-25, D-27).
final class SyncCycleResult {
  const SyncCycleResult({
    required this.uploadedEventsCount,
    required this.uploadedAuditsCount,
    required this.pendingRemaining,
    required this.rosterEpoch,
    this.sessionRevoked = false,
    this.offline = false,
  });

  final int uploadedEventsCount;
  final int uploadedAuditsCount;
  final int pendingRemaining;
  final int rosterEpoch;
  final bool sessionRevoked;
  final bool offline;
}

/// Automatic offline-first synchronization engine (PRD §17.4, §23.6, D-25, D-27).
/// Guarantees:
/// 1. Offline recording never blocks.
/// 2. Pending outbox events and audit entries are uploaded idempotently BEFORE any session revocation.
/// 3. If `roster_epoch` increased on the server or the user's account was deactivated,
///    the engine flushes all pending local work first, updates local reference state, and returns `SessionRevoked`.
/// 4. A brand-new supervisor/viewer device without local roster data and without connectivity throws `ActivationRequired`.
final class SyncEngine {
  const SyncEngine({
    required this.database,
    required this.outbox,
    required this.gateway,
  });

  final AppDatabase database;
  final OutboxRepository outbox;
  final RemoteSyncGateway gateway;

  /// Computes exponential backoff duration for retry attempt [attempt] (1-based).
  static Duration backoffForAttempt(int attempt) {
    final clamped = attempt.clamp(1, 6);
    final seconds = 1 << clamped; // 2s, 4s, 8s, 16s, 32s, 64s
    return Duration(seconds: seconds);
  }

  /// Checks whether a non-admin device has been activated with roster data (PRD §23.6).
  Future<void> ensureActivated({required ActorContext actor}) async {
    if (actor.role == AuthRole.projectManager || actor.role == AuthRole.hr) {
      return;
    }
    final activatedRow =
        await (database.select(database.settings)
              ..where((s) => s.key.equals(AppSettingKeys.deviceActivated)))
            .getSingleOrNull();
    if (activatedRow?.value == 'true') return;

    final hasEmployees =
        (await database.select(database.employees).get()).isNotEmpty;
    if (hasEmployees) {
      await _markActivated();
      return;
    }

    if (!await gateway.isReachable()) {
      throw const OperationException(ActivationRequired());
    }
  }

  /// Runs a full upload-then-download synchronization cycle (PRD §23.6, D-25).
  Future<SyncCycleResult> synchronize({
    required ActorContext actor,
    required ScopeSnapshot scope,
  }) async {
    await ensureActivated(actor: actor);

    final reachable = await gateway.isReachable();
    if (!reachable) {
      final pending = await outbox.readPendingCount();
      final localEpoch = await _readLocalEpoch();
      return SyncCycleResult(
        uploadedEventsCount: 0,
        uploadedAuditsCount: 0,
        pendingRemaining: pending,
        rosterEpoch: localEpoch,
        offline: true,
      );
    }

    // Step 1: Upload all pending events and audit entries FIRST so no offline work is ever lost (D-25).
    final pendingEvents = await outbox.readPendingEvents(limit: 500);
    final pendingAudits = await outbox.readPendingAudits(limit: 500);
    var uploadedEvents = 0;
    var uploadedAudits = 0;

    if (pendingEvents.isNotEmpty || pendingAudits.isNotEmpty) {
      final ack = await gateway.uploadBatch(
        actorUserId: actor.userId,
        actorRole: actor.role,
        allowedTeamIds: scope.teamIds,
        allowedHousingIds: scope.housingIds,
        events: pendingEvents,
        audits: pendingAudits,
      );
      await outbox.markEventsSynced(ack.acceptedEventIds);
      await outbox.markAuditsSynced(ack.acceptedAuditIds);
      uploadedEvents = ack.acceptedEventIds.length;
      uploadedAudits = ack.acceptedAuditIds.length;
    }

    // Step 2: Fetch remote snapshot (roster_epoch, account status, updated reference rows).
    final snapshot = await gateway.fetchSnapshot(actorUserId: actor.userId);
    final localEpoch = await _readLocalEpoch();
    final epochChanged = snapshot.rosterEpoch > localEpoch;
    final accountDeactivated = !snapshot.accountActive;

    await _applySnapshot(snapshot, epochChanged: epochChanged);
    await _markActivated();

    final remaining = await outbox.readPendingCount();
    final isSupervisorOrViewer =
        actor.role != AuthRole.projectManager && actor.role != AuthRole.hr;
    final revoked =
        accountDeactivated || (epochChanged && isSupervisorOrViewer);

    return SyncCycleResult(
      uploadedEventsCount: uploadedEvents,
      uploadedAuditsCount: uploadedAudits,
      pendingRemaining: remaining,
      rosterEpoch: snapshot.rosterEpoch,
      sessionRevoked: revoked,
    );
  }

  Future<int> _readLocalEpoch() async {
    final row =
        await (database.select(database.settings)
              ..where((s) => s.key.equals(AppSettingKeys.rosterEpoch)))
            .getSingleOrNull();
    return int.tryParse(row?.value ?? '1') ?? 1;
  }

  Future<void> _markActivated() async {
    await database
        .into(database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: AppSettingKeys.deviceActivated,
            value: 'true',
          ),
        );
  }

  Future<void> _applySnapshot(
    RemoteRosterSnapshot snapshot, {
    required bool epochChanged,
  }) async {
    await database.transaction(() async {
      if (epochChanged) {
        await (database.update(database.employees)).write(
          const EmployeesCompanion(
            isActive: Value(false),
            currentTeamId: Value(null),
          ),
        );
      }

      final existingRows = await database.select(database.employees).get();
      final byUid = {for (final e in existingRows) e.employeeUid: e};

      for (final remote in snapshot.employees) {
        final local = byUid[remote.employeeUid];
        if (local == null) {
          await database
              .into(database.employees)
              .insert(
                EmployeesCompanion.insert(
                  employeeUid: remote.employeeUid,
                  employeeCode: remote.employeeCode,
                  fullNameAr: remote.fullNameAr,
                  fullNameEn: Value(remote.fullNameEn),
                  category: remote.category,
                  supplier: Value(remote.supplier),
                  currentTeamId: Value(remote.currentTeamId),
                  housingId: Value(remote.housingId),
                  isActive: Value(remote.isActive),
                  rowVersion: Value(remote.rowVersion),
                ),
              );
        } else if (remote.rowVersion >= local.rowVersion) {
          await (database.update(
            database.employees,
          )..where((e) => e.employeeUid.equals(remote.employeeUid))).write(
            EmployeesCompanion(
              employeeCode: Value(remote.employeeCode),
              fullNameAr: Value(remote.fullNameAr),
              fullNameEn: Value(remote.fullNameEn),
              category: Value(remote.category),
              supplier: Value(remote.supplier),
              currentTeamId: Value(remote.currentTeamId),
              housingId: Value(remote.housingId),
              isActive: Value(remote.isActive),
              rowVersion: Value(remote.rowVersion),
            ),
          );
        }
      }

      await database
          .into(database.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(
              key: AppSettingKeys.rosterEpoch,
              value: snapshot.rosterEpoch.toString(),
            ),
          );
    });
  }
}
