import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/account_provisioning_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/roster/data/workforce_import_repository.dart';
import 'package:radar_labor/features/roster/domain/supervisor_role_resolver.dart';
import 'package:radar_labor/features/roster/domain/workforce_row.dart';

void main() {
  late AppDatabase db;
  late LocalAuthRepository auth;
  late AccountProvisioningRepository provisioning;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    auth = LocalAuthRepository(db);
    provisioning = AccountProvisioningRepository(db, auth);
  });

  tearDown(() => db.close());

  test('ensureAdminAccounts creates PM and Admin on empty database and updates legacy HR name', () async {
    expect(await auth.accounts(), isEmpty);
    await provisioning.ensureAdminAccounts();

    final accounts = await auth.accounts();
    expect(accounts.length, 2);
    expect(
      accounts.any(
        (a) => a.role == AuthRole.projectManager && a.mustChangePassword,
      ),
      isTrue,
    );
    expect(
      accounts.any((a) => a.role == AuthRole.hr && a.mustChangePassword && a.displayName == 'Admin'),
      isTrue,
    );

    // Idempotent: does not duplicate
    await provisioning.ensureAdminAccounts();
    expect((await auth.accounts()).length, 2);

    // Updates existing account if displayName was 'HR'
    final hrAcc = accounts.firstWhere((a) => a.role == AuthRole.hr);
    await (db.update(db.appUsers)..where((u) => u.id.equals(hrAcc.id)))
        .write(const AppUsersCompanion(displayName: Value('HR')));
    expect((await auth.accounts()).firstWhere((a) => a.id == hrAcc.id).displayName, 'HR');

    await provisioning.ensureAdminAccounts();
    expect((await auth.accounts()).firstWhere((a) => a.id == hrAcc.id).displayName, 'Admin');
  });

  test('SupervisorRoleResolver detects site and campus supervisors', () {
    const resolver = SupervisorRoleResolver();

    expect(
      resolver.resolve(
        const WorkforceRow(
          code: '1',
          name: 'علي',
          designation: 'Worker',
          supplier: '',
          role: 'Site Supervisor',
        ),
      ),
      AuthRole.siteSupervisor,
    );

    expect(
      resolver.resolve(
        const WorkforceRow(
          code: '2',
          name: 'سالم',
          designation: 'Campus Supervisor',
          supplier: '',
        ),
      ),
      AuthRole.housingSupervisor,
    );

    expect(
      resolver.resolve(
        const WorkforceRow(
          code: '20',
          name: 'بدر',
          designation: 'CAMPOS',
          supplier: '',
        ),
      ),
      AuthRole.housingSupervisor,
    );

    expect(
      resolver.resolve(
        const WorkforceRow(
          code: '21',
          name: 'سعيد',
          designation: 'مشرف كامبوس',
          supplier: '',
        ),
      ),
      AuthRole.housingSupervisor,
    );

    expect(
      resolver.resolve(
        const WorkforceRow(
          code: '3',
          name: 'محمد',
          designation: 'Labourer',
          supplier: '',
        ),
      ),
      isNull,
    );
  });

  test('WorkforceImportRepository adds workers only without auto-creating supervisor accounts', () async {
    final importer = WorkforceImportRepository(db);

    final res = await importer.commit([
      const WorkforceRow(
        code: '1000000001',
        name: 'أحمد مشرف موقع',
        designation: 'Site Supervisor',
        supplier: 'Supp1',
        team: 'فريق أ',
      ),
      const WorkforceRow(
        code: '1000000002',
        name: 'خالد مشرف سكن',
        designation: 'Housing Supervisor',
        supplier: 'Supp1',
        campus: 'سكن النرجس',
      ),
      const WorkforceRow(
        code: '1000000003',
        name: 'عامر عامل',
        designation: 'Mason',
        supplier: 'Supp1',
      ),
    ]);

    expect(res.added, 3);
    expect(res.accountsCreated, 0);

    // No accounts created automatically from import
    final accounts = await auth.accounts();
    expect(accounts, isEmpty);

    // Activating supervisors is done explicitly via AccountProvisioningRepository
    final employees = await (db.select(db.employees)).get();
    final siteEmp = employees.where((e) => e.iqamaNo == '1000000001').toList();
    final housingEmp = employees.where((e) => e.iqamaNo == '1000000002').toList();

    final siteCount = await provisioning.batchActivateSupervisors(
      selectedEmployees: siteEmp,
      role: AuthRole.siteSupervisor,
    );
    final housingCount = await provisioning.batchActivateSupervisors(
      selectedEmployees: housingEmp,
      role: AuthRole.housingSupervisor,
    );

    expect(siteCount, 1);
    expect(housingCount, 1);

    final updatedAccounts = await auth.accounts();
    final siteSup = updatedAccounts.firstWhere((a) => a.role == AuthRole.siteSupervisor);
    final housingSup = updatedAccounts.firstWhere((a) => a.role == AuthRole.housingSupervisor);

    expect(siteSup.displayName, 'أحمد مشرف موقع');
    expect(siteSup.mustChangePassword, isTrue);

    expect(housingSup.displayName, 'خالد مشرف سكن');
    expect(housingSup.housingIds, contains('main_campus'));
    expect(housingSup.mustChangePassword, isTrue);
  });

  test('Atomic dual-write: transferring team clears previous supervisor and updates scopes', () async {
    final sup1Id = await auth.createAccount(
      employeeUid: '1001',
      displayName: 'Supervisor 1',
      role: AuthRole.siteSupervisor,
    );
    final sup2Id = await auth.createAccount(
      employeeUid: '1002',
      displayName: 'Supervisor 2',
      role: AuthRole.siteSupervisor,
    );

    const teamId = 'team-alpha';
    await db.into(db.teams).insert(
      TeamsCompanion.insert(
        teamId: teamId,
        nameAr: 'فريق ألفا',
        nameEn: const Value('Team Alpha'),
        supervisorUserId: Value(sup1Id),
      ),
    );
    await auth.updateScopes(sup1Id, teamIds: [teamId], housingIds: const []);

    var team = await (db.select(db.teams)..where((t) => t.teamId.equals(teamId))).getSingle();
    expect(team.supervisorUserId, sup1Id);
    var sup1Acc = (await auth.accounts()).firstWhere((a) => a.id == sup1Id);
    expect(sup1Acc.teamIds, contains(teamId));

    // Transfer team to sup2
    await auth.updateScopes(sup2Id, teamIds: [teamId], housingIds: const []);

    team = await (db.select(db.teams)..where((t) => t.teamId.equals(teamId))).getSingle();
    expect(team.supervisorUserId, sup2Id);

    sup1Acc = (await auth.accounts()).firstWhere((a) => a.id == sup1Id);
    expect(sup1Acc.teamIds, isNot(contains(teamId)));

    final sup2Acc = (await auth.accounts()).firstWhere((a) => a.id == sup2Id);
    expect(sup2Acc.teamIds, contains(teamId));

    // Deactivating sup2 clears supervisorUserId from team
    await auth.deactivateAccount(sup2Id);
    team = await (db.select(db.teams)..where((t) => t.teamId.equals(teamId))).getSingle();
    expect(team.supervisorUserId, isNull);
  });

  test('Viewer role is frictionless: no employeeUid required and mustChangePassword is false', () async {
    final viewerId = await auth.createAccount(
      employeeUid: null,
      displayName: 'VIP Auditor',
      role: AuthRole.viewer,
    );
    final accounts = await auth.accounts();
    final viewer = accounts.firstWhere((a) => a.id == viewerId);
    expect(viewer.employeeUid, isNull);
    expect(viewer.displayName, 'VIP Auditor');
    expect(viewer.role, AuthRole.viewer);
    expect(viewer.mustChangePassword, isFalse);
  });
}
