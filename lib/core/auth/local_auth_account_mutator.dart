import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/auth_exceptions.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_account_reader.dart';
import 'package:radar_labor/core/auth/local_auth_password_service.dart';
import 'package:radar_labor/core/auth/team_scope_sync.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:uuid/uuid.dart';

final class LocalAuthAccountMutator {
  const LocalAuthAccountMutator(this._database, this._clock, this._passwords, this._reader);
  final AppDatabase _database;
  final Clock _clock;
  final LocalAuthPasswordService _passwords;
  final LocalAuthAccountReader _reader;

  Future<void> createInitialAccounts({
    required String projectManagerEmployeeUid, required String hrEmployeeUid,
    required String projectManagerName, required String hrName,
  }) async {
    if ((await _reader.accounts()).isNotEmpty) throw const AuthConflictException();
    await _database.transaction(() async {
      await insertUser(projectManagerEmployeeUid, projectManagerName, AuthRole.projectManager);
      await insertUser(hrEmployeeUid, hrName, AuthRole.hr);
    });
  }

  Future<String> createAccount({
    String? employeeUid, required String displayName, required AuthRole role,
    List<String> teamIds = const [], List<String> housingIds = const [],
  }) async {
    if (role != AuthRole.viewer && (employeeUid == null || employeeUid.trim().isEmpty)) {
      throw ArgumentError('Non-viewer roles require an employeeUid');
    }
    final existing = await _reader.accounts(activeOnly: true);
    final needle = displayName.trim().toLowerCase();
    final conflict = employeeUid != null
        ? existing.any((a) => a.employeeUid == employeeUid && a.role == role)
        : existing.any((a) => a.role == role && a.displayName.toLowerCase() == needle);
    if (conflict) throw const AuthConflictException();
    return insertUser(employeeUid, displayName.trim(), role, teamIds, housingIds);
  }

  Future<void> deactivateAccount(String id) => _database.transaction(() async {
    await (_database.update(_database.appUsers)..where((u) => u.id.equals(id))).write(const AppUsersCompanion(active: Value(false)));
    await TeamScopeSync(_database).clearSupervisor(id);
  });

  Future<bool> ensureAccountForRole(AuthRole role, String displayName) =>
      _database.transaction(() async {
        final query = _database.select(_database.appUsers)..where((u) => u.role.equals(role.name))..limit(1);
        if (await query.getSingleOrNull() != null) return false;
        await insertUser(null, displayName, role);
        return true;
      });

  Future<void> updateScopes(String id, {required List<String> teamIds, required List<String> housingIds}) =>
      _database.transaction(() => TeamScopeSync(_database).syncScopes(
        userId: id, teamIds: teamIds, housingIds: housingIds,
      ));

  Future<String> insertUser(
    String? empUid, String name, AuthRole role, [List<String> tIds = const [], List<String> hIds = const []]
  ) async {
    final id = const Uuid().v4();
    final (salt, hash) = await _passwords.hashPassword(AuthConstants.temporaryPassword);
    await _database.transaction(() async {
      await _database.into(_database.appUsers).insert(AppUsersCompanion.insert(
        id: id, employeeUid: Value(empUid), displayName: name, role: role.name,
        pwHash: hash, pwSalt: salt, kdfParams: AuthConstants.kdfParamsJson,
        mustChange: Value(role != AuthRole.viewer), createdAt: _clock.nowUtc(),
      ));
      await TeamScopeSync(_database).syncScopes(userId: id, teamIds: tIds, housingIds: hIds);
    });
    return id;
  }
}
