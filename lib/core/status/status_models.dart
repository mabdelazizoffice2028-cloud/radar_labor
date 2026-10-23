/// A worker's canonical status calculated from the append-only local event log.
enum WorkerStatus { onSite, housingOnly, unknown, justified, notRecorded }

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

/// Cloud delivery state is retained in the local schema for future migration,
/// but the current owner-approved build never starts a sync client.
enum EventDelivery { pending, sent, acked, rejected }

enum StatusFlag {
  housingSiteConflict,
  multipleSiteTeams,
  inactiveWorkerEvent,
  eventOutsideEmployment,
  lateEvent,
  rejectedEvent,
}

final class EmploymentPeriod {
  const EmploymentPeriod(this.startDate, {this.endDate});

  final String startDate;
  final String? endDate;

  bool contains(String date) =>
      date.compareTo(startDate) >= 0 &&
      (endDate == null || date.compareTo(endDate!) <= 0);
}

final class WorkerProfile {
  const WorkerProfile({
    required this.employeeUid,
    required this.code,
    required this.fullName,
    required this.employmentPeriods,
    this.currentTeamId,
    this.housingId,
    this.isActive = true,
  });

  final String employeeUid;
  final String code;
  final String fullName;
  final String? currentTeamId;
  final String? housingId;
  final bool isActive;
  final List<EmploymentPeriod> employmentPeriods;

  bool employedOn(String businessDate) =>
      employmentPeriods.isEmpty ||
      employmentPeriods.any((period) => period.contains(businessDate));
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
  final int deviceSeq;
  final DateTime? receivedAtUtc;
  final DateTime? deviceTimeUtc;
  final EventDelivery delivery;
  final bool isLate;
  final ResolutionKind? resolutionKind;
}

final class WorkerStatusResult {
  const WorkerStatusResult({
    required this.worker,
    required this.status,
    required this.isEligible,
    required this.flags,
    required this.isSlaBreached,
    this.teamId,
    this.housingId,
    this.housingCheckAtUtc,
  });

  final WorkerProfile worker;
  final WorkerStatus status;
  final bool isEligible;
  final Set<StatusFlag> flags;
  final bool isSlaBreached;
  final String? teamId;
  final String? housingId;
  final DateTime? housingCheckAtUtc;
}

final class StatusSnapshot {
  const StatusSnapshot({required this.businessDate, required this.workers});

  final String businessDate;
  final List<WorkerStatusResult> workers;

  int count(WorkerStatus status) => workers
      .where((worker) => worker.isEligible && worker.status == status)
      .length;

  int get eligibleCount => workers.where((worker) => worker.isEligible).length;
}
