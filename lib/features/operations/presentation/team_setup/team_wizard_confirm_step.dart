import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_confirm_workers_list.dart';

final class TeamWizardConfirmStep extends StatelessWidget {
  const TeamWizardConfirmStep({
    required this.arabic, required this.teamNameAr, required this.teamNameEn,
    required this.selectedWorkers, required this.isSaving,
    required this.onBack, required this.onConfirm, super.key,
  });

  final bool arabic;
  final String teamNameAr;
  final String teamNameEn;
  final List<SelectableWorker> selectedWorkers;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final displayName = teamNameEn.trim().isNotEmpty ? teamNameEn : teamNameAr;
    return Padding(
      padding: const EdgeInsets.all(AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(OperationsStrings.wizardStepOf(arabic, 3, 3), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppTokens.space8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.groups_2_outlined),
              title: Text(displayName),
              trailing: Text(OperationsStrings.workersSelected(arabic, selectedWorkers.length)),
            ),
          ),
          const SizedBox(height: AppTokens.space12),
          Text(OperationsStrings.confirmWorkersTitle(arabic), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppTokens.space8),
          Expanded(
            child: TeamWizardConfirmWorkersList(selectedWorkers: selectedWorkers, arabic: arabic),
          ),
          SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSaving ? null : onBack,
                    child: Text(OperationsStrings.wizardBack(arabic)),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: FilledButton(
                    onPressed: isSaving ? null : onConfirm,
                    child: isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(OperationsStrings.confirmAndSave(arabic)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
