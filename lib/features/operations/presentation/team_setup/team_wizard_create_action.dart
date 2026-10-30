import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/team_setup_notifier.dart';

Future<void> confirmAndCreateTeam({
  required BuildContext context,
  required WidgetRef ref,
  required ActorContext actor,
  required bool arabic,
  required bool embedded,
  ValueChanged<EntityOption>? onTeamCreated,
}) async {
  final notifier = ref.read(teamSetupNotifierProvider.notifier);
  final state = ref.read(teamSetupNotifierProvider);
  final ar = arabic;

  if (state.selectedWorkerIds.isEmpty) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(OperationsStrings.setupTeamWizardTitle(ar)),
        content: Text(OperationsStrings.confirmCreateEmptyTeam(ar)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel(ar)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(OperationsStrings.confirmAction(ar)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
  }

  final created = await notifier.submitCreateTeam(actor: actor);
  if (!context.mounted) return;
  if (created != null) {
    await FieldHaptics.success();
    if (!context.mounted) return;
    AppSnackBar.showSuccess(
      context,
      message: OperationsStrings.teamCreated(ar),
    );
    onTeamCreated?.call(created);
    if (!embedded && Navigator.canPop(context)) {
      Navigator.pop(context, created);
    }
    return;
  }

  final failure = ref.read(teamSetupNotifierProvider).failure;
  if (failure != null) {
    await FieldHaptics.error();
    if (!context.mounted) return;
    AppSnackBar.showError(
      context,
      message: OperationFailureMessage.of(failure, ar),
    );
  }
}
