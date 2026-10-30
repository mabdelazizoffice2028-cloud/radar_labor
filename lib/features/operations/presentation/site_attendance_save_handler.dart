import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_conflict_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_background_sync.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_confirm_sync_dialog.dart';

final class SiteAttendanceSaveHandler {
  static Future<void> handleSave({
    required BuildContext context, required WidgetRef ref, required bool arabic,
    ActorContext? actor, ScopeSnapshot? scope,
  }) async {
    final notifier = ref.read(siteAttendanceNotifierProvider.notifier);
    final state = ref.read(siteAttendanceNotifierProvider);
    try {
      final prepared = await notifier.prepareSave();
      if (prepared == null || !context.mounted) return;
      var resolutions = <String, ConflictResolutionChoice>{};
      if (prepared.conflicts.isNotEmpty) {
        final res = await AttendanceConflictDialog.show(
          context: context, conflicts: prepared.conflicts,
          currentTeamName: prepared.team.displayName(arabic: arabic),
          arabic: arabic, currentDate: prepared.date,
        );
        if (res == null || !context.mounted) return;
        resolutions = res;
      }
      final isFriday = isFridayBusinessDate(prepared.date);
      final countSummary = isFriday
          ? OperationsStrings.fridaySaveConfirm(arabic, state.presentCount)
          : OperationsStrings.presentCountLabel(arabic, state.presentCount);
      final diffLine = prepared.diff.hasChanges ? prepared.diff.totalLine(arabic) : null;
      final presentWorkers = state.rows.where((r) => r.isPresent).map((r) => r.worker).toList();
      final confirmed = await OperationConfirmSyncDialog.show(
        context: context, title: OperationsStrings.confirmSiteAttendanceTitle(arabic),
        entityName: prepared.team.displayName(arabic: arabic), date: prepared.date,
        countSummaryText: countSummary, selectedWorkers: presentWorkers,
        emptySelectionText: OperationsStrings.zeroWorkersConfirmation(arabic),
        arabic: arabic, diffLine: diffLine,
      );
      if (confirmed != true || !context.mounted) return;
      final result = await notifier.confirmSave(prepared: prepared, resolutions: resolutions);
      if (result == null || !context.mounted) return;
      await Clipboard.setData(ClipboardData(text: result.summary.messageText));
      triggerBackgroundSync(ref, actor: actor, scope: scope);
      await FieldHaptics.success();
      if (!context.mounted) return;
      AppSnackBar.showSuccess(
        context, message: OperationsStrings.teamSavedLocally(arabic),
        duration: OperationsConstants.undoWindow,
        action: SnackBarAction(
          label: OperationsStrings.undoAction(arabic),
          onPressed: () => unawaited(notifier.undoLastSave()),
        ),
      );
      if (context.mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
    } on OperationException catch (e) {
      await FieldHaptics.error();
      if (context.mounted) AppSnackBar.showError(context, message: OperationFailureMessage.of(e.failure, arabic));
    } on Object catch (e) {
      await FieldHaptics.error();
      debugPrint('Site attendance save error: $e');
      if (context.mounted) AppSnackBar.showError(context, message: OperationsStrings.errSaveFailed(arabic));
    }
  }
}
