import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/time/clock.dart';

abstract final class OutboxSyncMarker {
  static Future<void> markEventsSynced(
    AppDatabase database,
    Iterable<String> eventIds,
    Clock clock,
  ) async {
    if (eventIds.isEmpty) return;
    final now = clock.nowUtc();
    await database.transaction(() async {
      for (final id in eventIds) {
        await (database.update(database.events)..where((e) => e.eventId.equals(id))).write(
          EventsCompanion(syncStatus: const Value('synced'), receivedAt: Value(now)),
        );
      }
    });
  }

  static Future<void> markAuditsSynced(
    AppDatabase database,
    Iterable<String> auditIds,
    Clock clock,
  ) async {
    if (auditIds.isEmpty) return;
    final now = clock.nowUtc();
    await database.transaction(() async {
      for (final id in auditIds) {
        await (database.update(database.auditLogs)..where((a) => a.auditId.equals(id))).write(
          AuditLogsCompanion(syncStatus: const Value('synced'), receivedAt: Value(now)),
        );
      }
    });
  }
}
