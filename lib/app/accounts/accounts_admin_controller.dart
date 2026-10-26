import 'package:radar_labor/core/auth/account_provisioning_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/roster/data/workforce_file_picker.dart';
import 'package:radar_labor/features/roster/data/workforce_import_repository.dart';
import 'package:radar_labor/features/roster/domain/supervisor_role_resolver.dart';
import 'package:radar_labor/features/roster/domain/workforce_import_parser.dart';
import 'package:radar_labor/features/roster/domain/workforce_row.dart';

/// Reference data shown on the names & roles administration screen.
final class AccountsAdminData {
  const AccountsAdminData({
    required this.accounts,
    required this.employees,
    required this.teams,
    required this.housings,
  });

  final List<LocalAccount> accounts;
  final List<Employee> employees;
  final List<Team> teams;
  final List<Housing> housings;

  /// Whether any supervisor can already pick their name on the login screen.
  bool get hasSupervisors => accounts.any(
    (a) =>
        a.role == AuthRole.siteSupervisor ||
        a.role == AuthRole.housingSupervisor,
  );
}

/// Parsed roster awaiting the administrator's confirmation.
final class ImportPreview {
  const ImportPreview({required this.rows, required this.supervisorCount});
  final List<WorkforceRow> rows;
  final int supervisorCount;
}

/// Values entered in the add/edit account dialog.
final class AccountFormResult {
  const AccountFormResult({
    required this.displayName,
    required this.role,
    this.employeeUid,
    this.teamIds = const [],
    this.housingIds = const [],
  });

  final String? employeeUid;
  final String displayName;
  final AuthRole role;
  final List<String> teamIds;
  final List<String> housingIds;
}

/// Thrown when removing the only active project manager account.
final class LastManagerException implements Exception {
  const LastManagerException();
}

/// Orchestrates names/roles administration so the screen stays presentational.
final class AccountsAdminController {
  AccountsAdminController(this._database)
    : _auth = LocalAuthRepository(_database),
      _importer = WorkforceImportRepository(_database);

  final AppDatabase _database;
  final LocalAuthRepository _auth;
  final WorkforceImportRepository _importer;

  Future<AccountsAdminData> load() async {
    final db = _database;
    final accounts = await _auth.accounts(activeOnly: true);
    final employees = await (db.select(
      db.employees,
    )..where((r) => r.isActive)).get();
    final teams = await (db.select(db.teams)..where((r) => r.isActive)).get();
    final housings = await (db.select(
      db.housings,
    )..where((r) => r.isActive)).get();
    return AccountsAdminData(
      accounts: accounts,
      employees: employees,
      teams: teams,
      housings: housings,
    );
  }

  /// Opens the local file picker and parses the roster; null when cancelled.
  Future<ImportPreview?> pickImport() async {
    final file = await WorkforceFilePicker().pick();
    if (file == null) return null;
    final rows = const WorkforceImportParser().parse(
      filename: file.name,
      bytes: file.bytes,
    );
    const resolver = SupervisorRoleResolver();
    final supervisors = rows.where((r) => resolver.resolve(r) != null).length;
    return ImportPreview(rows: rows, supervisorCount: supervisors);
  }

  Future<WorkforceImportResult> commitImport(ImportPreview preview) =>
      _importer.commit(preview.rows);

  Future<void> create(AccountFormResult form) => _auth.createAccount(
    employeeUid: form.employeeUid,
    displayName: form.displayName,
    role: form.role,
    teamIds: form.teamIds,
    housingIds: form.housingIds,
  );

  Future<void> update(LocalAccount account, AccountFormResult form) async {
    if (form.role != AuthRole.projectManager) await _guardLastManager(account);
    await AccountProvisioningRepository(_database, _auth).updateAccount(
      accountId: account.id,
      displayName: form.displayName,
      role: form.role,
      teamIds: form.teamIds,
      housingIds: form.housingIds,
    );
  }

  Future<void> resetPassword(String accountId) =>
      _auth.resetPassword(accountId);

  /// Removes the account from the sign-in list (soft delete keeps history).
  Future<void> remove(LocalAccount account) async {
    await _guardLastManager(account);
    await _auth.deactivateAccount(account.id);
  }

  Future<void> _guardLastManager(LocalAccount account) async {
    if (account.role != AuthRole.projectManager) return;
    final managers = (await _auth.accounts(activeOnly: true))
        .where((a) => a.role == AuthRole.projectManager);
    if (managers.length <= 1) throw const LastManagerException();
  }
}
