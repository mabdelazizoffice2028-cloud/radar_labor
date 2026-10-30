import 'package:radar_labor/app/accounts/accounts_admin_models.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/models/housing_option.dart';

final class AccountsAdminLoader {
  const AccountsAdminLoader(this._database, this._auth);

  final AppDatabase _database;
  final LocalAuthRepository _auth;

  Future<AccountsAdminData> load() async {
    final accounts = await _auth.accounts(activeOnly: true);
    final employees = await (_database.select(_database.employees)
          ..where((r) => r.archivedAt.isNull()))
        .get();
    final teams = await (_database.select(_database.teams)
          ..where((r) => r.isActive))
        .get();
    const housings = [
      HousingOption(
        housingId: HousingConstants.defaultHousingId,
        nameAr: HousingConstants.defaultHousingNameAr,
        nameEn: HousingConstants.defaultHousingName,
      ),
    ];
    return AccountsAdminData(
      accounts: accounts,
      employees: employees,
      teams: teams,
      housings: housings,
    );
  }
}
