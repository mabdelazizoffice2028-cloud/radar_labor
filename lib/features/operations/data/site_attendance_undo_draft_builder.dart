import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';

abstract final class SiteAttendanceUndoDraftBuilder {
  static List<EventDraft> build({
    required LedgerUndoPlan plan,
    required String actorUserId,
  }) => [
    for (final entry in plan.entries)
      EventDraft(
        type: entry.key.type,
        action: entry.restoreAction,
        businessDate: plan.businessDate,
        employeeUid: entry.key.employeeUid,
        teamId: entry.key.teamId,
        housingId: entry.key.housingId,
        userId: actorUserId,
        payload: {
          if (entry.key.type == EventType.resolution &&
              entry.resolutionKind != null)
            'kind': entry.resolutionKind!.key,
          if (entry.restoreAction == EventAction.set &&
              entry.employmentType != null)
            'employmentType': entry.employmentType,
          if (entry.restoreAction == EventAction.set &&
              entry.jobCategory != null)
            'jobCategory': entry.jobCategory,
        },
      ),
  ];
}
