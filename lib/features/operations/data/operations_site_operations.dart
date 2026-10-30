import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

final class OperationsSiteOperations {
  const OperationsSiteOperations(this.events);
  final EventRepository events;

  Future<SiteAttendanceUndo> save({
    required String date,
    required EntityOption team,
    required Set<String> presentIds,
    required String actorUserId,
  }) async {
    final previous = await events.readBusinessDate(date);
    final ledger = AttendanceLedger(previous);
    final prevPresent = ledger.presentWorkerIdsForTeam(team.id);
    final wasSubmitted = ledger.isSiteSubmitted(team.id);
    final ids = {...prevPresent, ...presentIds};
    await events.appendBatch([
      for (final id in ids)
        EventDraft(
          type: EventType.sitePresent,
          action: presentIds.contains(id) ? EventAction.set : EventAction.clear,
          businessDate: date,
          employeeUid: id,
          teamId: team.id,
          userId: actorUserId,
        ),
      EventDraft(
        type: EventType.siteSubmitted,
        action: EventAction.set,
        businessDate: date,
        teamId: team.id,
        userId: actorUserId,
        payload: {'presentCount': presentIds.length},
      ),
    ]);
    return SiteAttendanceUndo(
      date: date,
      teamId: team.id,
      previousPresent: Set.unmodifiable(prevPresent),
      currentPresent: Set.unmodifiable(presentIds),
      wasSubmitted: wasSubmitted,
    );
  }

  Future<void> undo(SiteAttendanceUndo undo, {required String actorUserId}) =>
      events.appendBatch([
        for (final id in {...undo.previousPresent, ...undo.currentPresent})
          EventDraft(
            type: EventType.sitePresent,
            action: undo.previousPresent.contains(id) ? EventAction.set : EventAction.clear,
            businessDate: undo.date,
            employeeUid: id,
            teamId: undo.teamId,
            userId: actorUserId,
          ),
        EventDraft(
          type: EventType.siteSubmitted,
          action: undo.wasSubmitted ? EventAction.set : EventAction.clear,
          businessDate: undo.date,
          teamId: undo.teamId,
          userId: actorUserId,
        ),
      ]);
}
