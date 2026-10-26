import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/settings_attendance_draft_store.dart';
import 'package:radar_labor/features/operations/data/site_attendance_repository.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

import '../../support/seed_builder.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;

  @override
  DateTime nowUtc() => _now;
}

void main() {
  late AppDatabase db;
  late Clock clock;
  late EventRepository events;
  late SettingsAttendanceDraftStore draftStore;
  late SiteAttendanceRepository repo;

  const actor = ActorContext(userId: 'sup-1', role: AuthRole.siteSupervisor);
  const scope = ScopeSnapshot(teamIds: {'team-a'}, housingIds: {});
  const teamA = EntityOption(id: 'team-a', nameAr: 'فرقة أ', nameEn: 'Team A');
  const teamB = EntityOption(id: 'team-b', nameAr: 'فرقة ب', nameEn: 'Team B');

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = _FixedClock(DateTime.utc(2026, 4, 20, 8)); // 2026-04-20 Riyadh
    events = EventRepository(database: db, deviceId: 'dev-1', clock: clock);
    draftStore = SettingsAttendanceDraftStore(
      settings: LocalSettingsRepository(db),
      clock: clock,
    );
    repo = SiteAttendanceRepository(
      database: db,
      events: events,
      draftStore: draftStore,
      clock: clock,
    );

    final seed = SeedBuilder(database: db, events: events);
    await seed.seedTeam(id: 'team-a', nameAr: 'فرقة أ', nameEn: 'Team A');
    await seed.seedTeam(id: 'team-b', nameAr: 'فرقة ب', nameEn: 'Team B');
    await seed.seedWorker(
      uid: 'w1',
      code: '101',
      nameAr: 'أحمد',
      nameEn: 'Ahmed',
      teamId: 'team-a',
    );
    await seed.seedWorker(
      uid: 'w2',
      code: '102',
      nameAr: 'خالد',
      nameEn: 'Khaled',
      teamId: 'team-a',
    );
    await seed.seedWorker(
      uid: 'w3',
      code: '201',
      nameAr: 'سعيد',
      nameEn: 'Saeed',
      teamId: 'team-b',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'loadDay follows 4-level priority: empty -> suggestion -> saved -> draft',
    () async {
      final seed = SeedBuilder(database: db, events: events);

      // 1. Empty when no history exists
      final emptyDay = await repo.loadDay(
        actor: actor,
        scope: scope,
        team: teamA,
        date: '2026-04-20',
        arabic: true,
      );
      expect(emptyDay.initialSource, AttendanceInitialSource.empty);
      expect(emptyDay.rows.where((r) => r.isPresent), isEmpty);
      expect(emptyDay.baseline.kind, BaselineKind.none);

      // 2. Suggestion from last submitted day within 14 days (2026-04-18)
      await seed.seedSiteAttendance(
        businessDate: '2026-04-18',
        teamId: 'team-a',
        presentWorkerUids: const ['w1'],
        actorUserId: 'sup-1',
      );
      final suggested = await repo.loadDay(
        actor: actor,
        scope: scope,
        team: teamA,
        date: '2026-04-20',
        arabic: true,
      );
      expect(suggested.initialSource, AttendanceInitialSource.suggestion);
      expect(suggested.initialSourceDate, '2026-04-18');
      expect(suggested.rows.where((r) => r.isPresent).map((r) => r.worker.id), [
        'w1',
      ]);

      // 3. Saved day overrides suggestion
      await seed.seedSiteAttendance(
        businessDate: '2026-04-20',
        teamId: 'team-a',
        presentWorkerUids: const ['w2'],
        actorUserId: 'sup-1',
      );
      final saved = await repo.loadDay(
        actor: actor,
        scope: scope,
        team: teamA,
        date: '2026-04-20',
        arabic: true,
      );
      expect(saved.initialSource, AttendanceInitialSource.savedDay);
      expect(saved.baseline.kind, BaselineKind.lastSave);
      expect(saved.rows.where((r) => r.isPresent).map((r) => r.worker.id), [
        'w2',
      ]);

      // 4. Draft overrides saved day
      await draftStore.writeDraft(
        teamId: 'team-a',
        date: '2026-04-20',
        workerIds: const ['w1', 'w2'],
      );
      final drafted = await repo.loadDay(
        actor: actor,
        scope: scope,
        team: teamA,
        date: '2026-04-20',
        arabic: true,
      );
      expect(drafted.initialSource, AttendanceInitialSource.draft);
      expect(
        drafted.rows.where((r) => r.isPresent).map((r) => r.worker.id).toSet(),
        {'w1', 'w2'},
      );
    },
  );

  test('inactive worker recorded on saved day loads as locked row', () async {
    final seed = SeedBuilder(database: db, events: events);
    await seed.seedSiteAttendance(
      businessDate: '2026-04-19',
      teamId: 'team-a',
      presentWorkerUids: const ['w1'],
      actorUserId: 'sup-1',
    );
    await (db.update(db.employees)..where((r) => r.employeeUid.equals('w1')))
        .write(const EmployeesCompanion(isActive: Value(false)));

    final loaded = await repo.loadDay(
      actor: actor,
      scope: scope,
      team: teamA,
      date: '2026-04-19',
      arabic: true,
    );
    final w1Row = loaded.rows.firstWhere((r) => r.worker.id == 'w1');
    expect(w1Row.isLocked, isTrue);
    expect(w1Row.isPresent, isTrue);
  });

  test(
    'save resolves conflicts atomically and undo restores previous ledger',
    () async {
      final seed = SeedBuilder(database: db, events: events);
      await seed.seedSiteAttendance(
        businessDate: '2026-04-20',
        teamId: 'team-b',
        presentWorkerUids: const ['w3'],
        actorUserId: 'sup-2',
      );

      final loaded = await repo.loadDay(
        actor: actor,
        scope: scope,
        team: teamA,
        date: '2026-04-20',
        arabic: true,
      );
      final guests = await repo.searchCrossTeamWorkers(
        query: 'سعيد',
        excludeWorkerIds: {},
        arabic: true,
      );
      expect(guests.single.worker.id, 'w3');

      final rowsWithGuest = [
        for (final r in loaded.rows) r.copyWith(isPresent: r.worker.id == 'w1'),
        AttendanceRow(
          worker: guests.single.worker,
          isPresent: true,
          origin: WorkerRowOrigin.guest,
          originTeamNameAr: teamB.nameAr,
          originTeamNameEn: teamB.nameEn,
        ),
      ];

      final prepared = await repo.prepareSave(
        actor: actor,
        scope: scope,
        team: teamA,
        date: '2026-04-20',
        rows: rowsWithGuest,
        baseline: loaded.baseline,
        arabic: true,
      );
      expect(prepared.conflicts.single.worker.id, 'w3');

      expect(
        () => repo.save(
          actor: actor,
          scope: scope,
          prepared: prepared,
          resolutions: const {},
          arabic: true,
        ),
        throwsA(isA<OperationException>()),
      );

      final saved = await repo.save(
        actor: actor,
        scope: scope,
        prepared: prepared,
        resolutions: const {'w3': ConflictResolutionChoice.removeFromOtherTeam},
        arabic: true,
      );

      final afterSaveLedger = AttendanceLedger(
        await events.readBusinessDate('2026-04-20'),
      );
      expect(afterSaveLedger.presentWorkerIdsForTeam('team-a'), {'w1', 'w3'});
      expect(afterSaveLedger.presentWorkerIdsForTeam('team-b'), isEmpty);

      await repo.undo(
        actor: actor,
        scope: scope,
        teamId: 'team-a',
        plan: saved.undoPlan,
      );
      final afterUndoLedger = AttendanceLedger(
        await events.readBusinessDate('2026-04-20'),
      );
      expect(afterUndoLedger.presentWorkerIdsForTeam('team-a'), isEmpty);
      expect(afterUndoLedger.isSiteSubmitted('team-a'), isFalse);
      expect(afterUndoLedger.presentWorkerIdsForTeam('team-b'), {'w3'});
    },
  );
}
