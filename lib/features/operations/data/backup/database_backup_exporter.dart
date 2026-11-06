import 'dart:convert';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/time/clock.dart';

abstract final class DatabaseBackupExporter {
  static Future<String> export(AppDatabase db, Clock clock) async {
    final settings = await db.select(db.settings).get();
    final teams = await db.select(db.teams).get();
    final employees = await db.select(db.employees).get();
    final appUsers = await db.select(db.appUsers).get();
    final userScopes = await db.select(db.userScopes).get();
    final events = await db.select(db.events).get();

    final data = {
      'formatVersion': 1,
      'dbSchemaVersion': db.schemaVersion,
      'timestamp': clock.nowUtc().toIso8601String(),
      'settings': [for (final s in settings) {'key': s.key, 'value': s.value}],
      'teams': [
        for (final t in teams) {
          'teamId': t.teamId, 'nameAr': t.nameAr, 'nameEn': t.nameEn,
          'supervisorUserId': t.supervisorUserId, 'isActive': t.isActive,
        }
      ],
      'employees': [
        for (final e in employees) {
          'iqamaNo': e.iqamaNo, 'fullNameAr': e.fullNameAr, 'fullNameEn': e.fullNameEn,
          'jobTitle': e.jobTitle, 'jobCategory': e.jobCategory, 'employmentType': e.employmentType,
          'rentalCompany': e.rentalCompany, 'iqamaExpiry': e.iqamaExpiry?.toIso8601String(),
          'currentTeamId': e.currentTeamId, 'archivedAt': e.archivedAt?.toIso8601String(),
          'rowVersion': e.rowVersion,
        }
      ],
      'appUsers': [
        for (final u in appUsers) {
          'id': u.id, 'employeeUid': u.employeeUid, 'displayName': u.displayName,
          'role': u.role, 'active': u.active, 'pwHash': u.pwHash, 'pwSalt': u.pwSalt,
          'kdfParams': u.kdfParams, 'mustChange': u.mustChange, 'failedAttempts': u.failedAttempts,
          'lockedUntil': u.lockedUntil?.toIso8601String(), 'createdAt': u.createdAt.toIso8601String(),
        }
      ],
      'userScopes': [
        for (final s in userScopes) {
          'id': s.id, 'userId': s.userId, 'scopeType': s.scopeType, 'scopeId': s.scopeId,
        }
      ],
      'events': [
        for (final ev in events) {
          'eventId': ev.eventId, 'deviceId': ev.deviceId, 'deviceSeq': ev.deviceSeq,
          'type': ev.type, 'action': ev.action, 'businessDate': ev.businessDate,
          'employeeUid': ev.employeeUid, 'teamId': ev.teamId, 'housingId': ev.housingId,
          'userId': ev.userId, 'payload': ev.payload, 'deviceTime': ev.deviceTime.toIso8601String(),
          'receivedAt': ev.receivedAt?.toIso8601String(), 'serverSeq': ev.serverSeq,
          'late': ev.late, 'eventSchemaVersion': ev.eventSchemaVersion,
          'syncStatus': ev.syncStatus, 'rejectReason': ev.rejectReason,
        }
      ],
    };

    return jsonEncode(data);
  }
}
