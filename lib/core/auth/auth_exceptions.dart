/// Exceptions thrown during authentication and account management operations.
library;

final class AuthConflictException implements Exception {
  const AuthConflictException([this.message = 'Account conflict']);
  final String message;
  @override
  String toString() => message;
}

final class AccountLockedException implements Exception {
  const AccountLockedException(this.lockedUntil);
  final DateTime lockedUntil;
}

final class AccountDeactivatedException implements Exception {
  const AccountDeactivatedException();
}
