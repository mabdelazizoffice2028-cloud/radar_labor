import 'package:radar_labor/core/status/staff_category_resolver.dart';
import 'package:radar_labor/core/status/status_models.dart';

final class StatusEngineWorkerEvaluator {
  static WorkerStatusResult evaluateWorker({
    required WorkerProfile worker,
    required List<LocalEvent> dayEvents,
    required List<LocalEvent> effectiveEvents,
    required String businessDate,
    required DateTime nowUtc,
    required int slaMinutes,
    required bool isFriday,
  }) {
    final workerEvents = dayEvents.where((e) => e.employeeUid == worker.employeeUid).toList(growable: false);
    final eligible = worker.isActive && !worker.isOnLeave && worker.employedOn(businessDate);
    final flags = <StatusFlag>{};
    if (!worker.isActive && workerEvents.isNotEmpty) flags.add(StatusFlag.inactiveWorkerEvent);
    if (!worker.employedOn(businessDate) && workerEvents.isNotEmpty) flags.add(StatusFlag.eventOutsideEmployment);
    if (workerEvents.any((e) => e.isLate)) flags.add(StatusFlag.lateEvent);
    if (workerEvents.any((e) => e.delivery == EventDelivery.rejected)) flags.add(StatusFlag.rejectedEvent);

    final activeEvents = effectiveEvents.where(
      (e) => e.employeeUid == worker.employeeUid && e.delivery != EventDelivery.rejected,
    );
    final isStaff = !isFriday && StaffCategoryResolver.isAutoPresentStaff(worker.jobCategory);
    final siteEvents = activeEvents.where((e) => e.type == EventType.sitePresent).toList(growable: false);
    final absentEvents = isFriday ? const <LocalEvent>[] : activeEvents.where(
      (e) => e.type == EventType.housingAbsent && ((worker.housingId != null && e.housingId == worker.housingId) || isStaff),
    ).toList(growable: false);
    final hasJustification = activeEvents.any((e) => e.type == EventType.justification);
    final hasResolution = activeEvents.any((e) => e.type == EventType.resolution && e.resolutionKind != null);
    final check = isFriday ? null : effectiveEvents.where(
      (e) => e.type == EventType.housingCheck && worker.housingId != null && e.housingId == worker.housingId,
    ).firstOrNull;

    if (!isFriday && !hasResolution && absentEvents.isNotEmpty && siteEvents.isNotEmpty) {
      flags.add(StatusFlag.housingSiteConflict);
    }
    final activeTeams = siteEvents.map((e) => e.teamId).whereType<String>().toSet();
    if (!hasResolution && activeTeams.length > 1) flags.add(StatusFlag.multipleSiteTeams);

    final status = !eligible
        ? WorkerStatus.notRecorded
        : isFriday
            ? (siteEvents.isNotEmpty ? WorkerStatus.onSite : WorkerStatus.notRecorded)
            : siteEvents.isNotEmpty
                ? WorkerStatus.onSite
                : absentEvents.isNotEmpty
                    ? (hasJustification ? WorkerStatus.justified : WorkerStatus.unknown)
                    : isStaff
                        ? WorkerStatus.onSite
                        : (check != null ? WorkerStatus.housingOnly : WorkerStatus.notRecorded);

    final checkAt = check?.receivedAtUtc ?? check?.deviceTimeUtc;
    final elapsed = checkAt == null ? null : nowUtc.toUtc().difference(checkAt.toUtc());
    final isUnknown = !isFriday && siteEvents.isEmpty && absentEvents.isNotEmpty && !hasJustification;
    final breached = eligible && isUnknown && elapsed != null && elapsed > Duration(minutes: slaMinutes);

    return WorkerStatusResult(
      worker: worker,
      status: status,
      isEligible: eligible,
      flags: Set.unmodifiable(flags),
      isSlaBreached: breached,
      teamId: siteEvents.firstOrNull?.teamId,
      housingId: worker.housingId,
      housingCheckAtUtc: checkAt,
    );
  }
}
