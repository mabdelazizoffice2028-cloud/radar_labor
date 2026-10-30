import 'package:radar_labor/app/accounts/accounts_admin_import_picker.dart';
import 'package:radar_labor/app/accounts/accounts_admin_loader.dart';
import 'package:radar_labor/app/accounts/accounts_admin_models.dart';
import 'package:radar_labor/core/auth/account_provisioning_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/roster/data/workforce_import_repository.dart';

export 'package:radar_labor/app/accounts/accounts_admin_models.dart';

final class AccountsAdminController {
  AccountsAdminController(this._database, [LocalAuthRepository? auth])
      : _auth = auth ?? LocalAuthRepository(_database),
        _importer = WorkforceImportRepository(_database);

  final AppDatabase _database;
  final LocalAuthRepository _auth;
  final WorkforceImportRepository _importer;

  Future<AccountsAdminData> load() => AccountsAdminLoader(_database, _auth).load();

  Future<ImportPreview?> pickImport() => const AccountsAdminImportPicker().pick();

  Future<WorkforceImportResult> commitImport(ImportPreview p) => _importer.commit(p.rows);

  Future<void> create(AccountFormResult form) => _auth.createAccount(
        employeeUid: form.employeeUid,
        displayName: form.displayName,
        role: form.role,
        teamIds: form.teamIds,
        housingIds: form.housingIds.isEmpty ? [HousingConstants.defaultHousingId] : form.housingIds,
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

  Future<void> resetPassword(String id) => _auth.resetPassword(id);

  Future<void> remove(LocalAccount a) async {
    await _guardLastManager(a);
    await _auth.deactivateAccount(a.id);
  }

  Future<void> _guardLastManager(LocalAccount account) async {
    if (account.role != AuthRole.projectManager) return;
    final managers = (await _auth.accounts(activeOnly: true))
        .where((a) => a.role == AuthRole.projectManager);
    if (managers.length <= 1) throw const LastManagerException();
  }
}
