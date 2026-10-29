import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/operations_store.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/operations_screen.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_screen.dart';

final class _FixedClock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 26, 10, 0);
}

/// Store whose team stream is driven by the test.
final class _TeamsOnlyStore implements OperationsStore {
  final teams = StreamController<List<EntityOption>>.broadcast();

  @override
  Stream<List<EntityOption>> watchTeams() => teams.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

final class _FakeTeamSetupStore implements TeamSetupStore {
  @override
  Stream<List<SelectableWorker>> watchActiveWorkersWithTeams() =>
      Stream.value(const <SelectableWorker>[]);

  @override
  Future<EntityOption> createTeam({
    required ActorContext actor,
    required String nameAr,
    String? nameEn,
    required Set<String> workerIds,
  }) async => EntityOption(id: 't-1', nameAr: nameAr, nameEn: nameEn);

  @override
  Future<void> updateTeamMembers({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
    required Set<String> workerIds,
  }) async {}
}

void main() {
  late AppDatabase db;
  late _TeamsOnlyStore store;
  final clock = _FixedClock();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = _TeamsOnlyStore();
  });

  tearDown(() async {
    await store.teams.close();
    await db.close();
  });

  Future<void> pump(WidgetTester tester, AuthRole role) async {
    final events = EventRepository(
      database: db,
      deviceId: 'dev-1',
      clock: clock,
    );
    final repo = OperationsRepository(database: db, events: events);
    final controller = OperationsController(
      store: store,
      clock: clock,
      actorUserId: 'user-1',
      capabilities: role.capabilities,
      allowedTeamIds: const ['t-1'],
      allowedHousingIds: const ['h-1'],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          eventRepositoryProvider.overrideWithValue(events),
          operationsRepositoryProvider.overrideWithValue(repo),
          clockProvider.overrideWithValue(clock),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: OperationsScreen(
              controller: controller,
              arabic: false,
              role: role,
              teamSetupStore: _FakeTeamSetupStore(),
              actor: ActorContext(userId: 'user-1', role: role),
              scope: const ScopeSnapshot(teamIds: {'t-1'}, housingIds: {}),
            ),
          ),
        ),
      ),
    );
  }

  const createButton = ValueKey('create_first_team_button');
  const launcherCard = ValueKey('launch_site_attendance_card');

  testWidgets('site supervisor sees loading, never the empty state, first', (
    tester,
  ) async {
    await pump(tester, AuthRole.siteSupervisor);
    await tester.pump();

    expect(find.byKey(const ValueKey('teams_loading')), findsOneWidget);
    expect(find.byKey(createButton), findsNothing);
    expect(
      find.text(OperationsStrings.noTeamsYetSupervisor(false)),
      findsNothing,
    );
  });

  testWidgets('stream error shows a distinct localized message', (
    tester,
  ) async {
    await pump(tester, AuthRole.siteSupervisor);
    store.teams.addError(StateError('boom'));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('teams_stream_error')), findsOneWidget);
    expect(find.text(OperationsStrings.teamsLoadFailed(false)), findsOneWidget);
    expect(find.text('Bad state: boom'), findsNothing);
    expect(find.byKey(createButton), findsNothing);
  });

  testWidgets('no teams: guidance + create button opens the team wizard', (
    tester,
  ) async {
    await pump(tester, AuthRole.siteSupervisor);
    store.teams.add(const <EntityOption>[]);
    await tester.pump();
    await tester.pump();

    expect(
      find.text(OperationsStrings.noTeamsYetSupervisor(false)),
      findsOneWidget,
    );
    expect(find.byKey(createButton), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, OperationsStrings.createNewTeam(false)),
      findsOneWidget,
    );
    expect(find.byKey(launcherCard), findsNothing);

    await tester.tap(find.byKey(createButton));
    await tester.pumpAndSettle();
    expect(find.byType(TeamWizardScreen), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(TeamWizardScreen), findsNothing);
    expect(find.byKey(createButton), findsOneWidget);
  });

  testWidgets('a team appearing in the stream restores the launcher', (
    tester,
  ) async {
    await pump(tester, AuthRole.siteSupervisor);
    store.teams.add(const <EntityOption>[]);
    await tester.pump();
    await tester.pump();
    expect(find.byKey(createButton), findsOneWidget);

    store.teams.add(const [
      EntityOption(id: 't-1', nameAr: 'فريق', nameEn: 'Crew'),
    ]);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(createButton), findsNothing);
    expect(find.byKey(launcherCard), findsOneWidget);
  });

  testWidgets('housing supervisor never sees the team empty state', (
    tester,
  ) async {
    await pump(tester, AuthRole.housingSupervisor);
    await tester.pump();

    expect(find.byKey(const ValueKey('teams_loading')), findsNothing);
    expect(find.byKey(createButton), findsNothing);
    expect(
      find.byKey(const ValueKey('launch_campus_check_card')),
      findsOneWidget,
    );
  });
}
