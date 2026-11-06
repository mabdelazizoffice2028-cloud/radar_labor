import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/housing_draft_store.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/operations_store.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';

final class HousingCheckLoader {
  const HousingCheckLoader({required this.store, required this.draftStore, required this.events});
  final OperationsStore store;
  final HousingDraftStore draftStore;
  final EventRepository events;

  Future<({List<HousingWorkerRow> rows, bool hasSaved, bool hasDraft})> load({
    required EntityOption housing, required String date,
  }) async {
    final workers = await store.getHousingWorkers(housing.id, date: date);
    final ledger = AttendanceLedger(await events.readBusinessDate(date));
    final saved = ledger.isHousingChecked(housing.id);
    final draft = await draftStore.readDraft(housingId: housing.id, date: date);
    final absent = draft != null
        ? draft.absentWorkerIds.toSet()
        : (saved ? ledger.absentWorkerIdsForHousing(housing.id) : null);
    final reviewed = draft?.reviewedWorkerIds.toSet();

    final rows = List<HousingWorkerRow>.unmodifiable([
      for (final w in workers)
        HousingWorkerRow(
          worker: w,
          reviewState: (absent?.contains(w.id) ?? false)
              ? HousingReviewState.absent
              : (draft != null
                      ? (reviewed?.contains(w.id) ?? false)
                      : saved)
                  ? HousingReviewState.reviewedPresent
                  : HousingReviewState.unreviewed,
        ),
    ]);
    return (rows: rows, hasSaved: saved, hasDraft: draft != null);
  }
}
