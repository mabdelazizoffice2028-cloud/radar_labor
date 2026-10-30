import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_check_no_absences_handler.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_check_save_handler.dart';

final class HousingCheckDialogHelper {
  static Future<void> handleNoAbsences({
    required BuildContext context,
    required WidgetRef ref,
    required OperationsController controller,
    required HousingCheckNotifier notifier,
    required HousingCheckState state,
    required bool arabic,
    ActorContext? actor,
    ScopeSnapshot? scope,
  }) => handleHousingNoAbsences(
    context: context,
    ref: ref,
    controller: controller,
    notifier: notifier,
    state: state,
    arabic: arabic,
    actor: actor,
    scope: scope,
  );

  static Future<void> handleSave({
    required BuildContext context,
    required WidgetRef ref,
    required OperationsController controller,
    required HousingCheckNotifier notifier,
    required HousingCheckState state,
    required bool arabic,
    ActorContext? actor,
    ScopeSnapshot? scope,
  }) => handleHousingSave(
    context: context,
    ref: ref,
    controller: controller,
    notifier: notifier,
    state: state,
    arabic: arabic,
    actor: actor,
    scope: scope,
  );
}
