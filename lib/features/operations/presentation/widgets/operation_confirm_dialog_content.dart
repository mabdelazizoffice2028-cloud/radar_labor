import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_confirm_dialog_workers_list.dart';

class OperationConfirmDialogContent extends StatelessWidget {
  const OperationConfirmDialogContent({
    required this.countSummaryText,
    required this.selectedWorkers,
    required this.emptySelectionText,
    required this.arabic,
    this.diffLine,
    super.key,
  });

  final String countSummaryText;
  final List<WorkerOption> selectedWorkers;
  final String emptySelectionText;
  final bool arabic;
  final String? diffLine;

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
        if (diffLine != null && diffLine!.isNotEmpty) ...[
          const SizedBox(height: AppTokens.space8),
          Text(
            diffLine!,
            style: const TextStyle(fontSize: 12, color: AppTokens.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppTokens.space12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: OperationConfirmDialogWorkersList(
            selectedWorkers: selectedWorkers,
            emptySelectionText: emptySelectionText,
            arabic: arabic,
          ),
        ),
      ],
    );
  }
}
