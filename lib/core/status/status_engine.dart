import 'package:radar_labor/core/status/status_models.dart';

final RegExp _isoDatePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// Pure Dart evaluator for the worker status rules in PRD §6.
///
/// No Flutter, database, file-system, clock, or network dependency is allowed
/// here. Inputs are immutable snapshots; the result preserves roster order.
final class StatusEngine {
  const StatusEngine();

  StatusSnapshot evaluate({
    required Iterable<WorkerProfile> workers,
    required Iterable<LocalEvent> events,
    required String businessDate,
    required DateTime nowUtc,
    required int slaMinutes,
  }) {
    if (!_isoDatePattern.hasMatch(businessDate) ||
        DateTime.tryParse(businessDate) == null) {
      throw ArgumentError.value(
        businessDate,
        'businessDate',
        'must be YYYY-MM-DD',
      );
    }
    if (slaMinutes < 0) {
      throw ArgumentError.value(slaMinutes, 'slaMinutes', 'cannot be negative');
    }

    final dayEvents = events
        .where((event) => event.businessDate == businessDate)
        .toList(growable: false);
    final effectiveEvents = _effectiveEvents(dayEvents);
    final results = <WorkerStatusResult>[];

    for (final worker in workers) {
      final workerEvents = dayEvents
          .where((event) => event.employeeUid == worker.employeeUid)
          .toList(growable: false);
      final eligible = worker.isActive && worker.employedOn(businessDate);
      final flags = <StatusFlag>{};

      if (!worker.isActive && workerEvents.isNotEmpty) {
        flags.add(StatusFlag.inactiveWorkerEvent);
      }
      if (!worker.employedOn(businessDate) && workerEvents.isNotEmpty) {
        flags.add(StatusFlag.eventOutsideEmployment);
      }
      if (workerEvents.any((event) => event.isLate)) {
        flags.add(StatusFlag.lateEvent);
      }
      if (workerEvents.any(
        (event) => event.delivery == EventDelivery.rejected,
      )) {
        flags.add(StatusFlag.rejectedEvent);
      }

      final activeWorkerEvents = effectiveEvents.where(
        (event) =>
            event.employeeUid == worker.employeeUid &&
            event.delivery != EventDelivery.rejected,
      );
      final siteEvents = activeWorkerEvents
          .where((event) => event.type == EventType.sitePresent)
          .toList(growable: false);
      final absentEvents = activeWorkerEvents
          .where(
            (event) =>
                event.type == EventType.housingAbsent &&
                worker.housingId != null &&
                event.housingId == worker.housingId,
          )
          .toList(growable: false);
      final hasJustification = activeWorkerEvents.any(
        (event) => event.type == EventType.justification,
      );
      final hasResolution = activeWorkerEvents.any(
        (event) =>
            event.type == EventType.resolution && event.resolutionKind != null,
      );
      final check = effectiveEvents
          .where(
            (event) =>
                event.type == EventType.housingCheck &&
                worker.housingId != null &&
                event.housingId == worker.housingId,
          )
          .firstOrNull;

      if (!hasResolution && absentEvents.isNotEmpty && siteEvents.isNotEmpty) {
        flags.add(StatusFlag.housingSiteConflict);
      }
      final activeTeams = siteEvents
          .map((event) => event.teamId)
          .whereType<String>()
          .toSet();
      if (!hasResolution && activeTeams.length > 1) {
        flags.add(StatusFlag.multipleSiteTeams);
      }

      final latestSite = siteEvents.firstOrNull;
      final isUnknown = siteEvents.isEmpty && absentEvents.isNotEmpty;
      final status = !eligible
          ? WorkerStatus.notRecorded
          : siteEvents.isNotEmpty
          ? WorkerStatus.onSite
          : absentEvents.isNotEmpty
          ? hasJustification
                ? WorkerStatus.justified
                : WorkerStatus.unknown
          : check != null
          ? WorkerStatus.housingOnly
          : WorkerStatus.notRecorded;

      final checkAt = check?.receivedAtUtc ?? check?.deviceTimeUtc;
      final elapsed = checkAt == null
          ? null
          : nowUtc.toUtc().difference(checkAt.toUtc());
      final breached =
          eligible &&
          isUnknown &&
          elapsed != null &&
          elapsed > Duration(minutes: slaMinutes);

      results.add(
        WorkerStatusResult(
          worker: worker,
          status: status,
          isEligible: eligible,
          flags: Set.unmodifiable(flags),
          isSlaBreached: breached,
          teamId: latestSite?.teamId,
          housingId: worker.housingId,
          housingCheckAtUtc: checkAt,
        ),
      );
    }

    return StatusSnapshot(
      businessDate: businessDate,
      workers: List.unmodifiable(results),
    );
  }

  List<LocalEvent> _effectiveEvents(List<LocalEvent> events) {
    final latestByKey = <String, LocalEvent>{};
    for (final event in events.where(
      (event) => event.delivery != EventDelivery.rejected,
    )) {
      final key = [
        event.employeeUid ?? '',
        event.type.name,
        event.teamId ?? '',
        event.housingId ?? '',
      ].join('\u0000');
      final previous = latestByKey[key];
      if (previous == null || _compareEvents(event, previous) > 0) {
        latestByKey[key] = event;
      }
    }

    final effective = latestByKey.values
        .where((event) => event.action == EventAction.set)
        .toList(growable: false);
    effective.sort(_compareEventsDescending);
    return effective;
  }

  int _compareEventsDescending(LocalEvent a, LocalEvent b) =>
      _compareEvents(b, a);

  int _compareEvents(LocalEvent a, LocalEvent b) {
    final pendingOrder =
        (a.delivery == EventDelivery.pending ? 1 : 0) -
        (b.delivery == EventDelivery.pending ? 1 : 0);
    if (pendingOrder != 0) return pendingOrder;

    if (a.delivery != EventDelivery.pending &&
        b.delivery != EventDelivery.pending) {
      final receivedComparison = _compareNullableDates(
        a.receivedAtUtc,
        b.receivedAtUtc,
      );
      if (receivedComparison != 0) return receivedComparison;
    }

    final sequenceComparison = a.deviceSeq.compareTo(b.deviceSeq);
    if (sequenceComparison != 0) return sequenceComparison;
    return a.eventId.compareTo(b.eventId);
  }

  int _compareNullableDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.toUtc().compareTo(b.toUtc());
  }
}
