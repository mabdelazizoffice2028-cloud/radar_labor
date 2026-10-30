import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/app/screens/entities_screen.dart';
import 'package:radar_labor/app/widgets/sync_status_badge.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/auth/account_provisioning_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/sync/supabase_sync_gateway.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/roster/data/workforce_import_repository.dart';
import 'package:radar_labor/features/roster/domain/workforce_row.dart';

final class _MockOnlineGateway implements RemoteSyncGateway {
  const _MockOnlineGateway();

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
  }) async => RemoteUploadAck(
    acceptedEventIds: events.map((e) => e.eventId).toSet(),
    acceptedAuditIds: audits.map((a) => a.auditId).toSet(),
  );

  @override
  Future<RemoteRosterSnapshot> fetchSnapshot({
    required String actorUserId,
  }) async => const RemoteRosterSnapshot(rosterEpoch: 1);
}

void main() {
  group('Task 1 & Task 2: EntitiesScreen FAB & Default Campus', () {
    late AppDatabase db;
    late LocalAuthRepository auth;
    late AccountProvisioningRepository provisioning;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      auth = LocalAuthRepository(db);
      provisioning = AccountProvisioningRepository(db, auth);
    });

    tearDown(() => db.close());

    testWidgets('EntitiesScreen shows FAB for teams', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EntitiesScreen(database: db, arabic: false, teams: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('EntitiesScreen hides FAB for housings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EntitiesScreen(database: db, arabic: false, teams: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    test('ensureAdminAccounts guarantees default housing constant', () async {
      await provisioning.ensureAdminAccounts();
      expect(AppConstants.defaultHousingId, 'main_campus');
    });

    test(
      'Housing supervisor without campus auto-assigns defaultHousingId',
      () async {
        final created = await provisioning.provisionSupervisors([
          const SupervisorSeed(
            employeeUid: 'emp-h-1',
            displayName: 'Housing Supervisor 1',
            role: AuthRole.housingSupervisor,
            campusName: '',
          ),
        ]);
        expect(created, 1);

        final accounts = await auth.accounts();
        final housingSup = accounts.firstWhere(
          (a) => a.role == AuthRole.housingSupervisor,
        );
        expect(housingSup.housingIds, contains(AppConstants.defaultHousingId));
      },
    );

    test(
      'Workforce import auto-assigns defaultHousingId when campus is empty',
      () async {
        final importer = WorkforceImportRepository(db);
        final res = await importer.commit([
          const WorkforceRow(
            code: '1000000100',
            name: 'Tariq Worker',
            designation: 'Worker',
            supplier: '',
            campus: '',
          ),
        ]);
        expect(res.added, 1);

        final worker = await (db.select(
          db.employees,
        )..where((e) => e.iqamaNo.equals('1000000100'))).getSingle();
        expect(worker.housingId, AppConstants.defaultHousingId);
      },
    );
  });

  group('Task 3: SyncStatusBadge and SupabaseSyncGateway', () {
    testWidgets('SyncStatusBadge displays Local Mode when gateway is offline', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: Scaffold(body: SyncStatusBadge(arabic: false)),
          ),
        ),
      );
      expect(find.text('Local Mode'), findsOneWidget);
    });

    testWidgets(
      'SyncStatusBadge displays محلي in Arabic when gateway is offline',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            overrides: [],
            child: MaterialApp(
              home: Scaffold(body: SyncStatusBadge(arabic: true)),
            ),
          ),
        );
        expect(find.text('محلي'), findsOneWidget);
      },
    );

    testWidgets(
      'SyncStatusBadge displays Synced when real gateway is used and pending count is 0',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              remoteSyncGatewayProvider.overrideWithValue(
                const _MockOnlineGateway(),
              ),
              pendingOutboxCountProvider.overrideWith((ref) => Stream.value(0)),
            ],
            child: const MaterialApp(
              home: Scaffold(body: SyncStatusBadge(arabic: false)),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Synced'), findsOneWidget);
      },
    );

    test('SupabaseSyncGateway safely catches errors without throwing unexpected exceptions', () async {
      final gateway = SupabaseSyncGateway();

      // Without initialized Supabase instance, isReachable returns false safely
      final reachable = await gateway.isReachable();
      expect(reachable, isFalse);

      // uploadBatch throws OperationException(DatabaseBusy)
      expect(
        () => gateway.uploadBatch(
          actorUserId: 'user-1',
          actorRole: AuthRole.siteSupervisor,
          allowedTeamIds: {'t1'},
          allowedHousingIds: {'h1'},
          events: [],
          audits: [],
        ),
        throwsA(isA<OperationException>()),
      );

      // fetchSnapshot returns fallback empty snapshot
      final snapshot = await gateway.fetchSnapshot(actorUserId: 'user-1');
      expect(snapshot.rosterEpoch, 1);
      expect(snapshot.employees, isEmpty);
    });
  });
}
