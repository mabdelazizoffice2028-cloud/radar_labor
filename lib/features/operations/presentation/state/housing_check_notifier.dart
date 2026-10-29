import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/housing_draft_store.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/operations_store.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

/// Riverpod notifier managing binary housing absence review, drafts, and persistence (Phase 4).
final class HousingCheckNotifier extends Notifier<HousingCheckState> {
  Timer? _draftTimer;

  @override
  HousingCheckState build() {
    ref.onDispose(() => _draftTimer?.cancel());
    final clock = ref.read(clockProvider);
    final today = businessDateFor(clock.nowUtc());
    return HousingCheckState(selectedDate: today, todayDate: today);
  }

  Clock get _clock => ref.read(clockProvider);
  bool get _isArabic => ref.read(appLocaleProvider) == 'ar';

  /// Maps any failure to a localized message; never exposes technical text.
  String _failureMessage(Exception error) {
    if (error is OperationException) {
      return OperationFailureMessage.of(error.failure, _isArabic);
    }
    debugPrint('Housing check failed (${error.runtimeType}).');
    return OperationFailureMessage.of(const SaveFailed(), _isArabic);
  }

  OperationsStore get _opsStore => ref.read(operationsRepositoryProvider);
  HousingDraftStore get _draftStore => ref.read(housingDraftStoreProvider);
  EventRepository get _eventRepo => ref.read(eventRepositoryProvider);

  Future<void> ensureInitialHousing(List<EntityOption> housings) async {
    if (housings.isEmpty) {
      if (state.selectedHousing != null) {
        state = state.copyWith(clearSelectedHousing: true, rows: const []);
      }
      return;
    }
    final cur = state.selectedHousing;
    if (cur != null && housings.any((h) => h.id == cur.id)) {
      if (state.rows.isEmpty && !state.isLoading) {
        await _load(housing: cur, date: state.selectedDate);
      }
      return;
    }
    await selectHousing(housings.first);
  }

  Future<void> selectHousing(EntityOption? housing) async {
    await flushDraft();
    if (housing != null) {
      return _load(housing: housing, date: state.selectedDate);
    }
    state = state.copyWith(
      clearSelectedHousing: true,
      rows: const [],
      clearError: true,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleAbsent(String workerId) {
    final updated = [
      for (final r in state.rows)
        if (r.worker.id == workerId)
          r.copyWith(
            reviewState: r.reviewState == HousingReviewState.absent
                ? HousingReviewState.reviewedPresent
                : HousingReviewState.absent,
          )
        else
          r,
    ];
    _updateRows(updated);
  }

  void setReviewState(String workerId, HousingReviewState newState) {
    final updated = [
      for (final r in state.rows)
        if (r.worker.id == workerId) r.copyWith(reviewState: newState) else r,
    ];
    _updateRows(updated);
  }

  void markRemainingAsReviewed() {
    final updated = [
      for (final r in state.rows)
        if (r.reviewState == HousingReviewState.unreviewed)
          r.copyWith(reviewState: HousingReviewState.reviewedPresent)
        else
          r,
    ];
    _updateRows(updated);
  }

  void markAllReviewed() {
    final updated = [
      for (final r in state.rows)
        r.copyWith(reviewState: HousingReviewState.reviewedPresent),
    ];
    _updateRows(updated);
  }

  void clearAllReviews() {
    final updated = [
      for (final r in state.rows)
        r.copyWith(reviewState: HousingReviewState.unreviewed),
    ];
    _updateRows(updated);
  }

  void _updateRows(List<HousingWorkerRow> rows) {
    state = state.copyWith(
      rows: List.unmodifiable(rows),
      clearError: true,
      hasUnsavedChanges: true,
    );
    _draftTimer?.cancel();
    _draftTimer = Timer(
      OperationsConstants.draftDebounce,
      () => unawaited(flushDraft()),
    );
  }

  /// Persists pending edits now. Returns false when the draft write failed.
  Future<bool> flushDraft() async {
    _draftTimer?.cancel();
    final housing = state.selectedHousing;
    if (housing == null || state.rows.isEmpty || state.hasSavedRecordToday) {
      return true;
    }
    if (!state.hasUnsavedChanges) return true;
    try {
      await _draftStore.writeDraft(
        housingId: housing.id,
        date: state.selectedDate,
        reviewedWorkerIds: state.reviewedWorkerIds,
        absentWorkerIds: state.absentWorkerIds,
      );
      state = state.copyWith(hasDraftSaved: true, hasUnsavedChanges: false);
      return true;
    } on Exception catch (error) {
      state = state.copyWith(errorMessage: _failureMessage(error));
      return false;
    }
  }

  Future<void> _load({
    required EntityOption housing,
    required String date,
  }) async {
    final today = businessDateFor(_clock.nowUtc());
    state = state.copyWith(
      selectedHousing: housing,
      selectedDate: date,
      todayDate: today,
      isPastDate: date.compareTo(today) < 0,
      isLoading: true,
      clearError: true,
      hasUnsavedChanges: false,
    );

    try {
      final workers = await _opsStore.watchHousingWorkers(housing.id).first;
      final ledger = AttendanceLedger(await _eventRepo.readBusinessDate(date));
      final saved = ledger.isHousingChecked(housing.id);
      final draft = saved
          ? null
          : await _draftStore.readDraft(housingId: housing.id, date: date);
      final absent = saved
          ? ledger.absentWorkerIdsForHousing(housing.id)
          : draft?.absentWorkerIds.toSet();
      state = state.copyWith(
        isLoading: false,
        rows: List.unmodifiable([
          for (final w in workers)
            HousingWorkerRow(
              worker: w,
              reviewState: (absent?.contains(w.id) ?? false)
                  ? HousingReviewState.absent
                  : HousingReviewState.reviewedPresent,
            ),
        ]),
        hasSavedRecordToday: saved,
        hasDraftSaved: draft != null,
      );
    } on Exception catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _failureMessage(error),
      );
    }
  }

  Future<PreparedHousingCheck?> prepareSave({
    required OperationsController controller,
    required bool arabic,
  }) async {
    await flushDraft();
    final housing = state.selectedHousing;
    if (housing == null) return null;
    return controller.prepareHousingCheck(
      housing: housing,
      absentIds: state.absentWorkerIds,
      arabic: arabic,
    );
  }

  Future<HousingCheckUndo?> confirmSave({
    required OperationsController controller,
    required PreparedHousingCheck check,
  }) async {
    _draftTimer?.cancel();
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final undo = await controller.saveHousingCheck(check);
      await _draftStore.deleteDraft(
        housingId: check.housing.id,
        date: check.date,
      );
      await _load(housing: check.housing, date: check.date);
      state = state.copyWith(
        isSaving: false,
        lastUndo: undo,
        hasDraftSaved: false,
        hasSavedRecordToday: true,
      );
      return undo;
    } on Exception catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _failureMessage(error),
      );
      return null;
    }
  }

  Future<bool> undoLastSave({required OperationsController controller}) async {
    final undo = state.lastUndo;
    if (undo == null) return false;
    try {
      await controller.undoHousingCheck(undo);
      state = state.copyWith(clearUndo: true);
      if (state.selectedHousing != null) {
        await _load(housing: state.selectedHousing!, date: state.selectedDate);
      }
      return true;
    } on Exception catch (error) {
      state = state.copyWith(errorMessage: _failureMessage(error));
      return false;
    }
  }
}

final housingCheckNotifierProvider =
    NotifierProvider<HousingCheckNotifier, HousingCheckState>(
      HousingCheckNotifier.new,
    );
