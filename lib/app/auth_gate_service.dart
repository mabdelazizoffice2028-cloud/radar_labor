import 'package:radar_labor/core/auth/account_provisioning_repository.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';

final class AuthGateService {
  AuthGateService(this.database)
    : auth = LocalAuthRepository(database),
      provisioning = AccountProvisioningRepository(
        database,
        LocalAuthRepository(database),
      );

  final AppDatabase database;
  final LocalAuthRepository auth;
  final AccountProvisioningRepository provisioning;

  Future<(List<LocalAccount>, String?)> loadAccounts() async {
    final settings = LocalSettingsRepository(database);
    final rememberedId = await settings.read(
      AppSettingKeys.lastLoggedInAccountId,
    );
    await provisioning.ensureAdminAccounts();
    final accounts = await auth.accounts(activeOnly: true);
    return (accounts, rememberedId);
  }

  Future<void> rememberAccount(String accountId) async {
    final settings = LocalSettingsRepository(database);
    await settings.write(AppSettingKeys.lastLoggedInAccountId, accountId);
  }

  Future<void> forgetRememberedAccount() async {
    final settings = LocalSettingsRepository(database);
    await settings.delete(AppSettingKeys.lastLoggedInAccountId);
  }

  Future<LocalAccount> refreshAccount(String accountId) async {
    final list = await auth.accounts();
    return list.firstWhere((a) => a.id == accountId);
  }
}
