import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

/// Builds the atomic event batch and [LedgerUndoPlan] for a site attendance save.
final class SiteAttendanceSaveBuilder {
  const SiteAttendanceSaveBuilder._();

  static ({
    Set<String> finalSelectedIds,
    LedgerUndoPlan undoPlan,
    List<EventDraft> drafts,
  })
  build({
    required PreparedSiteSave prepared,
    required Map<String, ConflictResolutionChoice> resolutions,
    required AttendanceLedger ledger,
    required String actorUserId,
  }) {
    final finalSelectedIds = Set<String>.from(prepared.selectedWorkerIds);
    for (final c in prepared.conflicts) {
      if (resolutions[c.worker.id] == ConflictResolutionChoice.skipWorker) {
        finalSelectedIds.remove(c.worker.id);
      }
    }

    final previousPresent = ledger.presentWorkerIdsForTeam(prepared.team.id);
    final teamWorkerIds = {...previousPresent, ...finalSelectedIds};

    final touchedKeys = <LedgerKey>[
      for (final c in prepared.conflicts)
        if (resolutions[c.worker.id] ==
            ConflictResolutionChoice.transferDuringDay)
          LedgerKey(type: EventType.resolution, employeeUid: c.worker.id)
        else if (resolutions[c.worker.id] ==
            ConflictResolutionChoice.removeFromOtherTeam)
          LedgerKey(
            type: EventType.sitePresent,
            employeeUid: c.worker.id,
            teamId: c.otherTeamId,
          ),
      for (final id in teamWorkerIds)
        LedgerKey(
          type: EventType.sitePresent,
          employeeUid: id,
          teamId: prepared.team.id,
        ),
      LedgerKey(type: EventType.siteSubmitted, teamId: prepared.team.id),
    ];

    final undoPlan = LedgerUndoPlan.capture(
      businessDate: prepared.date,
      ledger: ledger,
      touchedKeys: touchedKeys,
    );

    final drafts = <EventDraft>[
      for (final c in prepared.conflicts)
        if (resolutions[c.worker.id] ==
            ConflictResolutionChoice.transferDuringDay)
          EventDraft(
            type: EventType.resolution,
            action: EventAction.set,
            businessDate: prepared.date,
            employeeUid: c.worker.id,
            teamId: prepared.team.id,
            userId: actorUserId,
            payload: {'kind': ResolutionKind.movedDuringDay.key},
          )
        else if (resolutions[c.worker.id] ==
            ConflictResolutionChoice.removeFromOtherTeam)
          EventDraft(
            type: EventType.sitePresent,
            action: EventAction.clear,
            businessDate: prepared.date,
            employeeUid: c.worker.id,
            teamId: c.otherTeamId,
            userId: actorUserId,
            payload: const {'reason': 'conflict_correction'},
          ),
      for (final id in teamWorkerIds)
        EventDraft(
          type: EventType.sitePresent,
          action: finalSelectedIds.contains(id)
              ? EventAction.set
              : EventAction.clear,
          businessDate: prepared.date,
          employeeUid: id,
          teamId: prepared.team.id,
          userId: actorUserId,
        ),
      EventDraft(
        type: EventType.siteSubmitted,
        action: EventAction.set,
        businessDate: prepared.date,
        teamId: prepared.team.id,
        userId: actorUserId,
        payload: {'presentCount': finalSelectedIds.length},
      ),
    ];

    return (
      finalSelectedIds: Set.unmodifiable(finalSelectedIds),
      undoPlan: undoPlan,
      drafts: List.unmodifiable(drafts),
    );
  }

  static List<EventDraft> buildUndoDrafts({
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
        },
      ),
  ];
}
