import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

final class OperationsHousingOperations {
  const OperationsHousingOperations(this.events);
  final EventRepository events;

  Future<HousingCheckUndo> save({
    required String date,
    required EntityOption housing,
    required Set<String> absentIds,
    required String actorUserId,
  }) async {
    final previous = await events.readBusinessDate(date);
    final ledger = AttendanceLedger(previous);
    final prevAbsences = ledger.absentWorkerIdsForHousing(housing.id);
    final wasChecked = ledger.isHousingChecked(housing.id);
    final ids = {...prevAbsences, ...absentIds};
    await events.appendBatch([
      EventDraft(
        type: EventType.housingCheck,
        action: EventAction.set,
        businessDate: date,
        housingId: housing.id,
        userId: actorUserId,
      ),
      for (final id in ids)
        EventDraft(
          type: EventType.housingAbsent,
          action: absentIds.contains(id) ? EventAction.set : EventAction.clear,
          businessDate: date,
          employeeUid: id,
          housingId: housing.id,
          userId: actorUserId,
        ),
    ]);
    return HousingCheckUndo(
      date: date,
      housingId: housing.id,
      previousAbsences: Set.unmodifiable(prevAbsences),
      currentAbsences: Set.unmodifiable(absentIds),
      wasChecked: wasChecked,
    );
  }

  Future<void> undo(HousingCheckUndo undo, {required String actorUserId}) =>
      events.appendBatch([
        EventDraft(
          type: EventType.housingCheck,
          action: undo.wasChecked ? EventAction.set : EventAction.clear,
          businessDate: undo.date,
          housingId: undo.housingId,
          userId: actorUserId,
        ),
        for (final id in {...undo.previousAbsences, ...undo.currentAbsences})
          EventDraft(
            type: EventType.housingAbsent,
            action: undo.previousAbsences.contains(id) ? EventAction.set : EventAction.clear,
            businessDate: undo.date,
            employeeUid: id,
            housingId: undo.housingId,
            userId: actorUserId,
          ),
      ]);
}
