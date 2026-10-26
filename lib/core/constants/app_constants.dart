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

  /// Progressive lockout delays in seconds based on failed attempts count.
  static const List<Duration> lockoutDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
  ];
}
