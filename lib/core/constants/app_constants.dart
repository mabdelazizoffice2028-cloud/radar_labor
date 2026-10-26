/// Every magic value of the app lives here (CLAUDE.md §5).
abstract final class DatabaseConstants {
  static const String fileName = 'radar_labor.sqlite';
  static const int keyByteLength = 32;
  static const String keyStorageName = 'radar_labor.db_key';
  static const int schemaVersion = 5;
}

abstract final class TimeConstants {
  /// Saudi Arabia has no DST, so a fixed offset is enough (PRD §6).
  static const Duration riyadhUtcOffset = Duration(hours: 3);
  static const int defaultDayCutoffHour = 3;
}

abstract final class SettingsDefaults {
  static const int slaMinutes = 120;
}

abstract final class AuthConstants {
  static const String temporaryPassword = '123456';
  static const int minPasswordLength = 8;
  static const int maxFailedAttempts = 5;
  static const int saltByteLength = 16;
  static const int argon2Memory = 19456;
  static const int argon2Iterations = 2;
  static const int argon2Parallelism = 1;
  static const int hashByteLength = 32;

  /// Serialized Argon2id parameters stored next to every password hash.
  static const String kdfParamsJson = '{"m":19456,"t":2,"p":1}';

  /// Display names for the built-in administrator accounts created on first
  /// launch so the project manager and HR can sign in on an empty database.
  static const String defaultProjectManagerName = 'Project Manager';
  static const String defaultHrName = 'HR';

  /// Progressive lockout delays in seconds based on failed attempts count.
  static const List<Duration> lockoutDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
  ];
}

/// Stored values of `user_scopes.scope_type` (internal names, never shown).
abstract final class ScopeTypes {
  static const String team = 'team';
  static const String housing = 'housing';
}

/// Default housing campus configuration (zero-config default housing).
abstract final class AppConstants {
  static const String defaultHousingId = 'default-campus';
  static const String defaultHousingName = 'Main Campus';
}

abstract final class HousingConstants {
  static const String defaultHousingId = AppConstants.defaultHousingId;
  static const String defaultHousingName = AppConstants.defaultHousingName;
}
