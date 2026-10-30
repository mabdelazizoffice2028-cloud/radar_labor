import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/presentation/state/team_setup_notifier.dart';

Future<void> saveTeamEdit({
  required BuildContext context,
  required WidgetRef ref,
  required ActorContext actor,
  required ScopeSnapshot scope,
  required String teamId,
  required bool arabic,
}) async {
  final notifier = ref.read(teamSetupNotifierProvider.notifier);
  final ok = await notifier.submitEditTeam(
    actor: actor,
    scope: scope,
    teamId: teamId,
  );
  if (!context.mounted) return;
  if (ok) {
    await FieldHaptics.success();
    if (!context.mounted) return;
    AppSnackBar.showSuccess(
      context,
      message: OperationsStrings.teamMembersSaved(arabic),
    );
    Navigator.pop(context, true);
    return;
  }
  final failure = ref.read(teamSetupNotifierProvider).failure;
  if (failure != null) {
    await FieldHaptics.error();
    if (!context.mounted) return;
    AppSnackBar.showError(
      context,
      message: OperationFailureMessage.of(failure, arabic),
    );
  }
}
