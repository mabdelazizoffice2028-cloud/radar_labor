import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';

/// Debounced local draft persistence for site attendance.
///
/// A draft that is safely stored on the device is never treated as lost data;
/// [SiteAttendanceState.hasUnsavedChanges] stays true only while a write is
/// pending or after a write failed.
mixin SiteDraftPersistence on Notifier<SiteAttendanceState> {
  Timer? draftTimer;

  /// Marks edits as unsaved and schedules the debounced draft write.
  void scheduleDraftWrite() {
    state = state.copyWith(hasUnsavedChanges: true);
    draftTimer?.cancel();
    draftTimer = Timer(
      OperationsConstants.draftDebounce,
      () => unawaited(flushDraft()),
    );
  }

  /// Persists pending edits now. Returns false when the draft write failed.
  Future<bool> flushDraft() async {
    draftTimer?.cancel();
    if (!state.hasUnsavedChanges) return true;
    final team = state.selectedTeam;
    if (team == null) return true;
    try {
      await ref
          .read(attendanceDraftStoreProvider)
          .writeDraft(
            teamId: team.id,
            date: state.selectedDate,
            workerIds: state.selectedActiveWorkerIds,
          );
      state = state.copyWith(hasUnsavedChanges: false);
      return true;
    } on Exception catch (error) {
      debugPrint('Site draft write failed (${error.runtimeType}).');
      state = state.copyWith(
        errorMessage: OperationFailureMessage.of(
          const SaveFailed(),
          ref.read(appLocaleProvider) == 'ar',
        ),
      );
      return false;
    }
  }
}
