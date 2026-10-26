import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/clock.dart';

/// Local outbox repository tracking pending attendance events and audit log rows (PRD §17.4, §23.6).
final class OutboxRepository {
  const OutboxRepository({
    required this.database,
    this.clock = const SystemClock(),
  });

  final AppDatabase database;
  final Clock clock;

  /// Reactive stream of the total number of pending items waiting for upload.
  Stream<int> watchPendingCount() {
    final eventsStream = (database.select(
      database.events,
    )..where((e) => e.syncStatus.equals('pending'))).watch();
    return eventsStream.asyncMap((_) => readPendingCount());
  }

  Future<int> readPendingCount() async {
    final pendingEvents = await (database.select(
      database.events,
    )..where((e) => e.syncStatus.equals('pending'))).get();
    final pendingAudits = await (database.select(
      database.auditLogs,
    )..where((a) => a.syncStatus.equals('pending'))).get();
    return pendingEvents.length + pendingAudits.length;
  }

  Future<List<LocalEvent>> readPendingEvents({int limit = 100}) async {
    final rows =
        await (database.select(database.events)
              ..where((e) => e.syncStatus.equals('pending'))
              ..orderBy([(e) => OrderingTerm.asc(e.deviceSeq)])
              ..limit(limit))
            .get();
    return List.unmodifiable([
      for (final row in rows)
        LocalEvent(
          eventId: row.eventId,
          deviceSeq: row.deviceSeq,
          type: EventType.values.byName(row.type),
          action: EventAction.values.byName(row.action),
          businessDate: row.businessDate,
          employeeUid: row.employeeUid,
          teamId: row.teamId,
          housingId: row.housingId,
          userId: row.userId,
          receivedAtUtc: row.receivedAt?.toUtc(),
          deviceTimeUtc: row.deviceTime.toUtc(),
          delivery: EventDelivery.values.byName(row.syncStatus),
          isLate: row.late,
        ),
    ]);
  }

  Future<List<AuditEntry>> readPendingAudits({int limit = 100}) async {
    final rows =
        await (database.select(database.auditLogs)
              ..where((a) => a.syncStatus.equals('pending'))
              ..orderBy([(a) => OrderingTerm.asc(a.deviceTime)])
              ..limit(limit))
            .get();
    return List.unmodifiable([
      for (final row in rows)
        AuditEntry(
          auditId: row.auditId,
          userId: row.userId,
          action: row.action,
          entityType: row.entityType,
          entityId: row.entityId,
          deviceId: row.deviceId,
          deviceTime: row.deviceTime,
          receivedAt: row.receivedAt,
          syncStatus: row.syncStatus,
        ),
    ]);
  }

  Future<void> markEventsSynced(Iterable<String> eventIds) async {
    if (eventIds.isEmpty) return;
    final now = clock.nowUtc();
    await database.transaction(() async {
      for (final id in eventIds) {
        await (database.update(
          database.events,
        )..where((e) => e.eventId.equals(id))).write(
          EventsCompanion(
            syncStatus: const Value('synced'),
            receivedAt: Value(now),
          ),
        );
      }
    });
  }

  Future<void> markAuditsSynced(Iterable<String> auditIds) async {
    if (auditIds.isEmpty) return;
    final now = clock.nowUtc();
    await database.transaction(() async {
      for (final id in auditIds) {
        await (database.update(
          database.auditLogs,
        )..where((a) => a.auditId.equals(id))).write(
          AuditLogsCompanion(
            syncStatus: const Value('synced'),
            receivedAt: Value(now),
          ),
        );
      }
    });
  }
}
