import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';

/// Step 3 of Team Setup Wizard: Review sorted workers and confirm save (PRD §7.2).
final class TeamWizardConfirmStep extends StatelessWidget {
  const TeamWizardConfirmStep({
    required this.arabic,
    required this.teamNameAr,
    required this.teamNameEn,
    required this.selectedWorkers,
    required this.isSaving,
    required this.onBack,
    required this.onConfirm,
    super.key,
  });

  final bool arabic;
  final String teamNameAr;
  final String teamNameEn;
  final List<SelectableWorker> selectedWorkers;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppTokens.space16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          OperationsStrings.wizardStepOf(arabic, 3, 3),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTokens.space8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.groups_2_outlined),
            title: Text(teamNameAr),
            subtitle: teamNameEn.trim().isEmpty ? null : Text(teamNameEn),
            trailing: Text(
              OperationsStrings.workersSelected(arabic, selectedWorkers.length),
            ),
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        Text(
          OperationsStrings.confirmWorkersTitle(arabic),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppTokens.space8),
        Expanded(
          child: selectedWorkers.isEmpty
              ? Center(
                  child: Text(OperationsStrings.workersSelected(arabic, 0)),
                )
              : ListView.builder(
                  itemCount: selectedWorkers.length,
                  itemBuilder: (context, index) {
                    final worker = selectedWorkers[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.check_circle,
                        color: AppTokens.statusOnSite,
                      ),
                      title: Text(worker.displayName(arabic: arabic)),
                      subtitle: Text(
                        '${OperationsStrings.codeLabel(arabic)}: ${worker.code}',
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      AppTokens.minTouchTarget,
                    ),
                  ),
                  child: Text(OperationsStrings.wizardBack(arabic)),
                ),
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : onConfirm,
                  icon: const Icon(Icons.check),
                  label: Text(
                    isSaving
                        ? OperationsStrings.savingLabel(arabic)
                        : OperationsStrings.confirmAndSave(arabic),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      AppTokens.minTouchTarget,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
