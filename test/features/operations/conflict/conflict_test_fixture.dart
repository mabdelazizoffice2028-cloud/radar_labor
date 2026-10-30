import 'package:drift/native.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/settings_attendance_draft_store.dart';
import 'package:radar_labor/features/operations/data/site_attendance_repository.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import '../../../support/seed_builder.dart';

final class FixedTestClock implements Clock {
  const FixedTestClock(this.now);
  final DateTime now;
  @override
  DateTime nowUtc() => now;
}

final class ConflictTestFixture {
  late AppDatabase db;
  late EventRepository events;
  late SiteAttendanceRepository repo;

  static const actor1 = ActorContext(userId: 'sup-1', role: AuthRole.siteSupervisor);
  static const actor2 = ActorContext(userId: 'sup-2', role: AuthRole.siteSupervisor);
  static const scopeA = ScopeSnapshot(teamIds: {'team-a'}, housingIds: {});
  static const scopeB = ScopeSnapshot(teamIds: {'team-b'}, housingIds: {});
  static const teamA = EntityOption(id: 'team-a', nameAr: 'فرقة أ', nameEn: 'Team A');
  static const teamB = EntityOption(id: 'team-b', nameAr: 'فرقة ب', nameEn: 'Team B');

  Future<void> setUp() async {
    db = AppDatabase(NativeDatabase.memory());
    final clock = FixedTestClock(DateTime.utc(2026, 4, 20, 8));
    events = EventRepository(database: db, deviceId: 'dev-1', clock: clock);
    final draftStore = SettingsAttendanceDraftStore(
      settings: LocalSettingsRepository(db), clock: clock,
    );
    repo = SiteAttendanceRepository(
      database: db, events: events, draftStore: draftStore, clock: clock,
    );

    final seed = SeedBuilder(database: db, events: events);
    await seed.seedTeam(id: 'team-a', nameAr: 'فرقة أ', nameEn: 'Team A');
    await seed.seedTeam(id: 'team-b', nameAr: 'فرقة ب', nameEn: 'Team B');
    await seed.seedWorker(uid: 'w1', code: '101', nameAr: 'أحمد', teamId: 'team-a');
    await seed.seedWorker(uid: 'w2', code: '102', nameAr: 'خالد', teamId: 'team-a');
    await seed.seedWorker(uid: 'w3', code: '201', nameAr: 'سعيد', teamId: 'team-b');
  }

  Future<void> saveTeamBWithW3() async {
    final loaded = await repo.loadDay(actor: actor2, scope: scopeB, team: teamB, date: '2026-04-20', arabic: true);
    final rows = loaded.rows.map((r) => r.worker.id == 'w3' ? r.copyWith(isPresent: true) : r).toList();
    final prep = await repo.prepareSave(actor: actor2, scope: scopeB, team: teamB, date: '2026-04-20', rows: rows, baseline: loaded.baseline, arabic: true);
    await repo.save(actor: actor2, scope: scopeB, prepared: prep, resolutions: const {}, arabic: true);
  }

  Future<PreparedSiteSave> prepareTeamAWithGuestW3() async {
    final loaded = await repo.loadDay(actor: actor1, scope: scopeA, team: teamA, date: '2026-04-20', arabic: true);
    final guests = await repo.searchCrossTeamWorkers(query: 'سعيد', excludeWorkerIds: {}, arabic: true);
    final rows = [
      ...loaded.rows.map((r) => r.worker.id == 'w1' ? r.copyWith(isPresent: true) : r),
      AttendanceRow(worker: guests.single.worker, isPresent: true, origin: WorkerRowOrigin.guest, originTeamNameAr: teamB.nameAr, originTeamNameEn: teamB.nameEn),
    ];
    return repo.prepareSave(actor: actor1, scope: scopeA, team: teamA, date: '2026-04-20', rows: rows, baseline: loaded.baseline, arabic: true);
  }

  Future<void> tearDown() async => db.close();
}
