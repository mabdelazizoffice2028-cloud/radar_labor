import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/clock.dart';

final class SyncEventsApplier {
  const SyncEventsApplier({
    required this.database,
    this.clock = const SystemClock(),
  });

  final AppDatabase database;
  final Clock clock;

  Future<int> applyInboundEvents(List<LocalEvent> events) async {
    if (events.isEmpty) return 0;
    var applied = 0;
    final now = clock.nowUtc();

    await database.transaction(() async {
      for (final event in events) {
        final existing = await (database.select(database.events)
              ..where((e) => e.eventId.equals(event.eventId)))
            .getSingleOrNull();

        if (existing == null) {
          final payload = <String, dynamic>{
            if (event.resolutionKind != null) 'kind': event.resolutionKind!.key,
            if (event.employmentType != null)
              'employmentType': event.employmentType,
            if (event.jobCategory != null) 'jobCategory': event.jobCategory,
          };
          await database.into(database.events).insert(
            EventsCompanion.insert(
              eventId: event.eventId,
              deviceId: event.deviceId,
              deviceSeq: event.deviceSeq,
              type: event.type.name,
              action: event.action.name,
              businessDate: event.businessDate,
              employeeUid: Value(event.employeeUid),
              teamId: Value(event.teamId),
              housingId: Value(event.housingId),
              userId: Value(event.userId),
              payload: Value(jsonEncode(payload)),
              deviceTime: event.deviceTimeUtc ?? now,
              receivedAt: Value(now),
              serverSeq: Value(event.serverSeq),
              late: Value(event.isLate),
              syncStatus: const Value('synced'),
            ),
          );
          applied++;
        } else if (existing.serverSeq == null && event.serverSeq != null) {
          await (database.update(database.events)
                ..where((e) => e.eventId.equals(event.eventId)))
              .write(
            EventsCompanion(
              serverSeq: Value(event.serverSeq),
              syncStatus: const Value('synced'),
            ),
          );
        }
      }
    });

    return applied;
  }
}
