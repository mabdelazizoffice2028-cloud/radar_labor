abstract final class AppSettingKeys {
  static const String dayCutoffHour = 'day_cutoff_hour';
  static const String deviceId = 'device_id';
  static const String deviceSequence = 'device_sequence';
  static const String locale = 'locale';
  static const String slaMinutes = 'sla_minutes';
  static const String rosterEpoch = 'roster_epoch';
  static const String deviceActivated = 'device_activated';
  static const String lastLoggedInAccountId = 'last_logged_in_account_id';
  static const String housingLockoutHour = 'housing_lockout_hour';
  static const String siteLockoutHour = 'site_lockout_hour';
  static const String workerLeaves = 'worker_leaves_v1';
  static const String draftSiteAttendancePrefix = 'draft_site_attendance_';
  static const String draftHousingCheckPrefix = 'draft_housing_check_';

  static String draftSiteAttendance(String teamId, String date) =>
      '$draftSiteAttendancePrefix${teamId}_$date';

  static String draftHousingCheck(String housingId, String date) =>
      '$draftHousingCheckPrefix${housingId}_$date';
}
