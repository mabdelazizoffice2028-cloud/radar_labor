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
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import '../../../support/seed_builder.dart';

final class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 4, 20, 8);
}

void main() {
  test('Draft resilience: drafts survive simulated app termination and restore accurately', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final clock = _Clock();
    final events = EventRepository(database: db, deviceId: 'dev-1', clock: clock);
    final settings = LocalSettingsRepository(db);
    final draftStore = SettingsAttendanceDraftStore(settings: settings, clock: clock);

    final seed = SeedBuilder(database: db, events: events);
    await seed.seedTeam(id: 'team-a', nameAr: 'فرقة أ');
    await seed.seedWorker(uid: 'w1', code: '101', nameAr: 'أحمد', teamId: 'team-a');
    await seed.seedWorker(uid: 'w2', code: '102', nameAr: 'خالد', teamId: 'team-a');

    // 1. Supervisor edits attendance, writing draft
    await draftStore.writeDraft(
      teamId: 'team-a', date: '2026-04-20', workerIds: {'w1'},
    );

    // 2. SIMULATE APP CRASH / PROCESS TERMINATION (new repo instance, same DB)
    final freshDraftStore = SettingsAttendanceDraftStore(settings: LocalSettingsRepository(db), clock: clock);
    final freshRepo = SiteAttendanceRepository(
      database: db, events: events, draftStore: freshDraftStore, clock: clock,
    );

    // 3. Re-open day check-in
    const actor = ActorContext(userId: 'sup-1', role: AuthRole.siteSupervisor);
    const scope = ScopeSnapshot(teamIds: {'team-a'}, housingIds: {});
    const team = EntityOption(id: 'team-a', nameAr: 'فرقة أ');

    final loaded = await freshRepo.loadDay(
      actor: actor, scope: scope, team: team, date: '2026-04-20', arabic: true,
    );

    // Assert that draft is restored with exact presence and zero events committed
    expect(loaded.initialSource, AttendanceInitialSource.draft);
    expect(loaded.rows.firstWhere((r) => r.worker.id == 'w1').isPresent, isTrue);
    expect(loaded.rows.firstWhere((r) => r.worker.id == 'w2').isPresent, isFalse);

    final committedEvents = await events.readBusinessDate('2026-04-20');
    expect(committedEvents, isEmpty); // Events table remains completely clean!

    await db.close();
  });
}
