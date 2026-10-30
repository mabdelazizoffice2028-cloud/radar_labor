import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/supervisor_seed.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

final class SupervisorAccountProvisioner {
  SupervisorAccountProvisioner(this._database, this._auth);
  final AppDatabase _database;
  final LocalAuthRepository _auth;
  static const _uuid = Uuid();

  Future<int> provision(List<SupervisorSeed> seeds) =>
      _database.transaction(() async {
        var created = 0;
        final all = await _auth.accounts();
        for (final seed in seeds) {
          final existing = all.where((a) => a.employeeUid == seed.employeeUid).toList();
          final reusable = existing.where((a) => a.active && a.role == seed.role).firstOrNull;
          if (existing.isNotEmpty && reusable == null) continue;
          final (teamIds, housingIds) = await _scopeFor(seed);
          final accountId = reusable?.id ?? await _auth.createAccount(
            employeeUid: seed.employeeUid,
            displayName: seed.displayName,
            role: seed.role,
            teamIds: teamIds,
            housingIds: housingIds,
          );
          if (reusable == null) {
            created++;
          } else {
            await _mergeScopes(reusable, teamIds, housingIds);
          }
          for (final teamId in teamIds) {
            await _claimTeam(teamId, accountId);
          }
        }
        return created;
      });

  Future<(List<String>, List<String>)> _scopeFor(SupervisorSeed seed) async {
    final team = seed.teamName.trim();
    if (seed.role == AuthRole.siteSupervisor && team.isNotEmpty) {
      return ([await _findOrCreateTeam(team)], const <String>[]);
    }
    if (seed.role == AuthRole.housingSupervisor) {
      return (const <String>[], [HousingConstants.defaultHousingId]);
    }
    return (const <String>[], const <String>[]);
  }

  Future<void> _mergeScopes(LocalAccount acc, List<String> tIds, List<String> hIds) async {
    final teams = {...acc.teamIds, ...tIds};
    final housings = {...acc.housingIds, ...hIds};
    if (teams.length == acc.teamIds.length && housings.length == acc.housingIds.length) return;
    await _auth.updateScopes(acc.id, teamIds: teams.toList(), housingIds: housings.toList());
  }

  Future<String> _findOrCreateTeam(String name) async {
    final rows = await (_database.select(_database.teams)..where((t) => t.isActive)).get();
    for (final t in rows) {
      if (t.nameAr.trim().toLowerCase() == name.toLowerCase() || (t.nameEn?.trim().toLowerCase() ?? '') == name.toLowerCase()) {
        return t.teamId;
      }
    }
    final id = _uuid.v4();
    await _database.into(_database.teams).insert(TeamsCompanion.insert(teamId: id, nameAr: name, nameEn: Value(name)));
    return id;
  }

  Future<void> _claimTeam(String teamId, String accountId) =>
      (_database.update(_database.teams)..where((t) => t.teamId.equals(teamId) & t.supervisorUserId.isNull()))
          .write(TeamsCompanion(supervisorUserId: Value(accountId)));
}
