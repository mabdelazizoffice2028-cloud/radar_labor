import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';

final class TeamWizardConfirmWorkersList extends StatelessWidget {
  const TeamWizardConfirmWorkersList({
    required this.selectedWorkers,
    required this.arabic,
    super.key,
  });

  final List<SelectableWorker> selectedWorkers;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    if (selectedWorkers.isEmpty) {
      return Center(child: Text(OperationsStrings.workersSelected(arabic, 0)));
    }
    return ListView.builder(
      itemCount: selectedWorkers.length,
      itemBuilder: (context, index) {
        final worker = selectedWorkers[index];
        return ListTile(
          leading: const Icon(Icons.check_circle, color: AppTokens.statusOnSite),
          title: Text(worker.displayName(arabic: arabic)),
          subtitle: Text('${OperationsStrings.codeLabel(arabic)}: ${worker.code}'),
        );
      },
    );
  }
}
