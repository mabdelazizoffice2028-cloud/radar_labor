import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/roster_admin_repository.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/roster_wipe_plan.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this.now);
  final DateTime now;
  @override
  DateTime nowUtc() => now;
}

void main() {
  late AppDatabase db;
  late _FixedClock clock;
  late AuditLogRepository audit;
  late LocalAuthRepository auth;
  late RosterAdminRepository adminRepo;
  late EventRepository events;

  const adminActor = ActorContext(
    userId: 'pm-1',
    role: AuthRole.projectManager,
  );
  const supervisorActor = ActorContext(
    userId: 'sup-1',
    role: AuthRole.siteSupervisor,
  );

  setUp(() async {
    clock = _FixedClock(DateTime.utc(2026, 4, 19, 6));
    db = AppDatabase(NativeDatabase.memory());
    audit = AuditLogRepository(database: db, clock: clock);
    auth = LocalAuthRepository(db, clock);
    adminRepo = RosterAdminRepository(database: db, audit: audit, auth: auth);
    events = EventRepository(
      database: db,
      deviceId: 'test-device',
      clock: clock,
    );

    await db
        .into(db.appUsers)
        .insert(
          AppUsersCompanion.insert(
            id: 'pm-1',
            displayName: 'مدير المشروع',
            role: AuthRole.projectManager.name,
            pwHash: 'h',
            pwSalt: 's',
            kdfParams: '{}',
            createdAt: clock.nowUtc(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('schemaVersion=6 initializes roster_epoch=1 and supports viewer without employeeUid (BC-7)', () async {
    expect(db.schemaVersion, 6);
    expect(await adminRepo.readRosterEpoch(), 1);

    final viewerId = await adminRepo.createAccountAudited(
      actor: adminActor,
      employeeUid: null,
      displayName: 'مراقب عام',
      role: AuthRole.viewer,
    );
    final accounts = await auth.accounts();
    final viewer = accounts.firstWhere((a) => a.id == viewerId);
    expect(viewer.employeeUid, isNull);
    expect(viewer.role, AuthRole.viewer);

    final logs = await audit.readForAdmin(actor: adminActor, arabic: true);
    expect(
      logs.any(
        (l) =>
            l.entry.action == 'account_created' && l.entry.entityId == viewerId,
      ),
      isTrue,
    );
  });

  test('worker mutations write atomic audit_log without personal names and archive preserves events (D-24, D-26)', () async {
    final empUid = await adminRepo.createWorker(
      actor: adminActor,
      code: 'E-501',
      fullNameAr: 'سعيد القحطاني',
      fullNameEn: 'Saeed Alqahtani',
    );

    await events.append(
      EventDraft(
        type: EventType.sitePresent,
        action: EventAction.set,
        businessDate: '2026-04-19',
        employeeUid: empUid,
        teamId: 'team-1',
        userId: 'pm-1',
      ),
    );

    await adminRepo.archiveWorker(actor: adminActor, employeeUid: empUid);

    final empRow = await (db.select(
      db.employees,
    )..where((e) => e.iqamaNo.equals(empUid))).getSingle();
    expect(empRow.isActive, isFalse);

    // Historical attendance event is preserved
    final dayEvents = await events.readBusinessDate('2026-04-19');
    expect(dayEvents.any((e) => e.employeeUid == empUid), isTrue);

    // Raw audit_log table contains no personal names (Q-5)
    final rawLogs = await db.select(db.auditLogs).get();
    expect(rawLogs, hasLength(2));
    for (final raw in rawLogs) {
      expect(raw.entityId, empUid);
      expect(raw.toString().contains('سعيد'), isFalse);
    }

    // Resolved audit log resolves actor and entity names for admin
    final resolved = await audit.readForAdmin(actor: adminActor, arabic: true);
    expect(resolved.first.actorDisplayName, 'مدير المشروع');
    expect(resolved.first.entityDisplayName, 'سعيد القحطاني');

    // Supervisor is denied access to audit log
    expect(
      () => audit.readForAdmin(actor: supervisorActor, arabic: true),
      throwsA(
        isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<PermissionDenied>(),
        ),
      ),
    );
  });

  test('failed transaction leaves no orphan audit_log entry', () async {
    final beforeCount = (await db.select(db.auditLogs).get()).length;
    await expectLater(
      adminRepo.archiveWorker(
        actor: adminActor,
        employeeUid: 'non-existent-worker',
      ),
      throwsA(isA<OperationException>()),
    );
    final afterCount = (await db.select(db.auditLogs).get()).length;
    expect(afterCount, beforeCount);
  });

  test('wipeRoster enforces backup + confirmation, increments epoch, and import reactivates by code (D-24, D-25, D-29)', () async {
    final uid1 = await adminRepo.createWorker(
      actor: adminActor,
      code: '1000000100',
      fullNameAr: 'عامل أول',
    );
    final uid2 = await adminRepo.createWorker(
      actor: adminActor,
      code: '1000000200',
      fullNameAr: 'عامل ثان',
    );

    // Without backupExported -> throws RosterWipeNotConfirmed
    await expectLater(
      adminRepo.wipeRoster(
        actor: adminActor,
        backupExported: false,
        confirmationText: 'WIPE',
      ),
      throwsA(
        isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<RosterWipeNotConfirmed>(),
        ),
      ),
    );

    // Wrong confirmation word -> throws RosterWipeNotConfirmed
    await expectLater(
      adminRepo.wipeRoster(
        actor: adminActor,
        backupExported: true,
        confirmationText: 'delete',
      ),
      throwsA(
        isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<RosterWipeNotConfirmed>(),
        ),
      ),
    );

    // Valid backup export + confirmation -> archives all workers and increments roster_epoch
    final backupJson = await adminRepo.exportRosterBackupJson(
      actor: adminActor,
    );
    expect(backupJson.contains('1000000100'), isTrue);

    final plan = await adminRepo.wipeRoster(
      actor: adminActor,
      backupExported: true,
      confirmationText: 'مسح',
    );
    expect(plan.previousEpoch, 1);
    expect(plan.nextEpoch, 2);
    expect(await adminRepo.readRosterEpoch(), 2);

    final activeAfterWipe = await (db.select(
      db.employees,
    )..where((e) => e.archivedAt.isNull())).get();
    expect(activeAfterWipe, isEmpty);

    // Re-importing W-100 reactivates the exact same employeeUid (D-29)
    final importRes = await adminRepo.importRosterAudited(
      actor: adminActor,
      rows: const [
        RosterImportEntry(
          code: '1000000100',
          name: 'عامل أول محدث',
          designation: 'Technician',
          supplier: 'SubA',
        ),
      ],
    );
    expect(importRes.added, 0);
    expect(importRes.updated, 1);

    final reactivated = await (db.select(
      db.employees,
    )..where((e) => e.iqamaNo.equals(uid1))).getSingle();
    expect(reactivated.employeeUid, uid1);
    expect(reactivated.isActive, isTrue);

    final stillArchived = await (db.select(
      db.employees,
    )..where((e) => e.iqamaNo.equals(uid2))).getSingle();
    expect(stillArchived.isActive, isFalse);
  });
}
