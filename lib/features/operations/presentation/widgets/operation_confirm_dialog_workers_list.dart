import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

final class OperationConfirmDialogWorkersList extends StatelessWidget {
  const OperationConfirmDialogWorkersList({
    required this.selectedWorkers,
    required this.emptySelectionText,
    required this.arabic,
    super.key,
  });

  final List<WorkerOption> selectedWorkers;
  final String emptySelectionText;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    if (selectedWorkers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space16),
          child: Text(
            emptySelectionText,
            style: const TextStyle(
              color: AppTokens.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: selectedWorkers.length,
      itemBuilder: (context, index) {
        final w = selectedWorkers[index];
        final name = w.displayName(arabic: arabic);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            '${index + 1}. $name (${w.code})',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
    );
  }
}
