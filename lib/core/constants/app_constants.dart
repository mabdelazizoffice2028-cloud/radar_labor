/// Centralized constants for database, auth, time, and housing.
abstract final class DatabaseConstants {
  static const String fileName = 'radar_labor.sqlite';
  static const int keyByteLength = 32;
  static const String keyStorageName = 'radar_labor.db_key';
  static const int schemaVersion = 6;
}

abstract final class TimeConstants {
  static const Duration riyadhUtcOffset = Duration(hours: 3);
  static const int defaultDayCutoffHour = 3;
}

abstract final class SettingsDefaults {
  static const int slaMinutes = 120;
}

abstract final class AuthConstants {
  static const String temporaryPassword = '123456';
  static const int minPasswordLength = 4;
  static const int maxPasswordLength = 8;
  static const int maxFailedAttempts = 5;
  static const int saltByteLength = 16;
  static const int argon2Memory = 19456;
  static const int argon2Iterations = 2;
  static const int argon2Parallelism = 1;
  static const int hashByteLength = 32;
  static const String kdfParamsJson = '{"m":19456,"t":2,"p":1}';
  static const String defaultProjectManagerName = 'Project Manager';
  static const String defaultHrName = 'Admin';
  static const List<Duration> lockoutDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
  ];
}

abstract final class ScopeTypes {
  static const String team = 'team';
  static const String housing = 'housing';
}

abstract final class HousingConstants {
  static const String defaultHousingId = 'main_campus';
  static const String defaultHousingName = 'Main CAMPOS';
  static const String defaultHousingNameAr = 'السكن الرئيسي';
}

abstract final class AppConstants {
  static const String defaultHousingId = HousingConstants.defaultHousingId;
  static const String defaultHousingName = HousingConstants.defaultHousingName;
  static const String defaultHousingNameAr = HousingConstants.defaultHousingNameAr;
}
