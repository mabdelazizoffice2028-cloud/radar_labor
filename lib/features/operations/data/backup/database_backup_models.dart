import 'package:radar_labor/core/database/app_database.dart';

final class ValidatedBackupData {
  const ValidatedBackupData({
    required this.formatVersion,
    required this.dbSchemaVersion,
    required this.timestamp,
    required this.settings,
    required this.teams,
    required this.employees,
    required this.appUsers,
    required this.userScopes,
    required this.events,
  });

  final int formatVersion;
  final int dbSchemaVersion;
  final String timestamp;
  final List<SettingsCompanion> settings;
  final List<TeamsCompanion> teams;
  final List<EmployeesCompanion> employees;
  final List<AppUsersCompanion> appUsers;
  final List<UserScopesCompanion> userScopes;
  final List<EventsCompanion> events;
}

final class BackupValidationException implements Exception {
  const BackupValidationException(this.message);
  final String message;

  @override
  String toString() => 'BackupValidationException: $message';
}
