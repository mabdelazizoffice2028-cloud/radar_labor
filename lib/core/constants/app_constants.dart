/// Every magic value of the app lives here (CLAUDE.md §5).
abstract final class DatabaseConstants {
  static const String fileName = 'radar_labor.sqlite';
  static const int keyByteLength = 32;
  static const String keyStorageName = 'radar_labor.db_key';
  static const int schemaVersion = 2;
}

abstract final class TimeConstants {
  /// Saudi Arabia has no DST, so a fixed offset is enough (PRD §6).
  static const Duration riyadhUtcOffset = Duration(hours: 3);
  static const int defaultDayCutoffHour = 3;
}

abstract final class SettingsDefaults {
  static const int slaMinutes = 120;
}
