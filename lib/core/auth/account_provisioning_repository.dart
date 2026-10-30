import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/supervisor_account_provisioner.dart';
import 'package:radar_labor/core/auth/supervisor_seed.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';

export 'package:radar_labor/core/auth/supervisor_seed.dart';

final class AccountProvisioningRepository {
  AccountProvisioningRepository(this._database, [LocalAuthRepository? auth])
    : _auth = auth ?? LocalAuthRepository(_database),
      _provisioner = SupervisorAccountProvisioner(
        _database,
        auth ?? LocalAuthRepository(_database),
      );

  final AppDatabase _database;
  final LocalAuthRepository _auth;
  final SupervisorAccountProvisioner _provisioner;

  Future<void> ensureAdminAccounts() async {
    await _auth.ensureAccountForRole(
      AuthRole.projectManager,
      AuthConstants.defaultProjectManagerName,
    );
    await _auth.ensureAccountForRole(AuthRole.hr, AuthConstants.defaultHrName);
    await (_database.update(_database.appUsers)
          ..where((u) => u.role.equals(AuthRole.hr.name) & u.displayName.equals('HR')))
        .write(const AppUsersCompanion(displayName: Value(AuthConstants.defaultHrName)));
  }

  Future<int> provisionSupervisors(List<SupervisorSeed> seeds) =>
      _provisioner.provision(seeds);

  Future<void> updateAccount({
    required String accountId,
    required String displayName,
    required AuthRole role,
    List<String> teamIds = const [],
    List<String> housingIds = const [],
  }) {
    final name = displayName.trim();
    if (name.isEmpty) throw ArgumentError('Display name is required');
    final effectiveHousingIds = role == AuthRole.housingSupervisor
        ? (housingIds.isEmpty ? [HousingConstants.defaultHousingId] : housingIds)
        : const <String>[];
    return _database.transaction(() async {
      await (_database.update(_database.appUsers)
            ..where((u) => u.id.equals(accountId)))
          .write(
            AppUsersCompanion(displayName: Value(name), role: Value(role.name)),
          );
      await _auth.updateScopes(
        accountId,
        teamIds: role == AuthRole.siteSupervisor ? teamIds : const [],
        housingIds: effectiveHousingIds,
      );
    });
  }
}
