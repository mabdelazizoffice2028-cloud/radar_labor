import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

/// A supervisor detected in an imported roster row.
final class SupervisorSeed {
  const SupervisorSeed({
    required this.employeeUid,
    required this.displayName,
    required this.role,
    this.teamName = '',
    this.campusName = '',
  });

  final String employeeUid;
  final String displayName;
  final AuthRole role;
  final String teamName;
  final String campusName;
}

/// Creates login accounts automatically so nobody has to pre-create them:
/// built-in admin accounts on first launch, and one account per imported
/// supervisor linked to its team or campus scope in `user_scopes`.
final class AccountProvisioningRepository {
  AccountProvisioningRepository(this._database, [LocalAuthRepository? auth])
    : _auth = auth ?? LocalAuthRepository(_database);

  final AppDatabase _database;
  final LocalAuthRepository _auth;
  static const _uuid = Uuid();

  /// Guarantees a project manager and an HR account exist (temporary password,
  /// must change on first sign-in). Existing accounts are never touched.
  Future<void> ensureAdminAccounts() async {
    await _auth.ensureAccountForRole(
      AuthRole.projectManager,
      AuthConstants.defaultProjectManagerName,
    );
    await _auth.ensureAccountForRole(AuthRole.hr, AuthConstants.defaultHrName);
  }

  /// Creates missing supervisor accounts and links their scopes atomically.
  /// An employee who already has an account keeps the role chosen by the
  /// administrator; only missing scopes are added when the role still matches.
  /// Returns the number of accounts created.
  Future<int> provisionSupervisors(List<SupervisorSeed> seeds) =>
      _database.transaction(() async {
        var created = 0;
        final all = await _auth.accounts();
        for (final seed in seeds) {
          final existing = [
            for (final a in all)
              if (a.employeeUid == seed.employeeUid) a,
          ];
          final reusable = existing
              .where((a) => a.active && a.role == seed.role)
              .firstOrNull;
          if (existing.isNotEmpty && reusable == null) continue;
          final (teamIds, housingIds) = await _scopeFor(seed);
          final accountId =
              reusable?.id ??
              await _auth.createAccount(
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

  /// Updates an account's name, role and scopes in one transaction.
  Future<void> updateAccount({
    required String accountId,
    required String displayName,
    required AuthRole role,
    List<String> teamIds = const [],
    List<String> housingIds = const [],
  }) {
    final name = displayName.trim();
    if (name.isEmpty) throw ArgumentError('Display name is required');
    return _database.transaction(() async {
      await (_database.update(_database.appUsers)
            ..where((u) => u.id.equals(accountId)))
          .write(
            AppUsersCompanion(displayName: Value(name), role: Value(role.name)),
          );
      await _auth.updateScopes(
        accountId,
        teamIds: role == AuthRole.siteSupervisor ? teamIds : const [],
        housingIds: role == AuthRole.housingSupervisor ? housingIds : const [],
      );
    });
  }

  Future<(List<String>, List<String>)> _scopeFor(SupervisorSeed seed) async {
    final team = seed.teamName.trim();
    final campus = seed.campusName.trim();
    if (seed.role == AuthRole.siteSupervisor && team.isNotEmpty) {
      return ([await _findOrCreateTeam(team)], const <String>[]);
    }
    if (seed.role == AuthRole.housingSupervisor && campus.isNotEmpty) {
      return (const <String>[], [await _findOrCreateHousing(campus)]);
    }
    return (const <String>[], const <String>[]);
  }

  Future<void> _mergeScopes(
    LocalAccount account,
    List<String> teamIds,
    List<String> housingIds,
  ) async {
    final teams = {...account.teamIds, ...teamIds};
    final housings = {...account.housingIds, ...housingIds};
    if (teams.length == account.teamIds.length &&
        housings.length == account.housingIds.length) {
      return;
    }
    await _auth.updateScopes(
      account.id,
      teamIds: teams.toList(),
      housingIds: housings.toList(),
    );
  }

  bool _sameName(String needle, String nameAr, String? nameEn) {
    final n = needle.toLowerCase();
    return nameAr.trim().toLowerCase() == n ||
        (nameEn?.trim().toLowerCase() ?? '') == n;
  }

  Future<String> _findOrCreateTeam(String name) async {
    final rows = await (_database.select(
      _database.teams,
    )..where((t) => t.isActive)).get();
    for (final t in rows) {
      if (_sameName(name, t.nameAr, t.nameEn)) return t.teamId;
    }
    final id = _uuid.v4();
    await _database
        .into(_database.teams)
        .insert(
          TeamsCompanion.insert(teamId: id, nameAr: name, nameEn: Value(name)),
        );
    return id;
  }

  Future<String> _findOrCreateHousing(String name) async {
    final rows = await (_database.select(
      _database.housings,
    )..where((h) => h.isActive)).get();
    for (final h in rows) {
      if (_sameName(name, h.nameAr, h.nameEn)) return h.housingId;
    }
    final id = _uuid.v4();
    await _database
        .into(_database.housings)
        .insert(
          HousingsCompanion.insert(
            housingId: id,
            nameAr: name,
            nameEn: Value(name),
          ),
        );
    return id;
  }

  Future<void> _claimTeam(String teamId, String accountId) =>
      (_database.update(_database.teams)..where(
            (t) => t.teamId.equals(teamId) & t.supervisorUserId.isNull(),
          ))
          .write(TeamsCompanion(supervisorUserId: Value(accountId)));
}
