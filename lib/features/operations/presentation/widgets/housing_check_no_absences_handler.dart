import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_saver.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_check_guard.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_background_sync.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_confirm_sync_dialog.dart';

Future<void> handleHousingNoAbsences({
  required BuildContext context,
  required WidgetRef ref,
  required OperationsController controller,
  required HousingCheckNotifier notifier,
  required HousingCheckState state,
  required bool arabic,
  ActorContext? actor,
  ScopeSnapshot? scope,
}) async {
  final guarded = await guardHousingAction(
    context: context,
    ref: ref,
    actor: actor,
    scope: scope,
    selectedDate: state.selectedDate,
    todayDate: state.todayDate,
    arabic: arabic,
  );
  if (!guarded || !context.mounted) return;
  try {
    final check = await controller.prepareHousingCheck(
      housing: HousingCheckSaver.defaultHousing,
      absentIds: const {},
      arabic: arabic,
    );
    if (!context.mounted) return;
    final ok = await OperationConfirmSyncDialog.show(
      context: context,
      title: OperationsStrings.confirmHousingCheckTitle(arabic),
      entityName: HousingCheckSaver.defaultHousing.displayName(arabic: arabic),
      date: state.selectedDate,
      countSummaryText: OperationsStrings.markedAbsentCount(arabic, 0),
      selectedWorkers: const [],
      emptySelectionText: OperationsStrings.noAbsencesSaveCheck(arabic),
      arabic: arabic,
    );
    if (ok != true || !context.mounted) return;
    final undo = await notifier.confirmSave(controller: controller, check: check);
    if (undo == null || !context.mounted) return;
    await Clipboard.setData(ClipboardData(text: check.summary.messageText));
    triggerBackgroundSync(ref, actor: actor, scope: scope);
    await FieldHaptics.success();
    if (!context.mounted) return;
    AppSnackBar.showSuccess(
      context,
      message: OperationsStrings.housingSavedLocally(arabic),
      duration: OperationsConstants.undoWindow,
      action: SnackBarAction(
        label: OperationsStrings.undoAction(arabic),
        onPressed: () => unawaited(notifier.undoLastSave(controller: controller)),
      ),
    );
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  } on OperationException catch (e) {
    await FieldHaptics.error();
    if (context.mounted) {
      AppSnackBar.showError(context, message: OperationFailureMessage.of(e.failure, arabic));
    }
  } on Object catch (e) {
    await FieldHaptics.error();
    debugPrint('Housing check no-absences error: $e');
    if (context.mounted) {
      AppSnackBar.showError(context, message: OperationsStrings.errSaveFailed(arabic));
    }
  }
}
