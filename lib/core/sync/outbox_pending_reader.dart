import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart';

abstract final class OutboxPendingReader {
  static Future<List<LocalEvent>> readEvents(AppDatabase database, {int limit = 100}) async {
    final rows = await (database.select(database.events)
          ..where((e) => e.syncStatus.equals('pending'))
          ..orderBy([(e) => OrderingTerm.asc(e.deviceSeq)])
          ..limit(limit))
        .get();
    return List.unmodifiable([
      for (final row in rows)
        LocalEvent(
          eventId: row.eventId, deviceSeq: row.deviceSeq,
          type: EventType.values.byName(row.type), action: EventAction.values.byName(row.action),
          businessDate: row.businessDate, employeeUid: row.employeeUid,
          teamId: row.teamId, housingId: row.housingId, userId: row.userId,
          receivedAtUtc: row.receivedAt?.toUtc(), deviceTimeUtc: row.deviceTime.toUtc(),
          delivery: EventDelivery.values.byName(row.syncStatus), isLate: row.late,
        ),
    ]);
  }

  static Future<List<AuditEntry>> readAudits(AppDatabase database, {int limit = 100}) async {
    final rows = await (database.select(database.auditLogs)
          ..where((a) => a.syncStatus.equals('pending'))
          ..orderBy([(a) => OrderingTerm.asc(a.deviceTime)])
          ..limit(limit))
        .get();
    return List.unmodifiable([
      for (final row in rows)
        AuditEntry(
          auditId: row.auditId, userId: row.userId, action: row.action,
          entityType: row.entityType, entityId: row.entityId, deviceId: row.deviceId,
          deviceTime: row.deviceTime, receivedAt: row.receivedAt, syncStatus: row.syncStatus,
        ),
    ]);
  }
}
