import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/presentation/state/team_setup_notifier.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_confirm_step.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_name_step.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_workers_step.dart';

final class TeamWizardStepBody extends ConsumerWidget {
  const TeamWizardStepBody({
    required this.arabic,
    required this.onConfirm,
    super.key,
  });

  final bool arabic;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamSetupNotifierProvider);
    final notifier = ref.read(teamSetupNotifierProvider.notifier);
    final ar = arabic;

    return switch (state.step) {
      1 => TeamWizardNameStep(
        arabic: ar,
        nameAr: state.nameAr,
        nameEn: state.nameEn,
        onNameArChanged: notifier.setNameAr,
        onNameEnChanged: notifier.setNameEn,
        onNext: () {
          if (!notifier.advanceFromNameStep()) {
            final failure = ref.read(teamSetupNotifierProvider).failure;
            if (failure != null) {
              FieldHaptics.error();
              AppSnackBar.showError(
                context,
                message: OperationFailureMessage.of(failure, ar),
              );
            }
          }
        },
      ),
      2 => TeamWizardWorkersStep(
        arabic: ar,
        stepHeader: OperationsStrings.wizardStepOf(ar, 2, 3),
        workers: state.visibleWorkers,
        selectedIds: state.selectedWorkerIds,
        isSelectable: state.isWorkerSelectable,
        onSearchChanged: notifier.setSearchQuery,
        onToggleWorker: notifier.toggleWorker,
        onSelectAllVisible: notifier.selectAllVisible,
        onClearAllVisible: notifier.clearAllVisible,
        onBack: () => notifier.goToStep(1),
        onNext: () => notifier.goToStep(3),
        primaryActionLabel: OperationsStrings.wizardNext(ar),
      ),
      _ => TeamWizardConfirmStep(
        arabic: ar,
        teamNameAr: state.nameAr,
        teamNameEn: state.nameEn,
        selectedWorkers: state.selectedWorkersSorted,
        isSaving: state.isSaving,
        onBack: () => notifier.goToStep(2),
        onConfirm: onConfirm,
      ),
    };
  }
}
