import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/sync/outbox_repository.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/sync/sync_engine.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this.now);
  final DateTime now;
  @override
  DateTime nowUtc() => now;
}

/// In-memory fake server gateway enforcing RLS, ScopeGuard, and idempotent event/audit ingestion (PRD §18, §23.6).
final class _FakeRlsRemoteGateway implements RemoteSyncGateway {
  bool reachable = true;
  int serverRosterEpoch = 1;
  bool serverAccountActive = true;
  final Map<String, LocalEvent> ingestedEventsById = {};
  final Map<String, AuditEntry> ingestedAuditsById = {};
  List<RemoteEmployeeRow> serverEmployees = const [];

  @override
  Future<bool> isReachable() async => reachable;

  @override
  Future<RemoteUploadAck> uploadBatch({
    required String actorUserId,
    required AuthRole actorRole,
    required Set<String> allowedTeamIds,
    required Set<String> allowedHousingIds,
    required List<LocalEvent> events,
    required List<AuditEntry> audits,
  }) async {
    // RLS Policy 1: Viewer cannot write anything
    if (actorRole == AuthRole.viewer) {
      throw const OperationException(PermissionDenied());
    }

    final acceptedEvents = <String>{};
    final rejectedEvents = <String, String>{};
    for (final ev in events) {
      if (nextUploadRejections.containsKey(ev.eventId)) {
        rejectedEvents[ev.eventId] = nextUploadRejections[ev.eventId]!;
        continue;
      }
      // RLS Policy 2: Site supervisor can only write to scoped teams
      if (actorRole == AuthRole.siteSupervisor &&
          ev.teamId != null &&
          !allowedTeamIds.contains(ev.teamId)) {
        throw const OperationException(PermissionDenied());
      }
      // RLS Policy 3: Housing supervisor can only write to scoped housings
      if (actorRole == AuthRole.housingSupervisor &&
          ev.housingId != null &&
          !allowedHousingIds.contains(ev.housingId)) {
        throw const OperationException(PermissionDenied());
      }
      // Idempotent by eventId
      ingestedEventsById.putIfAbsent(ev.eventId, () => ev);
      acceptedEvents.add(ev.eventId);
    }

    final acceptedAudits = <String>{};
    for (final au in audits) {
      ingestedAuditsById.putIfAbsent(au.auditId, () => au);
      acceptedAudits.add(au.auditId);
    }

    return RemoteUploadAck(
      acceptedEventIds: acceptedEvents,
      acceptedAuditIds: acceptedAudits,
      rejectedEvents: rejectedEvents,
    );
  }

  final List<LocalEvent> serverInboundEvents = [];
  final Map<String, String> nextUploadRejections = {};

  @override
  Future<RemoteSyncPullResult> pullEvents({
    required int sinceServerSeq,
    int limit = 200,
  }) async {
    final filtered = serverInboundEvents
        .where((e) => (e.serverSeq ?? 0) > sinceServerSeq)
        .take(limit)
        .toList();
    var maxSeq = sinceServerSeq;
    for (final e in filtered) {
      if ((e.serverSeq ?? 0) > maxSeq) maxSeq = e.serverSeq!;
    }
    return RemoteSyncPullResult(events: filtered, lastServerSeq: maxSeq);
  }

  @override
  Future<RemoteRosterSnapshot> fetchSnapshot({
    required String actorUserId,
  }) async {
    return RemoteRosterSnapshot(
      rosterEpoch: serverRosterEpoch,
      accountActive: serverAccountActive,
      employees: serverEmployees,
    );
  }
}

