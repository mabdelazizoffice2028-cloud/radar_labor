import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

class OperationConfirmDialogContent extends StatelessWidget {
  const OperationConfirmDialogContent({
    required this.countSummaryText,
    required this.selectedWorkers,
    required this.emptySelectionText,
    required this.arabic,
    super.key,
  });

  final String countSummaryText;
  final List<WorkerOption> selectedWorkers;
  final String emptySelectionText;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space12,
            vertical: AppTokens.space8,
          ),
          decoration: BoxDecoration(
            color: AppTokens.statusUnknownSoft,
            borderRadius: BorderRadius.circular(AppTokens.radius12),
          ),
          child: Text(
            countSummaryText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTokens.statusUnknown,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: selectedWorkers.isEmpty
              ? Center(
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
                )
              : ListView.builder(
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
                ),
        ),
      ],
    );
  }
}
