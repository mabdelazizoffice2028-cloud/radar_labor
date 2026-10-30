import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/features/operations/domain/housing_draft_store.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/operations_store.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_loader.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

final class HousingCheckSaver {
  const HousingCheckSaver({required this.store, required this.draftStore, required this.events});
  final OperationsStore store;
  final HousingDraftStore draftStore;
  final EventRepository events;

  static const defaultHousing = EntityOption(
    id: HousingConstants.defaultHousingId,
    nameAr: HousingConstants.defaultHousingNameAr,
    nameEn: HousingConstants.defaultHousingName,
  );

  Future<HousingCheckState> load(HousingCheckState cur, bool ar) async {
    try {
      final res = await HousingCheckLoader(store: store, draftStore: draftStore, events: events).load(housing: defaultHousing, date: cur.selectedDate);
      return cur.copyWith(isLoading: false, rows: res.rows, hasSavedRecordToday: res.hasSaved, hasDraftSaved: res.hasDraft);
    } on Exception catch (e) {
      return cur.copyWith(isLoading: false, errorMessage: _msg(e, ar));
    }
  }

  Future<bool> flushDraft(HousingCheckState state) async {
    if (!state.hasUnsavedChanges) return true;
    try {
      await draftStore.writeDraft(
        housingId: defaultHousing.id, date: state.selectedDate,
        reviewedWorkerIds: state.rows.map((r) => r.worker.id), absentWorkerIds: state.absentWorkerIds,
      );
      return true;
    } on Exception {
      return false;
    }
  }

  Future<(HousingCheckState, HousingCheckUndo?)> confirm({
    required OperationsController controller, required PreparedHousingCheck check, required HousingCheckState cur, required bool ar,
  }) async {
    try {
      final undo = await controller.saveHousingCheck(check);
      await draftStore.deleteDraft(housingId: defaultHousing.id, date: check.date);
      return (cur.copyWith(isSaving: false, lastUndo: undo, hasDraftSaved: false, hasSavedRecordToday: true), undo);
    } on Exception catch (e) {
      return (cur.copyWith(isSaving: false, errorMessage: _msg(e, ar)), null);
    }
  }

  Future<(HousingCheckState, bool)> undo({
    required OperationsController controller, required HousingCheckUndo undo, required HousingCheckState cur, required bool ar,
  }) async {
    try {
      await controller.undoHousingCheck(undo);
      return (cur.copyWith(clearUndo: true), true);
    } on Exception catch (e) {
      return (cur.copyWith(errorMessage: _msg(e, ar)), false);
    }
  }

  static String _msg(Exception e, bool ar) => e is OperationException ? OperationFailureMessage.of(e.failure, ar) : OperationFailureMessage.of(const SaveFailed(), ar);
}
