import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/features/operations/data/team_setup_repository.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

import '../../support/fixed_clock.dart';
import '../../support/seed_builder.dart';

void main() {
  late AppDatabase database;
  late EventRepository events;
  late LocalAuthRepository authRepo;
  late TeamSetupRepository teamSetupRepo;
  late SeedBuilder seed;

  const siteActor = ActorContext(
    userId: 'sup-1',
    role: AuthRole.siteSupervisor,
  );

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    events = EventRepository(
      database: database,
      deviceId: 'test-dev',
      clock: FixedClock(DateTime.utc(2026, 10, 23, 8)),
    );
    authRepo = LocalAuthRepository(database);
    teamSetupRepo = TeamSetupRepository(database: database);
    seed = SeedBuilder(database: database, events: events);

    await seed.seedWorker(
      uid: 'w-sup',
      code: 'S-01',
      nameAr: 'مشرف موقع',
      nameEn: 'Site Supervisor',
    );
    await seed.seedUser(
      id: 'sup-1',
      employeeUid: 'w-sup',
      displayName: 'Site Sup 1',
      role: AuthRole.siteSupervisor,
    );
    await seed.seedWorker(
      uid: 'w-1',
      code: 'W-01',
      nameAr: 'عامل ١',
      nameEn: 'Worker 1',
    );
    await seed.seedWorker(
      uid: 'w-2',
      code: 'W-02',
      nameAr: 'عامل ٢',
      nameEn: 'Worker 2',
    );
  });

  tearDown(() => database.close());

  test(
    'createTeam_atomicallyInsertsTeamScopeAndWorkersAndStreamsLiveScope',
    () async {
      final scopeEvents = <ScopeSnapshot>[];
      final sub = authRepo.watchScopes('sup-1').listen(scopeEvents.add);
      await pumpEventQueue();
      expect(scopeEvents.last.teamIds, isEmpty);

      final created = await teamSetupRepo.createTeam(
        actor: siteActor,
        nameAr: '  فريق   الخرسانة  ',
        nameEn: 'Concrete Team',
        workerIds: const {'w-1', 'w-2'},
      );
      await pumpEventQueue();
      await sub.cancel();

      expect(created.nameAr, 'فريق الخرسانة');
      expect(created.nameEn, 'Concrete Team');
      expect(scopeEvents.last.teamIds, contains(created.id));

      final teamRow = await (database.select(
        database.teams,
      )..where((t) => t.teamId.equals(created.id))).getSingle();
      expect(teamRow.supervisorUserId, 'sup-1');

      final workers = await (database.select(
        database.employees,
      )..where((e) => e.employeeUid.isIn(const ['w-1', 'w-2']))).get();
      for (final w in workers) {
        expect(w.currentTeamId, created.id);
        expect(w.rowVersion, 2);
      }

      // No attendance events are created during team setup
      expect(await events.readBusinessDate('2026-10-23'), isEmpty);
    },
  );

  test('createTeam_rollsBackEntireTransactionWhenAnyWorkerAssignedElsewhereOrInactive', () async {
    await seed.seedTeam(id: 'other-team', nameAr: 'فريق آخر');
    await seed.seedWorker(
      uid: 'w-taken',
      code: 'W-99',
      nameAr: 'عامل مسند',
      teamId: 'other-team',
    );

    await expectLater(
      teamSetupRepo.createTeam(
        actor: siteActor,
        nameAr: 'فريق جديد',
        workerIds: const {'w-1', 'w-taken'},
      ),
      throwsA(
        isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<WorkersUnavailable>().having((f) => f.workerIds, 'workerIds', {
            'w-taken',
          }),
        ),
      ),
    );

    // Verify no orphan team was created and w-1 was not modified
    final teams = await database.select(database.teams).get();
    expect(teams.map((t) => t.teamId), ['other-team']);

    final w1 = await (database.select(
      database.employees,
    )..where((e) => e.employeeUid.equals('w-1'))).getSingle();
    expect(w1.currentTeamId, isNull);
    expect(w1.rowVersion, 1);
  });

  test(
    'createTeam_rejectsDuplicateNormalizedTeamNameAndInvalidRoles',
    () async {
      await teamSetupRepo.createTeam(
        actor: siteActor,
        nameAr: 'فريق أحمد',
        workerIds: const {},
      );

      await expectLater(
        teamSetupRepo.createTeam(
          actor: siteActor,
          nameAr: '  فريق   احمد ',
          workerIds: const {},
        ),
        throwsA(
          isA<OperationException>().having(
            (e) => e.failure,
            'failure',
            isA<TeamNameExists>(),
          ),
        ),
      );

      await expectLater(
        teamSetupRepo.createTeam(
          actor: const ActorContext(
            userId: 'admin-1',
            role: AuthRole.projectManager,
          ),
          nameAr: 'فريق الإدارة',
          workerIds: const {},
        ),
        throwsA(
          isA<OperationException>().having(
            (e) => e.failure,
            'failure',
            isA<PermissionDenied>(),
          ),
        ),
      );
    },
  );

  test(
    'updateTeamMembers_addsAndRemovesWorkersAtomicallyAndIncrementsRowVersion',
    () async {
      final created = await teamSetupRepo.createTeam(
        actor: siteActor,
        nameAr: 'فريق الصيانة',
        workerIds: const {'w-1'},
      );
      final scope = ScopeSnapshot(teamIds: {created.id});

      await teamSetupRepo.updateTeamMembers(
        actor: siteActor,
        scope: scope,
        teamId: created.id,
        workerIds: const {'w-2'},
      );

      final w1 = await (database.select(
        database.employees,
      )..where((e) => e.employeeUid.equals('w-1'))).getSingle();
      final w2 = await (database.select(
        database.employees,
      )..where((e) => e.employeeUid.equals('w-2'))).getSingle();

      expect(w1.currentTeamId, isNull);
      expect(w1.rowVersion, 3); // 1 -> 2 on create -> 3 on remove
      expect(w2.currentTeamId, created.id);
      expect(w2.rowVersion, 2); // 1 -> 2 on add
    },
  );
}
