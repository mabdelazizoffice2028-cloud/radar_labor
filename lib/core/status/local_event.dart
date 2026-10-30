enum EventType {
  housingCheck,
  housingAbsent,
  sitePresent,
  siteSubmitted,
  justification,
  resolution,
}

enum EventAction { set, clear }

enum ResolutionKind {
  confirmPresentLeftEarly('confirm_present_left_early'),
  movedDuringDay('moved_during_day'),
  housingError('housing_error'),
  siteError('site_error'),
  officialErrand('official_errand');

  const ResolutionKind(this.key);
  final String key;

  static ResolutionKind? fromKey(Object? value) {
    if (value is! String) return null;
    for (final kind in values) {
      if (kind.key == value) return kind;
    }
    return null;
  }
}

enum EventDelivery { pending, sent, acked, rejected }

enum StatusFlag {
  housingSiteConflict,
  multipleSiteTeams,
  inactiveWorkerEvent,
  eventOutsideEmployment,
  lateEvent,
  rejectedEvent,
}

final class LocalEvent {
  const LocalEvent({
    required this.eventId,
    required this.type,
    required this.action,
    required this.businessDate,
    required this.deviceSeq,
    this.employeeUid,
    this.teamId,
    this.housingId,
    this.userId,
    this.receivedAtUtc,
    this.deviceTimeUtc,
    this.delivery = EventDelivery.pending,
    this.isLate = false,
    this.resolutionKind,
  });

  final String eventId;
  final EventType type;
  final EventAction action;
  final String businessDate;
  final String? employeeUid;
  final String? teamId;
  final String? housingId;
  final String? userId;
  final int deviceSeq;
  final DateTime? receivedAtUtc;
  final DateTime? deviceTimeUtc;
  final EventDelivery delivery;
  final bool isLate;
  final ResolutionKind? resolutionKind;
}
