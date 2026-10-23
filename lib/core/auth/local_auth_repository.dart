import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/auth_exceptions.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/password_hasher.dart';
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

  static const String _defaultKdf = '{"m":19456,"t":2,"p":1}';

  Future<List<LocalAccount>> accounts({bool activeOnly = false}) async {
    final query = _database.select(_database.appUsers);
    if (activeOnly) {
      query.where((u) => u.active);
    }
    final userRows = await query.get();
    if (userRows.isEmpty) return const [];

    final scopeRows = await _database.select(_database.userScopes).get();
    final teamsMap = <String, List<String>>{};
    final housingsMap = <String, List<String>>{};

    for (final s in scopeRows) {
      if (s.scopeType == 'team') {
        (teamsMap[s.userId] ??= []).add(s.scopeId);
      } else if (s.scopeType == 'housing') {
        (housingsMap[s.userId] ??= []).add(s.scopeId);
      }
    }

    return List.unmodifiable(
      userRows.map(
        (u) => LocalAccount(
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
      ),
    );
  }

  Future<void> createInitialAccounts({
    required String projectManagerEmployeeUid,
    required String hrEmployeeUid,
    required String projectManagerName,
    required String hrName,
  }) async {
    final existing = await accounts();
    if (existing.isNotEmpty) throw const AuthConflictException();

    await _database.transaction(() async {
      await _insertUser(
        employeeUid: projectManagerEmployeeUid,
        displayName: projectManagerName,
        role: AuthRole.projectManager,
      );
      await _insertUser(
        employeeUid: hrEmployeeUid,
        displayName: hrName,
        role: AuthRole.hr,
      );
    });
  }

  Future<void> createAccount({
    required String employeeUid,
    required String displayName,
    required AuthRole role,
    List<String> teamIds = const [],
    List<String> housingIds = const [],
  }) async {
    final existing = await accounts();
    if (existing.any((a) => a.employeeUid == employeeUid && a.role == role)) {
      throw const AuthConflictException();
    }
    await _insertUser(
      employeeUid: employeeUid,
      displayName: displayName,
      role: role,
      teamIds: teamIds,
      housingIds: housingIds,
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

    final candidate = await _hasher.hash(password, base64Url.decode(user.pwSalt));
    final verified = _hasher.constantTimeEquals(candidate, base64Url.decode(user.pwHash));

    if (!verified) {
      final attempts = user.failedAttempts + 1;
      final lockTime = attempts >= AuthConstants.maxFailedAttempts
          ? now.add(const Duration(minutes: 5))
          : null;

      await (_database.update(_database.appUsers)..where((u) => u.id.equals(accountId))).write(
        AppUsersCompanion(failedAttempts: Value(attempts), lockedUntil: Value(lockTime)),
      );
      return null;
    }

    if (user.failedAttempts > 0 || user.lockedUntil != null) {
      await (_database.update(_database.appUsers)..where((u) => u.id.equals(accountId))).write(
        const AppUsersCompanion(failedAttempts: Value(0), lockedUntil: Value(null)),
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
      final currentHash = await _hasher.hash(currentPassword, base64Url.decode(user.pwSalt));
      if (!_hasher.constantTimeEquals(currentHash, base64Url.decode(user.pwHash))) {
        throw StateError('Current password is incorrect');
      }
      final newCandidate = await _hasher.hash(trimmed, base64Url.decode(user.pwSalt));
      if (_hasher.constantTimeEquals(newCandidate, base64Url.decode(user.pwHash))) {
        throw ArgumentError('New password must be different from current password');
      }
    }

    final salt = _hasher.randomBytes(AuthConstants.saltByteLength);
    final hash = await _hasher.hash(trimmed, salt);

    await (_database.update(_database.appUsers)..where((u) => u.id.equals(account.id))).write(
      AppUsersCompanion(
        pwSalt: Value(base64UrlEncode(salt)),
        pwHash: Value(base64UrlEncode(hash)),
        mustChange: const Value(false),
      ),
    );
  }

  Future<void> deactivateAccount(String accountId) async {
    await (_database.update(_database.appUsers)
          ..where((u) => u.id.equals(accountId)))
        .write(const AppUsersCompanion(active: Value(false)));
  }

  Future<void> resetPassword(String accountId) async {
    final salt = _hasher.randomBytes(AuthConstants.saltByteLength);
    final hash = await _hasher.hash(AuthConstants.temporaryPassword, salt);
    await (_database.update(_database.appUsers)
          ..where((u) => u.id.equals(accountId)))
        .write(
          AppUsersCompanion(
            pwSalt: Value(base64UrlEncode(salt)),
            pwHash: Value(base64UrlEncode(hash)),
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
  }) async {
    await _database.transaction(() async {
      await (_database.delete(_database.userScopes)
            ..where((s) => s.userId.equals(accountId)))
          .go();
      await _saveScopes(accountId, teamIds, housingIds);
    });
  }

  Future<void> _insertUser({
    required String employeeUid,
    required String displayName,
    required AuthRole role,
    List<String> teamIds = const [],
    List<String> housingIds = const [],
  }) async {
    final id = const Uuid().v4();
    final salt = _hasher.randomBytes(AuthConstants.saltByteLength);
    final hash = await _hasher.hash(AuthConstants.temporaryPassword, salt);

    await _database.transaction(() async {
      await _database.into(_database.appUsers).insert(
        AppUsersCompanion.insert(
          id: id,
          employeeUid: employeeUid,
          displayName: displayName,
          role: role.name,
          pwHash: base64UrlEncode(hash),
          pwSalt: base64UrlEncode(salt),
          kdfParams: _defaultKdf,
          mustChange: const Value(true),
          createdAt: _clock.nowUtc(),
        ),
      );
      await _saveScopes(id, teamIds, housingIds);
    });
  }

  Future<void> _saveScopes(
    String userId,
    List<String> teamIds,
    List<String> housingIds,
  ) async {
    const uuid = Uuid();
    for (final tid in teamIds) {
      await _database.into(_database.userScopes).insert(
        UserScopesCompanion.insert(
          id: uuid.v4(),
          userId: userId,
          scopeType: 'team',
          scopeId: tid,
        ),
      );
    }
    for (final hid in housingIds) {
      await _database.into(_database.userScopes).insert(
        UserScopesCompanion.insert(
          id: uuid.v4(),
          userId: userId,
          scopeType: 'housing',
          scopeId: hid,
        ),
      );
    }
  }
}
