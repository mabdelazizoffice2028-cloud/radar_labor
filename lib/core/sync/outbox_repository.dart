import 'dart:async';
import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/sync/outbox_pending_reader.dart';
import 'package:radar_labor/core/sync/outbox_rejected_reader.dart';
import 'package:radar_labor/core/sync/outbox_sync_marker.dart';
import 'package:radar_labor/core/time/clock.dart';

final class OutboxRepository {
  const OutboxRepository({
    required this.database,
    this.clock = const SystemClock(),
  });

  final AppDatabase database;
  final Clock clock;

  Stream<int> watchPendingCount() {
    late final StreamController<int> controller;
    StreamSubscription? s1; StreamSubscription? s2;
    Future<void> emit() async {
      if (!controller.isClosed) {
        try { controller.add(await readPendingCount()); }
        catch (e) { if (!controller.isClosed) controller.addError(e); }
      }
    }
    controller = StreamController<int>.broadcast(
      onListen: () {
        emit();
        s1 = (database.select(database.events)..where((e) => e.syncStatus.equals('pending'))).watch().listen((_) => emit());
        s2 = (database.select(database.auditLogs)..where((a) => a.syncStatus.equals('pending'))).watch().listen((_) => emit());
      },
      onCancel: () { s1?.cancel(); s2?.cancel(); },
    );
    return controller.stream;
  }

  Future<int> readPendingCount() async {
    final cE = database.events.eventId.count();
    final qE = database.selectOnly(database.events)..addColumns([cE])..where(database.events.syncStatus.equals('pending'));
    final evCount = await qE.map((r) => r.read(cE) ?? 0).getSingle();

    final cA = database.auditLogs.auditId.count();
    final qA = database.selectOnly(database.auditLogs)..addColumns([cA])..where(database.auditLogs.syncStatus.equals('pending'));
    final auCount = await qA.map((r) => r.read(cA) ?? 0).getSingle();
    return evCount + auCount;
  }

  Future<List<LocalEvent>> readPendingEvents({int limit = 100}) => OutboxPendingReader.readEvents(database, limit: limit);
  Future<List<AuditEntry>> readPendingAudits({int limit = 100}) => OutboxPendingReader.readAudits(database, limit: limit);
  Future<void> markEventsSynced(Iterable<String> eventIds) => OutboxSyncMarker.markEventsSynced(database, eventIds, clock);
  Future<void> markAuditsSynced(Iterable<String> auditIds) => OutboxSyncMarker.markAuditsSynced(database, auditIds, clock);

  Future<void> markEventsRejected(Map<String, String> rejected) => OutboxSyncMarker.markEventsRejected(database, rejected, clock);
  Future<List<LocalEvent>> readRejectedEvents({int limit = 100}) => OutboxRejectedReader.readRejected(database, limit: limit);
  Future<int> readRejectedCount() => OutboxRejectedReader.readCount(database);
}
