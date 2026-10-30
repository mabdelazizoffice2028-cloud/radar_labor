import 'package:radar_labor/core/status/status_models.dart';

final class StatusEngineEvents {
  static List<LocalEvent> effectiveEvents(List<LocalEvent> events) {
    final latestByKey = <String, LocalEvent>{};
    for (final event in events.where((e) => e.delivery != EventDelivery.rejected)) {
      final key = [
        event.employeeUid ?? '',
        event.type.name,
        event.teamId ?? '',
        event.housingId ?? '',
      ].join('\u0000');
      final previous = latestByKey[key];
      if (previous == null || compareEvents(event, previous) > 0) {
        latestByKey[key] = event;
      }
    }
    final effective = latestByKey.values
        .where((event) => event.action == EventAction.set)
        .toList(growable: false);
    effective.sort((a, b) => compareEvents(b, a));
    return effective;
  }

  static int compareEvents(LocalEvent a, LocalEvent b) {
    final pendingOrder =
        (a.delivery == EventDelivery.pending ? 1 : 0) -
        (b.delivery == EventDelivery.pending ? 1 : 0);
    if (pendingOrder != 0) return pendingOrder;

    if (a.delivery != EventDelivery.pending && b.delivery != EventDelivery.pending) {
      final receivedComparison = _compareNullableDates(a.receivedAtUtc, b.receivedAtUtc);
      if (receivedComparison != 0) return receivedComparison;
    }

    final sequenceComparison = a.deviceSeq.compareTo(b.deviceSeq);
    if (sequenceComparison != 0) return sequenceComparison;
    return a.eventId.compareTo(b.eventId);
  }

  static int _compareNullableDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.toUtc().compareTo(b.toUtc());
  }
}