void main() {
  late AppDatabase db;
  late _FixedClock clock;
  late EventRepository events;
  late AuditLogRepository audit;
  late OutboxRepository outbox;
  late _FakeRlsRemoteGateway gateway;
  late SyncEngine engine;

  const supActor = ActorContext(userId: 'sup-1', role: AuthRole.siteSupervisor);
  const supScope = ScopeSnapshot(teamIds: {'team-1'});

  setUp(() async {
    clock = _FixedClock(DateTime.utc(2026, 4, 19, 8));
    db = AppDatabase(NativeDatabase.memory());
    events = EventRepository(database: db, deviceId: 'dev-1', clock: clock);
    audit = AuditLogRepository(database: db, clock: clock);
    outbox = OutboxRepository(database: db, clock: clock);
    gateway = _FakeRlsRemoteGateway();
    engine = SyncEngine(database: db, outbox: outbox, gateway: gateway);
  });

  tearDown(() async {
    await db.close();
  });

  test('new supervisor device without local roster and offline throws ActivationRequired (PRD §23.6)', () async {
    gateway.reachable = false;
    await expectLater(
      engine.synchronize(actor: supActor, scope: supScope),
      throwsA(
        isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<ActivationRequired>(),
        ),
      ),
    );
  });

  test('idempotent upload and pre-revocation flush when roster_epoch increases (D-25, D-27)', () async {
    // Seed 1 employee so device is activated
    await db
        .into(db.employees)
        .insert(
          EmployeesCompanion.insert(
            iqamaNo: 'emp-1',
            fullNameAr: 'عامل 1',
          ),
        );

    // Record attendance and an audit entry while offline
    gateway.reachable = false;
    final appended = await events.append(
      const EventDraft(
        type: EventType.sitePresent,
        action: EventAction.set,
        businessDate: '2026-04-19',
        employeeUid: 'emp-1',
        teamId: 'team-1',
        userId: 'sup-1',
      ),
    );
    await audit.record(
      userId: 'sup-1',
      action: 'team_updated',
      entityType: 'team',
      entityId: 'team-1',
    );
    expect(await outbox.readPendingCount(), 2);

    final offlineRes = await engine.synchronize(
      actor: supActor,
      scope: supScope,
    );
    expect(offlineRes.offline, isTrue);
    expect(offlineRes.pendingRemaining, 2);

    // Meanwhile admin wipes roster on server (serverRosterEpoch becomes 2)
    gateway
      ..reachable = true
      ..serverRosterEpoch = 2;

    // First sync after reconnect: uploads pending event + audit FIRST, then revokes session!
    final onlineRes = await engine.synchronize(
      actor: supActor,
      scope: supScope,
    );
    expect(onlineRes.uploadedEventsCount, 1);
    expect(onlineRes.uploadedAuditsCount, 1);
    expect(onlineRes.pendingRemaining, 0);
    expect(onlineRes.sessionRevoked, isTrue);
    expect(onlineRes.rosterEpoch, 2);
    expect(gateway.ingestedEventsById.containsKey(appended.eventId), isTrue);

    // Re-uploading the same event to gateway is idempotent (still 1 row)
    await gateway.uploadBatch(
      actorUserId: supActor.userId,
      actorRole: supActor.role,
      allowedTeamIds: supScope.teamIds,
      allowedHousingIds: supScope.housingIds,
      events: [gateway.ingestedEventsById[appended.eventId]!],
      audits: const [],
    );
    expect(gateway.ingestedEventsById, hasLength(1));
  });

  test('RLS simulation across roles: viewer blocked from writing, site supervisor blocked from unassigned team', () async {
    await db
        .into(db.employees)
        .insert(
          EmployeesCompanion.insert(
            iqamaNo: 'emp-1',
            fullNameAr: 'عامل 1',
          ),
        );
    await events.append(
      const EventDraft(
        type: EventType.sitePresent,
        action: EventAction.set,
        businessDate: '2026-04-19',
        employeeUid: 'emp-1',
        teamId: 'team-other',
        userId: 'sup-1',
      ),
    );

    // Viewer cannot upload
    await expectLater(
      engine.synchronize(
        actor: const ActorContext(userId: 'v-1', role: AuthRole.viewer),
        scope: const ScopeSnapshot(),
      ),
      throwsA(
        isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<PermissionDenied>(),
        ),
      ),
    );

    // Site supervisor scoped only to team-1 cannot upload event for team-other
    await expectLater(
      engine.synchronize(actor: supActor, scope: supScope),
      throwsA(
        isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<PermissionDenied>(),
        ),
      ),
    );

    // Exponential backoff helper
    expect(SyncEngine.backoffForAttempt(1), const Duration(seconds: 2));
    expect(SyncEngine.backoffForAttempt(3), const Duration(seconds: 8));
  });

  group('Section 9: Multi-Device Sync & Supabase Ingest Integration', () {
    test('Server rejected events transition to rejected status with reason and do not re-upload', () async {
      await db.into(db.settings).insert(
        SettingsCompanion.insert(key: 'device_activated', value: 'true'),
      );

      final ev1 = await events.append(
        const EventDraft(
          type: EventType.sitePresent,
          action: EventAction.set,
          businessDate: '2026-04-19',
          employeeUid: 'emp-bad',
          teamId: 'team-1',
          userId: 'sup-1',
        ),
      );

      gateway.nextUploadRejections[ev1.eventId] = 'employee_inactive_on_server';

      final result = await engine.synchronize(actor: supActor, scope: supScope);
      expect(result.uploadedEventsCount, 0);

      // Verify rejected event in outbox
      final rejectedCount = await outbox.readRejectedCount();
      expect(rejectedCount, 1);

      final rejectedRows = await outbox.readRejectedEvents();
      expect(rejectedRows.length, 1);
      expect(rejectedRows.first.eventId, ev1.eventId);

      final dbRow = await (db.select(db.events)..where((e) => e.eventId.equals(ev1.eventId))).getSingle();
      expect(dbRow.syncStatus, 'rejected');
      expect(dbRow.rejectReason, 'employee_inactive_on_server');

      // Subsequent sync does NOT re-attempt upload
      final secondSync = await engine.synchronize(actor: supActor, scope: supScope);
      expect(secondSync.uploadedEventsCount, 0);
      expect(secondSync.pendingRemaining, 0);
    });

    test('Inbound events with server_seq are pulled and applied idempotently', () async {
      await db.into(db.settings).insert(
        SettingsCompanion.insert(key: 'device_activated', value: 'true'),
      );

      const remoteEv1 = LocalEvent(
        eventId: 'remote-ev-1',
        type: EventType.sitePresent,
        action: EventAction.set,
        businessDate: '2026-04-19',
        deviceSeq: 1,
        serverSeq: 101,
        teamId: 'team-1',
        employeeUid: 'emp-101',
      );

      gateway.serverInboundEvents.add(remoteEv1);

      // First sync pulls and applies
      await engine.synchronize(actor: supActor, scope: supScope);

      final localEvents = await (db.select(db.events)..where((e) => e.eventId.equals('remote-ev-1'))).get();
      expect(localEvents.length, 1);
      expect(localEvents.first.serverSeq, 101);
      expect(localEvents.first.syncStatus, 'synced');

      // Duplicate sync with same event remains idempotent
      await engine.synchronize(actor: supActor, scope: supScope);
      final localEventsAfter = await (db.select(db.events)..where((e) => e.eventId.equals('remote-ev-1'))).get();
      expect(localEventsAfter.length, 1);
    });

    test('Deactivated account on server immediately revokes session', () async {
      await db.into(db.settings).insert(
        SettingsCompanion.insert(key: 'device_activated', value: 'true'),
      );

      gateway.serverAccountActive = false;

      final result = await engine.synchronize(actor: supActor, scope: supScope);
      expect(result.sessionRevoked, isTrue);
    });
  });
}
