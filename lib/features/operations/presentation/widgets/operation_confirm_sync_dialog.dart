import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_confirm_dialog_actions.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_confirm_dialog_content.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_confirm_dialog_header.dart';

class OperationConfirmSyncDialog extends StatelessWidget {
  const OperationConfirmSyncDialog({
    required this.title, required this.entityName, required this.date,
    required this.countSummaryText, required this.selectedWorkers,
    required this.emptySelectionText, required this.arabic,
    this.diffLine, super.key,
  });

  final String title;
  final String entityName;
  final String date;
  final String countSummaryText;
  final List<WorkerOption> selectedWorkers;
  final String emptySelectionText;
  final bool arabic;
  final String? diffLine;

  static Future<bool?> show({
    required BuildContext context, required String title, required String entityName,
    required String date, required String countSummaryText,
    required List<WorkerOption> selectedWorkers, required String emptySelectionText,
    required bool arabic, String? diffLine,
  }) => showDialog<bool>(
    context: context,
    builder: (_) => OperationConfirmSyncDialog(
      title: title, entityName: entityName, date: date, countSummaryText: countSummaryText,
      selectedWorkers: selectedWorkers, emptySelectionText: emptySelectionText,
      arabic: arabic, diffLine: diffLine,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      title: OperationConfirmDialogHeader(
        title: title, entityName: entityName, date: date, arabic: arabic,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: OperationConfirmDialogContent(
          countSummaryText: countSummaryText, selectedWorkers: selectedWorkers,
          emptySelectionText: emptySelectionText, arabic: arabic, diffLine: diffLine,
        ),
      ),
      actions: [OperationConfirmDialogActions(arabic: arabic)],
    );
  }
}
