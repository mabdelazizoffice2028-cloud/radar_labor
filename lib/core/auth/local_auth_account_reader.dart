import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';

final class LocalAuthAccountReader {
  const LocalAuthAccountReader(this._database);
  final AppDatabase _database;

  Stream<ScopeSnapshot> watchScopes(String accountId) =>
      (_database.select(_database.userScopes)..where((s) => s.userId.equals(accountId))).watch().map(
        (rows) => ScopeSnapshot(
          teamIds: Set.unmodifiable({for (final r in rows) if (r.scopeType == ScopeTypes.team) r.scopeId}),
          housingIds: Set.unmodifiable({for (final r in rows) if (r.scopeType == ScopeTypes.housing) r.scopeId}),
        ),
      );

  Future<List<LocalAccount>> accounts({bool activeOnly = false}) async {
    final query = _database.select(_database.appUsers);
    if (activeOnly) query.where((u) => u.active);
    final userRows = await query.get();
    if (userRows.isEmpty) return const [];

    final scopeRows = await _database.select(_database.userScopes).get();
    final teamsMap = <String, List<String>>{};
    final housingsMap = <String, List<String>>{};
    for (final s in scopeRows) {
      final target = s.scopeType == ScopeTypes.team ? teamsMap : housingsMap;
      (target[s.userId] ??= []).add(s.scopeId);
    }

    return List.unmodifiable([
      for (final u in userRows)
        LocalAccount(
          id: u.id,
          employeeUid: u.employeeUid,
          displayName: u.displayName,
          role: AuthRole.values.byName(u.role),
          salt: u.pwSalt,
          passwordHash: u.pwHash,
          mustChangePassword: u.mustChange,
          active: u.active,
          teamIds: List.unmodifiable(teamsMap[u.id] ?? const []),
          housingIds: List.unmodifiable(housingsMap[u.id] ?? const []),
        ),
    ]);
  }
}
