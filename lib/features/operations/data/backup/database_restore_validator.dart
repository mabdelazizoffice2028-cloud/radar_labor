import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/operations/data/backup/database_backup_models.dart';

abstract final class DatabaseRestoreValidator {
  static ValidatedBackupData validate(String jsonString) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      throw BackupValidationException('Invalid JSON payload: $e');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const BackupValidationException('Backup payload must be a JSON object.');
    }
    final formatVersion = decoded['formatVersion'];
    if (formatVersion is! int || formatVersion < 1) {
      throw const BackupValidationException('Invalid or missing formatVersion.');
    }
    final dbSchemaVersion = decoded['dbSchemaVersion'];
    if (dbSchemaVersion is! int) {
      throw const BackupValidationException('Invalid or missing dbSchemaVersion.');
    }
    final timestamp = decoded['timestamp'] as String? ?? '';

    final settings = _parseList(decoded, 'settings', _toSetting);
    final teams = _parseList(decoded, 'teams', _toTeam);
    final employees = _parseList(decoded, 'employees', _toEmployee);
    final appUsers = _parseList(decoded, 'appUsers', _toAppUser);
    final userScopes = _parseList(decoded, 'userScopes', _toUserScope);
    final events = _parseList(decoded, 'events', _toEvent);

    return ValidatedBackupData(
      formatVersion: formatVersion, dbSchemaVersion: dbSchemaVersion,
      timestamp: timestamp, settings: settings, teams: teams,
      employees: employees, appUsers: appUsers, userScopes: userScopes, events: events,
    );
  }

  static List<T> _parseList<T>(Map<String, dynamic> root, String key, T Function(Map<String, dynamic>) fn) {
    final list = root[key];
    if (list is! List) throw BackupValidationException('Missing table array: $key');
    return [for (final item in list) if (item is Map<String, dynamic>) fn(item)];
  }

  static SettingsCompanion _toSetting(Map<String, dynamic> m) => SettingsCompanion(
    key: Value(m['key'] as String), value: Value(m['value'] as String),
  );

  static TeamsCompanion _toTeam(Map<String, dynamic> m) => TeamsCompanion(
    teamId: Value(m['teamId'] as String), nameAr: Value(m['nameAr'] as String),
    nameEn: Value(m['nameEn'] as String?), supervisorUserId: Value(m['supervisorUserId'] as String?),
    isActive: Value(m['isActive'] as bool? ?? true),
  );

  static EmployeesCompanion _toEmployee(Map<String, dynamic> m) => EmployeesCompanion(
    iqamaNo: Value(m['iqamaNo'] as String), fullNameAr: Value(m['fullNameAr'] as String),
    fullNameEn: Value(m['fullNameEn'] as String?), jobTitle: Value(m['jobTitle'] as String?),
    jobCategory: Value(m['jobCategory'] as String? ?? 'direct_labor'),
    employmentType: Value(m['employmentType'] as String? ?? 'company'),
    rentalCompany: Value(m['rentalCompany'] as String?),
    iqamaExpiry: Value(m['iqamaExpiry'] != null ? DateTime.parse(m['iqamaExpiry'] as String) : null),
    currentTeamId: Value(m['currentTeamId'] as String?),
    archivedAt: Value(m['archivedAt'] != null ? DateTime.parse(m['archivedAt'] as String) : null),
    rowVersion: Value(m['rowVersion'] as int? ?? 1),
  );

  static AppUsersCompanion _toAppUser(Map<String, dynamic> m) => AppUsersCompanion(
    id: Value(m['id'] as String), employeeUid: Value(m['employeeUid'] as String?),
    displayName: Value(m['displayName'] as String), role: Value(m['role'] as String),
    active: Value(m['active'] as bool? ?? true), pwHash: Value(m['pwHash'] as String),
    pwSalt: Value(m['pwSalt'] as String), kdfParams: Value(m['kdfParams'] as String),
    mustChange: Value(m['mustChange'] as bool? ?? true),
    failedAttempts: Value(m['failedAttempts'] as int? ?? 0),
    lockedUntil: Value(m['lockedUntil'] != null ? DateTime.parse(m['lockedUntil'] as String) : null),
    createdAt: Value(DateTime.parse(m['createdAt'] as String)),
  );

  static UserScopesCompanion _toUserScope(Map<String, dynamic> m) => UserScopesCompanion(
    id: Value(m['id'] as String), userId: Value(m['userId'] as String),
    scopeType: Value(m['scopeType'] as String), scopeId: Value(m['scopeId'] as String),
  );

  static EventsCompanion _toEvent(Map<String, dynamic> m) => EventsCompanion(
    eventId: Value(m['eventId'] as String), deviceId: Value(m['deviceId'] as String),
    deviceSeq: Value(m['deviceSeq'] as int), type: Value(m['type'] as String),
    action: Value(m['action'] as String), businessDate: Value(m['businessDate'] as String),
    employeeUid: Value(m['employeeUid'] as String?), teamId: Value(m['teamId'] as String?),
    housingId: Value(m['housingId'] as String?), userId: Value(m['userId'] as String?),
    payload: Value(m['payload'] as String? ?? '{}'), deviceTime: Value(DateTime.parse(m['deviceTime'] as String)),
    receivedAt: Value(m['receivedAt'] != null ? DateTime.parse(m['receivedAt'] as String) : null),
    serverSeq: Value(m['serverSeq'] as int?), late: Value(m['late'] as bool? ?? false),
    eventSchemaVersion: Value(m['eventSchemaVersion'] as int? ?? 1),
    syncStatus: Value(m['syncStatus'] as String? ?? 'pending'), rejectReason: Value(m['rejectReason'] as String?),
  );
}
