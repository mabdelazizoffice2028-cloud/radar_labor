import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/settings_attendance_draft_store.dart';
import 'package:radar_labor/features/operations/data/site_attendance_repository.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

final class _C implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 4, 19, 10, 0);
}

void main() {
  test('Auto-fix QA clears housing absence and writes worker_history on save', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = _C();
    final events = EventRepository(database: db, deviceId: 'd', clock: clock);
    final repo = SiteAttendanceRepository(
      database: db, events: events, clock: clock,
      draftStore: SettingsAttendanceDraftStore(settings: LocalSettingsRepository(db), clock: clock),
    );

    await db.into(db.teams).insert(TeamsCompanion.insert(teamId: 't1', nameAr: 'فريق 1'));
    await db.into(db.employees).insert(EmployeesCompanion.insert(
      iqamaNo: '1000000001', fullNameAr: 'عامل', currentTeamId: const Value('t1'),
    ));
    await events.append(EventDraft(
      type: EventType.housingAbsent, action: EventAction.set, businessDate: '2026-04-19',
      housingId: HousingConstants.defaultHousingId, employeeUid: '1000000001', userId: 'h-1',
    ));

    final worker = const WorkerOption(id: '1000000001', code: '1000000001', nameAr: 'عامل');
    final diff = AttendanceDiff.compute(
      baseline: const AttendanceBaseline(kind: BaselineKind.none),
      selectedIds: {'1000000001'}, workersById: {'1000000001': worker}, arabic: true,
    );
    final prepared = PreparedSiteSave(
      team: const EntityOption(id: 't1', nameAr: 'فريق 1'), date: '2026-04-19',
      selectedWorkerIds: {'1000000001'}, diff: diff, conflicts: const [], workersById: {'1000000001': worker},
    );

    await repo.save(
      actor: const ActorContext(userId: 's1', role: AuthRole.siteSupervisor),
      scope: const ScopeSnapshot(teamIds: {'t1'}, housingIds: {}),
      prepared: prepared, resolutions: {}, arabic: true,
    );

    final evts = await events.readBusinessDate('2026-04-19');
    expect(evts.any((e) => e.type == EventType.housingAbsent && e.action == EventAction.clear && e.employeeUid == '1000000001'), isTrue);
    final history = await db.select(db.workerHistory).get();
    expect(history.any((h) => h.iqamaNo == '1000000001' && h.action == 'auto_fix_housing_absence_cleared'), isTrue);
  });
}
