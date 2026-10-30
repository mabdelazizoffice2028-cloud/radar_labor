import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_saver.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

final class HousingCheckNotifier extends Notifier<HousingCheckState> {
  Timer? _draftTimer;
  HousingCheckSaver get _saver => HousingCheckSaver(
    store: ref.read(operationsRepositoryProvider),
    draftStore: ref.read(housingDraftStoreProvider),
    events: ref.read(eventRepositoryProvider),
  );
  bool get _isAr => ref.read(appLocaleProvider) == 'ar';

  @override
  HousingCheckState build() {
    ref.onDispose(() => _draftTimer?.cancel());
    final today = businessDateFor(ref.read(clockProvider).nowUtc());
    return HousingCheckState(selectedDate: today, todayDate: today, selectedHousing: HousingCheckSaver.defaultHousing);
  }

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  Future<void> loadDefaultHousing() async {
    state = state.copyWith(isLoading: true, clearError: true);
    state = await _saver.load(state, _isAr);
  }

  void toggleAbsent(String id) {
    state = state.copyWith(
      rows: [for (final r in state.rows) if (r.worker.id == id) r.copyWith(reviewState: r.isAbsent ? HousingReviewState.reviewedPresent : HousingReviewState.absent) else r],
      hasUnsavedChanges: true,
    );
    _draftTimer?.cancel();
    _draftTimer = Timer(OperationsConstants.draftDebounce, () => unawaited(flushDraft()));
  }

  Future<bool> flushDraft() async {
    _draftTimer?.cancel();
    final ok = await _saver.flushDraft(state);
    if (ok) state = state.copyWith(hasUnsavedChanges: false, hasDraftSaved: true);
    return ok;
  }

  Future<PreparedHousingCheck?> prepareSave({required OperationsController controller, required bool arabic}) async {
    await flushDraft();
    return controller.prepareHousingCheck(housing: HousingCheckSaver.defaultHousing, absentIds: state.absentWorkerIds, arabic: arabic);
  }

  Future<HousingCheckUndo?> confirmSave({required OperationsController controller, required PreparedHousingCheck check}) async {
    _draftTimer?.cancel();
    state = state.copyWith(isSaving: true, clearError: true);
    final (next, undo) = await _saver.confirm(controller: controller, check: check, cur: state, ar: _isAr);
    state = next;
    if (undo != null) await loadDefaultHousing();
    return undo;
  }

  Future<bool> undoLastSave({required OperationsController controller}) async {
    final undo = state.lastUndo;
    if (undo == null) return false;
    final (next, ok) = await _saver.undo(controller: controller, undo: undo, cur: state, ar: _isAr);
    state = next;
    if (ok) await loadDefaultHousing();
    return ok;
  }

  Future<HousingCheckUndo?> submitNoAbsencesToday({required OperationsController controller, required bool arabic}) async {
    final check = await controller.prepareHousingCheck(housing: HousingCheckSaver.defaultHousing, absentIds: const {}, arabic: arabic);
    return confirmSave(controller: controller, check: check);
  }
}

final housingCheckNotifierProvider = NotifierProvider<HousingCheckNotifier, HousingCheckState>(HousingCheckNotifier.new);
