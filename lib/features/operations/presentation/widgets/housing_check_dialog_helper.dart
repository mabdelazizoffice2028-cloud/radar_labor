import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_saver.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_background_sync.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_confirm_sync_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_whatsapp_dialog.dart';

final class HousingCheckDialogHelper {
  static Future<bool> _guard(BuildContext ctx, WidgetRef ref, ActorContext? a, ScopeSnapshot? s, String d, String td, bool ar) async {
    if (a == null || s == null) return true;
    try {
      final hour = await ref.read(housingLockoutHourProvider.future);
      ScopeGuard.guardHousingRecord(actor: a, scope: s, housingId: HousingCheckSaver.defaultHousing.id, date: d, todayBusinessDate: td, nowUtc: ref.read(clockProvider).nowUtc(), lockoutHour: hour);
      return true;
    } on OperationException catch (e) {
      if (ctx.mounted) AppSnackBar.show(ctx, message: OperationFailureMessage.of(e.failure, ar));
      return false;
    }
  }

  static Future<void> handleNoAbsences({
    required BuildContext context, required WidgetRef ref, required OperationsController controller,
    required HousingCheckNotifier notifier, required HousingCheckState state, required bool arabic,
    ActorContext? actor, ScopeSnapshot? scope,
  }) async {
    if (!await _guard(context, ref, actor, scope, state.selectedDate, state.todayDate, arabic) || !context.mounted) return;
    try {
      final undo = await notifier.submitNoAbsencesToday(controller: controller, arabic: arabic);
      if (undo != null && context.mounted) AppSnackBar.show(context, message: OperationsStrings.noAbsencesConfirmed(arabic));
    } on OperationException catch (e) {
      if (context.mounted) AppSnackBar.show(context, message: OperationFailureMessage.of(e.failure, arabic));
    } on Object catch (e) {
      debugPrint('Housing check no-absences error (${e.runtimeType}).');
      if (context.mounted) AppSnackBar.show(context, message: OperationsStrings.errSaveFailed(arabic));
    }
  }

  static Future<void> handleSave({
    required BuildContext context, required WidgetRef ref, required OperationsController controller,
    required HousingCheckNotifier notifier, required HousingCheckState state, required bool arabic,
    ActorContext? actor, ScopeSnapshot? scope,
  }) async {
    if (!await _guard(context, ref, actor, scope, state.selectedDate, state.todayDate, arabic) || !context.mounted) return;
    try {
      final check = await notifier.prepareSave(controller: controller, arabic: arabic);
      if (check == null || !context.mounted) return;
      final absent = state.rows.where((r) => r.isAbsent).map((r) => r.worker).toList(growable: false);
      final ok = await OperationConfirmSyncDialog.show(
        context: context, title: OperationsStrings.confirmHousingCheckTitle(arabic),
        entityName: HousingCheckSaver.defaultHousing.displayName(arabic: arabic), date: state.selectedDate,
        countSummaryText: OperationsStrings.markedAbsentCount(arabic, state.absentCount),
        selectedWorkers: absent, emptySelectionText: OperationsStrings.noAbsencesSaveCheck(arabic), arabic: arabic,
      );
      if (ok != true || !context.mounted) return;
      final undo = await notifier.confirmSave(controller: controller, check: check);
      if (undo == null || !context.mounted) return;

      AppSnackBar.show(context, message: OperationsStrings.housingSavedLocally(arabic), duration: OperationsConstants.undoWindow,
        action: SnackBarAction(label: OperationsStrings.undoAction(arabic), onPressed: () => unawaited(notifier.undoLastSave(controller: controller))));
      triggerBackgroundSync(ref, actor: actor, scope: scope);
      if (!context.mounted) return;
      await showOperationWhatsappDialog(context: context, messageText: check.summary.messageText, arabic: arabic);
      if (context.mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
    } on OperationException catch (e) {
      if (context.mounted) AppSnackBar.show(context, message: OperationFailureMessage.of(e.failure, arabic));
    } on Object catch (e) {
      debugPrint('Housing check save error (${e.runtimeType}).');
      if (context.mounted) AppSnackBar.show(context, message: OperationsStrings.errSaveFailed(arabic));
    }
  }
}
