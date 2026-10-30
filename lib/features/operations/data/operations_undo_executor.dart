import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';

final class OperationsUndoExecutor {
  const OperationsUndoExecutor._();

  static Future<void> execute(
    EventRepository events,
    LedgerUndoPlan plan, {
    required String actorUserId,
  }) async {
    if (plan.entries.isEmpty) return;
    await events.appendBatch([
      for (final e in plan.entries)
        EventDraft(
          type: e.key.type,
          action: e.restoreAction,
          businessDate: plan.businessDate,
          employeeUid: e.key.employeeUid,
          teamId: e.key.teamId,
          housingId: e.key.housingId,
          userId: actorUserId,
          payload: {
            if (e.key.type == EventType.resolution &&
                e.resolutionKind != null)
              'kind': e.resolutionKind!.key,
          },
        ),
    ]);
  }
}
