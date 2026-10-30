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

  test('WorkforceImportRepository automatically creates supervisor accounts and scopes', () async {
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
    expect(res.accountsCreated, 2);

    final accounts = await auth.accounts();
    final siteSup = accounts.firstWhere(
      (a) => a.role == AuthRole.siteSupervisor,
    );
    final housingSup = accounts.firstWhere(
      (a) => a.role == AuthRole.housingSupervisor,
    );

    expect(siteSup.displayName, 'أحمد مشرف موقع');
    expect(siteSup.teamIds.length, 1);
    expect(siteSup.mustChangePassword, isTrue);

    expect(housingSup.displayName, 'خالد مشرف سكن');
    expect(housingSup.housingIds.length, 1);
    expect(housingSup.mustChangePassword, isTrue);
  });
}
