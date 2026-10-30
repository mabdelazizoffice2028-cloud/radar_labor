import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/password_hasher.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';

final class LocalAuthPasswordService {
  const LocalAuthPasswordService(this._database, this._hasher);
  final AppDatabase _database;
  final PasswordHasher _hasher;

  Future<(String, String)> hashPassword(String raw) => _hasher.hashEncoded(raw);

  Future<bool> verifyPassword(String raw, AppUser user) =>
      _hasher.verifyEncoded(raw, salt: user.pwSalt, expectedHash: user.pwHash);

  Future<void> changePassword(
    LocalAccount account,
    String newPassword, {
    String? currentPassword,
  }) async {
    final trimmed = newPassword.trim();
    if (trimmed.length < AuthConstants.minPasswordLength ||
        trimmed.length > AuthConstants.maxPasswordLength) {
      throw ArgumentError('Password must be between 4 and 8 characters');
    }
    if (trimmed == AuthConstants.temporaryPassword) {
      throw ArgumentError('New password cannot be the temporary default');
    }
    final user = await (_database.select(
      _database.appUsers,
    )..where((u) => u.id.equals(account.id))).getSingle();
    if (currentPassword != null) {
      if (!await verifyPassword(currentPassword, user)) {
        throw StateError('Current password is incorrect');
      }
      if (await verifyPassword(trimmed, user)) {
        throw ArgumentError('New password must be different from current');
      }
    }
    final (salt, hash) = await hashPassword(trimmed);
    await (_database.update(_database.appUsers)..where((u) => u.id.equals(account.id)))
        .write(AppUsersCompanion(
          pwSalt: Value(salt),
          pwHash: Value(hash),
          mustChange: const Value(false),
        ));
  }

  Future<void> resetPassword(String accountId) async {
    final (salt, hash) = await hashPassword(AuthConstants.temporaryPassword);
    await (_database.update(_database.appUsers)..where((u) => u.id.equals(accountId)))
        .write(AppUsersCompanion(
          pwSalt: Value(salt),
          pwHash: Value(hash),
          mustChange: const Value(true),
          failedAttempts: const Value(0),
          lockedUntil: const Value(null),
        ));
  }
}
