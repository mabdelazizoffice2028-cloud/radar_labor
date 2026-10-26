import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/auth_exceptions.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/password_hasher.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:uuid/uuid.dart';

export 'auth_exceptions.dart';

/// Stores and manages authenticated local accounts in encrypted database.
final class LocalAuthRepository {
  LocalAuthRepository(
    Object dbOrSettings, [
    this._clock = const SystemClock(),
    this._hasher = const PasswordHasher(),
  ]) : _database = dbOrSettings is AppDatabase
           ? dbOrSettings
           : (dbOrSettings as LocalSettingsRepository).database;

  final AppDatabase _database;
  final Clock _clock;
  final PasswordHasher _hasher;

  /// Live stream of a user's assigned team and housing scopes (PRD §5.4).
  Stream<ScopeSnapshot> watchScopes(String accountId) =>
      (_database.select(_database.userScopes)
            ..where((s) => s.userId.equals(accountId)))
          .watch()
          .map(
            (rows) => ScopeSnapshot(
              teamIds: Set.unmodifiable({
                for (final r in rows)
                  if (r.scopeType == ScopeTypes.team) r.scopeId,
              }),
              housingIds: Set.unmodifiable({
                for (final r in rows)
                  if (r.scopeType == ScopeTypes.housing) r.scopeId,
              }),
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

  Future<void> createInitialAccounts({
    required String projectManagerEmployeeUid,
    required String hrEmployeeUid,
    required String projectManagerName,
    required String hrName,
  }) async {
    if ((await accounts()).isNotEmpty) throw const AuthConflictException();
    await _database.transaction(() async {
      await _insertUser(
        projectManagerEmployeeUid,
        projectManagerName,
        AuthRole.projectManager,
      );
      await _insertUser(hrEmployeeUid, hrName, AuthRole.hr);
    });
  }

  /// Creates an account with the temporary password and returns its id.
  /// Deactivated (deleted) accounts never block re-creating the same person.
  Future<String> createAccount({
    String? employeeUid,
    required String displayName,
    required AuthRole role,
    List<String> teamIds = const [],
    List<String> housingIds = const [],
  }) async {
    if (role != AuthRole.viewer &&
        (employeeUid == null || employeeUid.trim().isEmpty)) {
      throw ArgumentError('Non-viewer roles require an employeeUid');
    }
    final existing = await accounts(activeOnly: true);
    final needle = displayName.trim().toLowerCase();
    final conflict = employeeUid != null
        ? existing.any((a) => a.employeeUid == employeeUid && a.role == role)
        : existing.any(
            (a) => a.role == role && a.displayName.toLowerCase() == needle,
          );
    if (conflict) throw const AuthConflictException();
    return _insertUser(
      employeeUid,
      displayName.trim(),
      role,
      teamIds,
      housingIds,
    );
  }

  Future<LocalAccount?> signIn({
    AuthRole? role,
    required String accountId,
    required String password,
  }) async {
    final user = await (_database.select(_database.appUsers)
          ..where((u) => u.id.equals(accountId)))
        .getSingleOrNull();
    if (user == null || (role != null && user.role != role.name)) return null;
    if (!user.active) throw const AccountDeactivatedException();

    final now = _clock.nowUtc();
    if (user.lockedUntil != null && user.lockedUntil!.isAfter(now)) return null;

    if (!await _verifyPassword(password, user)) {
      final attempts = user.failedAttempts + 1;
      final lockTime = attempts >= AuthConstants.maxFailedAttempts
          ? now.add(const Duration(minutes: 5))
          : null;
      await _updateUser(
        accountId,
        AppUsersCompanion(
          failedAttempts: Value(attempts),
          lockedUntil: Value(lockTime),
        ),
      );
      return null;
    }

    if (user.failedAttempts > 0 || user.lockedUntil != null) {
      await _updateUser(
        accountId,
        const AppUsersCompanion(
          failedAttempts: Value(0),
          lockedUntil: Value(null),
        ),
      );
    }

    final all = await accounts();
    return all.firstWhere((a) => a.id == accountId);
  }

  Future<void> changePassword(
    LocalAccount account,
    String newPassword, {
    String? currentPassword,
  }) async {
    final trimmed = newPassword.trim();
    if (trimmed.length < AuthConstants.minPasswordLength) {
      throw ArgumentError('Password must contain at least 8 characters');
    }
    if (trimmed == AuthConstants.temporaryPassword) {
      throw ArgumentError('New password cannot be the temporary default');
    }
    final user = await (_database.select(_database.appUsers)
          ..where((u) => u.id.equals(account.id)))
        .getSingle();
    if (currentPassword != null) {
      if (!await _verifyPassword(currentPassword, user)) {
        throw StateError('Current password is incorrect');
      }
      if (await _verifyPassword(trimmed, user)) {
        throw ArgumentError('New password must be different from current');
      }
    }
    final (salt, hash) = await _hashPassword(trimmed);
    await _updateUser(
      account.id,
      AppUsersCompanion(
        pwSalt: Value(salt),
        pwHash: Value(hash),
        mustChange: const Value(false),
      ),
    );
  }

  Future<void> deactivateAccount(String accountId) =>
      _updateUser(accountId, const AppUsersCompanion(active: Value(false)));

  /// Creates a built-in [role] account (no employee link) only when no account
  /// of that role exists at all, so deactivating it is respected later.
  Future<bool> ensureAccountForRole(AuthRole role, String displayName) =>
      _database.transaction(() async {
        final query = _database.select(_database.appUsers)
          ..where((u) => u.role.equals(role.name))
          ..limit(1);
        if (await query.getSingleOrNull() != null) return false;
        await _insertUser(null, displayName, role);
        return true;
      });

  Future<void> resetPassword(String accountId) async {
    final (salt, hash) = await _hashPassword(AuthConstants.temporaryPassword);
    await _updateUser(
      accountId,
      AppUsersCompanion(
        pwSalt: Value(salt),
        pwHash: Value(hash),
        mustChange: const Value(true),
        failedAttempts: const Value(0),
        lockedUntil: const Value(null),
      ),
    );
  }

  Future<void> updateScopes(
    String accountId, {
    required List<String> teamIds,
    required List<String> housingIds,
  }) => _database.transaction(() async {
    await (_database.delete(_database.userScopes)
          ..where((s) => s.userId.equals(accountId)))
        .go();
    await _saveScopes(accountId, teamIds, housingIds);
  });

  Future<(String, String)> _hashPassword(String raw) => _hasher.hashEncoded(raw);

  Future<bool> _verifyPassword(String raw, AppUser user) =>
      _hasher.verifyEncoded(raw, salt: user.pwSalt, expectedHash: user.pwHash);

  Future<int> _updateUser(String id, AppUsersCompanion companion) =>
      (_database.update(_database.appUsers)
            ..where((u) => u.id.equals(id)))
          .write(companion);

  Future<String> _insertUser(
    String? employeeUid,
    String displayName,
    AuthRole role, [
    List<String> teamIds = const [],
    List<String> housingIds = const [],
  ]) async {
    final id = const Uuid().v4();
    final (salt, hash) = await _hashPassword(AuthConstants.temporaryPassword);
    await _database.transaction(() async {
      await _database.into(_database.appUsers).insert(
            AppUsersCompanion.insert(
              id: id,
              employeeUid: Value(employeeUid),
              displayName: displayName,
              role: role.name,
              pwHash: hash,
              pwSalt: salt,
              kdfParams: AuthConstants.kdfParamsJson,
              mustChange: const Value(true),
              createdAt: _clock.nowUtc(),
            ),
          );
      await _saveScopes(id, teamIds, housingIds);
    });
    return id;
  }

  Future<void> _saveScopes(
    String userId,
    List<String> teamIds,
    List<String> housingIds,
  ) async {
    const uuid = Uuid();
    for (final (type, sid) in [
      for (final tid in teamIds) (ScopeTypes.team, tid),
      for (final hid in housingIds) (ScopeTypes.housing, hid),
    ]) {
      await _database.into(_database.userScopes).insert(
            UserScopesCompanion.insert(
              id: uuid.v4(),
              userId: userId,
              scopeType: type,
              scopeId: sid,
            ),
          );
    }
  }
}
