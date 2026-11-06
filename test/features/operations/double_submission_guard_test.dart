import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

final class _TestClock implements Clock {
  const _TestClock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 11, 6, 8);
}

void main() {
  late AppDatabase db;
  late EventRepository events;
  late OperationsRepository opsRepo;
  const clock = _TestClock();

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.settings).insert(
      SettingsCompanion.insert(key: AppSettingKeys.deviceSequence, value: '100'),
    );
    events = EventRepository(
      database: db,
      deviceId: 'dev_test',
      clock: clock,
    );
    opsRepo = OperationsRepository(database: db, events: events);
  });

  tearDown(() async {
    await db.close();
  });

  group('OperationsController re-entrancy locks', () {
    test('concurrent saveHousingCheck throws DatabaseBusy', () async {
      final ctrl = OperationsController(
        store: opsRepo,
        clock: clock,
        actorUserId: 'housing_sup_1',
        capabilities: AuthRole.housingSupervisor.capabilities,
        allowedHousingIds: ['H1'],
      );

      final check = PreparedHousingCheck(
        housing: const EntityOption(id: 'H1', nameAr: 'سكن 1', nameEn: 'Housing 1'),
        date: '2026-11-06',
        summary: const AttendanceSummary(
          workerCount: 1,
          workerIds: {'EMP_001'},
          confirmationText: 'Confirm',
          messageText: 'Summary message',
        ),
      );

      final f1 = ctrl.saveHousingCheck(check);
      expect(
        () => ctrl.saveHousingCheck(check),
        throwsA(isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<DatabaseBusy>(),
        )),
      );

      await f1;
    });

    test('concurrent saveSiteAttendance throws DatabaseBusy', () async {
      final ctrl = OperationsController(
        store: opsRepo,
        clock: clock,
        actorUserId: 'site_sup_1',
        capabilities: AuthRole.siteSupervisor.capabilities,
        allowedTeamIds: ['T1'],
      );

      final attendance = PreparedSiteAttendance(
        team: const EntityOption(id: 'T1', nameAr: 'فريق 1', nameEn: 'Team 1'),
        date: '2026-11-06',
        summary: const AttendanceSummary(
          workerCount: 1,
          workerIds: {'EMP_001'},
          confirmationText: 'Confirm',
          messageText: 'Summary message',
        ),
      );

      final f1 = ctrl.saveSiteAttendance(attendance);
      expect(
        () => ctrl.saveSiteAttendance(attendance),
        throwsA(isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<DatabaseBusy>(),
        )),
      );

      await f1;
    });
  });

  group('EventRepository atomic transaction and rollback resilience', () {
    test('transaction rolls back cleanly when error occurs mid-batch', () async {
      final initialSeqRow = await (db.select(db.settings)
            ..where((s) => s.key.equals(AppSettingKeys.deviceSequence)))
          .getSingle();
      expect(initialSeqRow.value, '100');

      final validDraft = EventDraft(
        type: EventType.housingCheck,
        action: EventAction.set,
        businessDate: '2026-11-06',
        housingId: 'H1',
        userId: 'admin_1',
      );

      expect(
        () => events.appendBatch([
          validDraft,
          EventDraft(
            type: EventType.housingAbsent,
            action: EventAction.set,
            businessDate: 'invalid-date-format',
            userId: 'admin_1',
          ),
        ]),
        throwsA(isA<ArgumentError>()),
      );

      final allEvents = await db.select(db.events).get();
      expect(allEvents, isEmpty);

      final afterSeqRow = await (db.select(db.settings)
            ..where((s) => s.key.equals(AppSettingKeys.deviceSequence)))
          .getSingle();
      expect(afterSeqRow.value, '100');
    });
  });
}
