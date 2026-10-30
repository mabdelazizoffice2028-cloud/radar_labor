import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/supervisor_seed.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';

/// Provisions supervisor accounts with temporary credentials and default scopes.
final class SupervisorAccountProvisioner {
  SupervisorAccountProvisioner(this._database, this._auth);
  final AppDatabase _database;
  final LocalAuthRepository _auth;

  Future<int> provision(List<SupervisorSeed> seeds) => _database.transaction(() async {
    var created = 0;
    final all = await _auth.accounts(activeOnly: true);
    for (final seed in seeds) {
      if (all.any((a) => a.employeeUid == seed.employeeUid && a.role == seed.role)) continue;
      final hIds = seed.role == AuthRole.housingSupervisor
          ? [HousingConstants.defaultHousingId]
          : const <String>[];
      await _auth.createAccount(
        employeeUid: seed.employeeUid, displayName: seed.displayName,
        role: seed.role, teamIds: const [], housingIds: hIds,
      );
      created++;
    }
    return created;
  });

  Future<int> batchActivate({
    required List<Employee> employees,
    required AuthRole role,
  }) => _database.transaction(() async {
    var created = 0;
    final all = await _auth.accounts(activeOnly: true);
    final hIds = role == AuthRole.housingSupervisor
        ? [HousingConstants.defaultHousingId]
        : const <String>[];
    for (final emp in employees) {
      if (all.any((a) => a.employeeUid == emp.iqamaNo && a.role == role)) continue;
      await _auth.createAccount(
        employeeUid: emp.iqamaNo, displayName: emp.fullNameAr,
        role: role, teamIds: const [], housingIds: hIds,
      );
      created++;
    }
    return created;
  });
}
