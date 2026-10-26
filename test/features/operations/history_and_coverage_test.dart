import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_coverage_repository.dart';
import 'package:radar_labor/features/operations/data/history_repository.dart';

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
  late HistoryRepository historyRepo;
  late DashboardCoverageRepository coverageRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = _FixedClock(DateTime.utc(2026, 4, 20, 8)); // 2026-04-20 Riyadh
    events = EventRepository(database: db, deviceId: 'dev-1', clock: clock);
    historyRepo = HistoryRepository(database: db, events: events, clock: clock);
    coverageRepo = DashboardCoverageRepository(database: db, events: events);

    final seed = SeedBuilder(database: db, events: events);
    await seed.seedTeam(
      id: 'team-a',
      nameAr: 'فرقة أ',
      nameEn: 'Team A',
      supervisorUserId: 'sup-a',
    );
    await seed.seedTeam(id: 'team-b', nameAr: 'فرقة ب', nameEn: 'Team B');
    await seed.seedHousing(id: 'h-1', nameAr: 'سكن 1', nameEn: 'Housing 1');
    await seed.seedWorker(
      uid: 'w1',
      code: '101',
      nameAr: 'أحمد',
      nameEn: 'Ahmed',
      teamId: 'team-a',
      housingId: 'h-1',
    );
    await seed.seedUser(
      id: 'sup-a',
      employeeUid: 'w1',
      displayName: 'المشرف سالم',
      role: AuthRole.siteSupervisor,
      teamIds: const ['team-a'],
    );
    await seed.seedUser(
      id: 'sup-inactive',
      employeeUid: 'w1',
      displayName: 'مشرف موقوف',
      role: AuthRole.siteSupervisor,
      active: false,
      teamIds: const ['team-b'],
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('HistoryRepository marks days within 7 days editable for supervisor and >7 days locked', () async {
    final seed = SeedBuilder(database: db, events: events);
    await seed.seedSiteAttendance(
      businessDate: '2026-04-18', // 2 days ago -> editable
      teamId: 'team-a',
      presentWorkerUids: const ['w1'],
      actorUserId: 'sup-a',
    );
    await seed.seedSiteAttendance(
      businessDate: '2026-04-10', // 10 days ago -> locked (>7 days)
      teamId: 'team-a',
      presentWorkerUids: const ['w1'],
      actorUserId: 'sup-a',
    );

    final supPage = await historyRepo.loadHistory(
      actor: const ActorContext(userId: 'sup-a', role: AuthRole.siteSupervisor),
      scope: const ScopeSnapshot(teamIds: {'team-a'}),
      daysWindow: 14,
      arabic: true,
    );

    expect(supPage.cards.length, 2);
    expect(supPage.cards[0].businessDate, '2026-04-18');
    expect(supPage.cards[0].canEdit, isTrue);
    expect(supPage.cards[0].lastActorName, 'المشرف سالم');

    expect(supPage.cards[1].businessDate, '2026-04-10');
    expect(supPage.cards[1].canEdit, isFalse);

    // Admin sees all history grouped by site and supervisor, never editable
    final adminPage = await historyRepo.loadHistory(
      actor: const ActorContext(
        userId: 'admin-1',
        role: AuthRole.projectManager,
      ),
      scope: const ScopeSnapshot(),
      daysWindow: 14,
      arabic: true,
    );
    expect(adminPage.cards.every((c) => !c.canEdit), isTrue);
    expect(adminPage.bySite['فرقة أ']?.length, 2);
    expect(adminPage.bySupervisor['المشرف سالم']?.length, 2);
  });

  test('DashboardCoverageRepository populates active supervisor names and omits inactive users', () async {
    final coverage = await coverageRepo.watch('2026-04-20').first;
    final teamAWarning = coverage.missingTeams.firstWhere(
      (w) => w.id == 'team-a',
    );
    final teamBWarning = coverage.missingTeams.firstWhere(
      (w) => w.id == 'team-b',
    );
    expect(teamAWarning.supervisorNames, ['المشرف سالم']);
    expect(teamBWarning.supervisorNames, isEmpty);
  });
}
