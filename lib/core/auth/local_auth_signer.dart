import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/auth_exceptions.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_account_reader.dart';
import 'package:radar_labor/core/auth/local_auth_password_service.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/time/clock.dart';

final class LocalAuthSigner {
  const LocalAuthSigner(
    this._database,
    this._clock,
    this._passwords,
    this._reader,
  );
  final AppDatabase _database;
  final Clock _clock;
  final LocalAuthPasswordService _passwords;
  final LocalAuthAccountReader _reader;

  Future<LocalAccount?> signIn({
    AuthRole? role,
    required String accountId,
    required String password,
  }) async {
    final user = await (_database.select(
      _database.appUsers,
    )..where((u) => u.id.equals(accountId))).getSingleOrNull();
    if (user == null || (role != null && user.role != role.name)) return null;
    if (!user.active) throw const AccountDeactivatedException();

    final now = _clock.nowUtc();
    if (user.lockedUntil != null && user.lockedUntil!.isAfter(now)) return null;

    if (!await _passwords.verifyPassword(password, user)) {
      final attempts = user.failedAttempts + 1;
      final lockTime = attempts >= AuthConstants.maxFailedAttempts
          ? now.add(const Duration(minutes: 5))
          : null;
      await (_database.update(_database.appUsers)..where((u) => u.id.equals(accountId)))
          .write(AppUsersCompanion(
            failedAttempts: Value(attempts),
            lockedUntil: Value(lockTime),
          ));
      return null;
    }

    if (user.failedAttempts > 0 || user.lockedUntil != null) {
      await (_database.update(_database.appUsers)..where((u) => u.id.equals(accountId)))
          .write(const AppUsersCompanion(
            failedAttempts: Value(0),
            lockedUntil: Value(null),
          ));
    }

    final all = await _reader.accounts();
    return all.firstWhere((a) => a.id == accountId);
  }
}
