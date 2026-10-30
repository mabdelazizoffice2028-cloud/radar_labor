import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/supervisor_task_strings.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/sync/outbox_repository.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/sync/sync_batch_uploader.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/operations_housing_workers_loader.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:radar_labor/features/operations/data/site_attendance_row_builder.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/widgets/supervisor_task_badge_resolver.dart';

final class _MultiBatchMockGateway implements RemoteSyncGateway {
  final List<List<LocalEvent>> uploadedBatches = [];

  @override
  Future<bool> isReachable() async => true;

  @override
  Future<RemoteUploadAck> uploadBatch({
    required String actorUserId,
    required AuthRole actorRole,
    required Set<String> allowedTeamIds,
    required Set<String> allowedHousingIds,
    required List<LocalEvent> events,
    required List<AuditEntry> audits,
  }) async {
    uploadedBatches.add(List.of(events));
    return RemoteUploadAck(
      acceptedEventIds: events.map((e) => e.eventId).toSet(),
      acceptedAuditIds: audits.map((a) => a.auditId).toSet(),
    );
  }

  @override
  Future<RemoteRosterSnapshot> fetchSnapshot({required String actorUserId}) async =>
      const RemoteRosterSnapshot(rosterEpoch: 1);
}

void main() {
  group('Surgical Audit Fix 1: WorkerOption preserves employmentType & jobCategory', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.into(db.employees).insert(
        EmployeesCompanion.insert(
          iqamaNo: '1000000001',
          fullNameAr: 'عامل تأجير',
          fullNameEn: const Value('Rental Worker'),
          employmentType: const Value('rental'),
          jobCategory: const Value('operator'),
        ),
      );
    });

    tearDown(() => db.close());

    test('OperationsHousingWorkersLoader includes rental and operator attributes', () async {
      final workers = await OperationsHousingWorkersLoader.load(db, 'h1');
      expect(workers, hasLength(1));
      expect(workers.first.employmentType, 'rental');
      expect(workers.first.jobCategory, 'operator');
    });

    test('OperationsRepository includes rental and operator attributes', () async {
      final events = EventRepository(database: db, deviceId: 'dev-1', clock: const SystemClock());
      final repo = OperationsRepository(database: db, events: events);
      final workers = await repo.getHousingWorkers('h1');
      expect(workers, hasLength(1));
      expect(workers.first.employmentType, 'rental');
      expect(workers.first.jobCategory, 'operator');
    });

    test('SiteAttendanceRowBuilder includes rental and operator attributes', () async {
      final rows = await db.select(db.employees).get();
      final emp = rows.first;
      final worker = SiteAttendanceRowBuilder.toWorker(emp);
      expect(worker.employmentType, 'rental');
      expect(worker.jobCategory, 'operator');
    });
  });

  group('Surgical Audit Fix 3: SupervisorTaskBadgeResolver unreviewedCount bug', () {
    test('Housing supervisor shows Not Started even when rows are reviewedPresent', () {
      const state = HousingCheckState(
        selectedDate: '2026-10-27',
        todayDate: '2026-10-27',
        hasSavedRecordToday: false,
        hasDraftSaved: false,
        hasUnsavedChanges: false,
        rows: [
          HousingWorkerRow(
            worker: WorkerOption(id: 'w1', code: '101', nameAr: 'عامل'),
            reviewState: HousingReviewState.reviewedPresent,
          ),
        ],
      );
      const siteState = SiteAttendanceState(
        selectedDate: '2026-10-27',
        todayDate: '2026-10-27',
      );

      final badge = SupervisorTaskBadgeResolver.resolve(
        role: AuthRole.housingSupervisor,
        todayDate: '2026-10-27',
        arabic: false,
        housingState: state,
        siteState: siteState,
      );

      expect(badge.text, SupervisorTaskStrings.taskStatusNotStarted(false));
    });

    test('Housing supervisor shows Draft when hasDraftSaved is true', () {
      const state = HousingCheckState(
        selectedDate: '2026-10-27',
        todayDate: '2026-10-27',
        hasSavedRecordToday: false,
        hasDraftSaved: true,
        hasUnsavedChanges: false,
      );
      const siteState = SiteAttendanceState(
        selectedDate: '2026-10-27',
        todayDate: '2026-10-27',
      );

      final badge = SupervisorTaskBadgeResolver.resolve(
        role: AuthRole.housingSupervisor,
        todayDate: '2026-10-27',
        arabic: false,
        housingState: state,
        siteState: siteState,
      );

      expect(badge.text, SupervisorTaskStrings.taskStatusDraftSaved(false));
    });
  });

  group('Surgical Audit Fix 7: SyncBatchUploader loops over all pending outbox batches', () {
    late AppDatabase db;
    late OutboxRepository outbox;
    late _MultiBatchMockGateway gateway;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      outbox = OutboxRepository(database: db);
      gateway = _MultiBatchMockGateway();

      await db.transaction(() async {
        for (var i = 1; i <= 600; i++) {
          await db.into(db.events).insert(
            EventsCompanion.insert(
              eventId: 'evt-$i',
              deviceId: 'dev-1',
              deviceSeq: i,
              type: EventType.sitePresent.name,
              action: EventAction.set.name,
              businessDate: '2026-10-27',
              deviceTime: DateTime.utc(2026, 10, 27, 8, 0),
              syncStatus: const Value('pending'),
            ),
          );
        }
      });
    });

    tearDown(() => db.close());

    test('uploads 600 events across 2 batches (500 + 100) and marks all synced', () async {
      final uploader = SyncBatchUploader(outbox: outbox, gateway: gateway);
      const actor = ActorContext(
        userId: 'u1',
        role: AuthRole.siteSupervisor,
      );
      const scope = ScopeSnapshot(teamIds: {'t1'});

      final res = await uploader.upload(actor: actor, scope: scope);
      expect(res.events, 600);
      expect(gateway.uploadedBatches, hasLength(2));
      expect(gateway.uploadedBatches[0], hasLength(500));
      expect(gateway.uploadedBatches[1], hasLength(100));

      final remaining = await outbox.readPendingCount();
      expect(remaining, 0);
    });
  });

  group('Surgical Audit Fix 10: OutboxRepository readPendingCount count query', () {
    late AppDatabase db;
    late OutboxRepository outbox;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      outbox = OutboxRepository(database: db);
    });

    tearDown(() => db.close());

    test('correctly counts pending events + pending audits without loading entities', () async {
      expect(await outbox.readPendingCount(), 0);

      await db.into(db.events).insert(
        EventsCompanion.insert(
          eventId: 'e1',
          deviceId: 'dev-1',
          deviceSeq: 1,
          type: EventType.housingAbsent.name,
          action: EventAction.set.name,
          businessDate: '2026-10-27',
          deviceTime: DateTime.utc(2026, 10, 27, 8, 0),
          syncStatus: const Value('pending'),
        ),
      );

      await db.into(db.auditLogs).insert(
        AuditLogsCompanion.insert(
          auditId: 'a1',
          action: 'account_created',
          entityType: 'account',
          entityId: 'acc1',
          deviceId: 'd1',
          deviceTime: DateTime.utc(2026, 10, 27, 8, 0),
          syncStatus: const Value('pending'),
        ),
      );

      expect(await outbox.readPendingCount(), 2);
    });
  });

  group('Surgical Audit Fix 2 & 4: AccountsAdminController records audit logs', () {
    late AppDatabase db;
    late LocalAuthRepository auth;
    late AccountsAdminController controller;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      auth = LocalAuthRepository(db);
      controller = AccountsAdminController(db, auth);

      await db.into(db.employees).insert(
        EmployeesCompanion.insert(
          iqamaNo: '2000000001',
          fullNameAr: 'موظف تجريبي',
        ),
      );
      await db.into(db.employees).insert(
        EmployeesCompanion.insert(
          iqamaNo: '2000000002',
          fullNameAr: 'مشرف تجريبي',
        ),
      );
    });

    tearDown(() => db.close());

    test('create, update, resetPassword, and remove record audit logs', () async {
      final emps = await db.select(db.employees).get();
      final emp1 = emps.firstWhere((e) => e.iqamaNo == '2000000001');
      final emp2 = emps.firstWhere((e) => e.iqamaNo == '2000000002');

      await controller.create(
        AccountFormResult(
          employeeUid: emp1.employeeUid,
          displayName: 'Admin User',
          role: AuthRole.projectManager,
          password: 'Password123!',
        ),
      );

      var logs = await db.select(db.auditLogs).get();
      expect(logs.any((l) => l.action == 'account_created'), isTrue);

      await controller.create(
        AccountFormResult(
          employeeUid: emp2.employeeUid,
          displayName: 'Site Sup',
          role: AuthRole.siteSupervisor,
          password: 'Password123!',
        ),
      );

      final siteAcc = (await auth.accounts()).firstWhere((a) => a.role == AuthRole.siteSupervisor);

      await controller.update(
        siteAcc,
        const AccountFormResult(
          displayName: 'Site Sup Renamed',
          role: AuthRole.siteSupervisor,
        ),
      );
      logs = await db.select(db.auditLogs).get();
      expect(logs.any((l) => l.action == 'account_updated'), isTrue);

      await controller.resetPassword(siteAcc.id);
      logs = await db.select(db.auditLogs).get();
      expect(logs.any((l) => l.action == 'password_reset'), isTrue);

      await controller.remove(siteAcc);
      logs = await db.select(db.auditLogs).get();
      expect(logs.any((l) => l.action == 'account_deactivated'), isTrue);
    });
  });
}
