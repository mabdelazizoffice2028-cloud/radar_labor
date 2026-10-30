import 'dart:async';
import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/sync/outbox_pending_reader.dart';
import 'package:radar_labor/core/sync/outbox_sync_marker.dart';
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
    late final StreamController<int> controller;
    StreamSubscription? subEvents;
    StreamSubscription? subAudits;

    Future<void> emitCount() async {
      if (!controller.isClosed) {
        try {
          controller.add(await readPendingCount());
        } catch (e) {
          if (!controller.isClosed) controller.addError(e);
        }
      }
    }

    controller = StreamController<int>.broadcast(
      onListen: () {
        emitCount();
        subEvents = (database.select(database.events)..where((e) => e.syncStatus.equals('pending')))
            .watch().listen((_) => emitCount());
        subAudits = (database.select(database.auditLogs)..where((a) => a.syncStatus.equals('pending')))
            .watch().listen((_) => emitCount());
      },
      onCancel: () {
        subEvents?.cancel();
        subAudits?.cancel();
      },
    );
    return controller.stream;
  }

  Future<int> readPendingCount() async {
    final countEvents = database.events.eventId.count();
    final qEvents = database.selectOnly(database.events)
      ..addColumns([countEvents])
      ..where(database.events.syncStatus.equals('pending'));
    final evCount = await qEvents.map((r) => r.read(countEvents) ?? 0).getSingle();

    final countAudits = database.auditLogs.auditId.count();
    final qAudits = database.selectOnly(database.auditLogs)
      ..addColumns([countAudits])
      ..where(database.auditLogs.syncStatus.equals('pending'));
    final auCount = await qAudits.map((r) => r.read(countAudits) ?? 0).getSingle();

    return evCount + auCount;
  }

  Future<List<LocalEvent>> readPendingEvents({int limit = 100}) =>
      OutboxPendingReader.readEvents(database, limit: limit);

  Future<List<AuditEntry>> readPendingAudits({int limit = 100}) =>
      OutboxPendingReader.readAudits(database, limit: limit);

  Future<void> markEventsSynced(Iterable<String> eventIds) =>
      OutboxSyncMarker.markEventsSynced(database, eventIds, clock);

  Future<void> markAuditsSynced(Iterable<String> auditIds) =>
      OutboxSyncMarker.markAuditsSynced(database, auditIds, clock);
}
