import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart';

abstract final class OutboxRejectedReader {
  static Future<List<LocalEvent>> readRejected(
    AppDatabase database, {
    int limit = 100,
  }) async {
    final rows = await (database.select(database.events)
          ..where((e) => e.syncStatus.equals('rejected'))
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
          delivery: EventDelivery.rejected,
          isLate: row.late,
        ),
    ]);
  }

  static Future<int> readCount(AppDatabase database) async {
    final countCol = database.events.eventId.count();
    final q = database.selectOnly(database.events)
      ..addColumns([countCol])
      ..where(database.events.syncStatus.equals('rejected'));
    return await q.map((r) => r.read(countCol) ?? 0).getSingle();
  }
}
