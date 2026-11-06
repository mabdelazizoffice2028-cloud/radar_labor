import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';

final class TeamWizardWorkerTile extends StatelessWidget {
  const TeamWizardWorkerTile({
    required this.worker,
    required this.selectable,
    required this.selected,
    required this.arabic,
    required this.onToggle,
    super.key,
  });

  final SelectableWorker worker;
  final bool selectable;
  final bool selected;
  final bool arabic;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final otherTeam = worker.assignedTeamName(arabic: arabic);
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space4,
      ),
      child: ListTile(
        enabled: selectable,
        minVerticalPadding: AppTokens.space12,
        onTap: selectable ? onToggle : null,
        leading: Icon(
          selected
              ? Icons.check_circle
              : (selectable ? Icons.radio_button_unchecked : Icons.lock_outline),
          color: selected ? AppTokens.statusOnSite : AppTokens.textSecondary,
        ),
        title: Text(worker.displayName(arabic: arabic)),
        subtitle: Text('${OperationsStrings.codeLabel(arabic)}: ${worker.code}'),
        trailing: !selectable && otherTeam != null
            ? Chip(
                label: Text(
                  OperationsStrings.workerAssignedElsewhere(arabic, otherTeam),
                ),
              )
            : Text(
                selected
                    ? OperationsStrings.workerSelectedState(arabic)
                    : OperationsStrings.workerUnselectedState(arabic),
              ),
      ),
    );
  }
}
