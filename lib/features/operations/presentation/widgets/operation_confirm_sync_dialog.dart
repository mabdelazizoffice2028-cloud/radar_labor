import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

/// User decision for saving operations data locally vs uploading immediately.
enum ConfirmSaveAction { saveLocalOnly, saveAndSync }

/// Shared confirmation and explicit sync dialog for operations check-ins.
class OperationConfirmSyncDialog extends StatelessWidget {
  const OperationConfirmSyncDialog({
    required this.title,
    required this.entityName,
    required this.date,
    required this.countSummaryText,
    required this.selectedWorkers,
    required this.emptySelectionText,
    required this.arabic,
    super.key,
  });

  final String title;
  final String entityName;
  final String date;
  final String countSummaryText;
  final List<WorkerOption> selectedWorkers;
  final String emptySelectionText;
  final bool arabic;

  static Future<ConfirmSaveAction?> show({
    required BuildContext context,
    required String title,
    required String entityName,
    required String date,
    required String countSummaryText,
    required List<WorkerOption> selectedWorkers,
    required String emptySelectionText,
    required bool arabic,
  }) {
    return showDialog<ConfirmSaveAction>(
      context: context,
      builder: (_) => OperationConfirmSyncDialog(
        title: title,
        entityName: entityName,
        date: date,
        countSummaryText: countSummaryText,
        selectedWorkers: selectedWorkers,
        emptySelectionText: emptySelectionText,
        arabic: arabic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            '$entityName • $date',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppTokens.textSecondary),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
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
        ),
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(OperationsStrings.saveAndSyncNowAction(arabic)),
              onPressed: () =>
                  Navigator.of(context).pop(ConfirmSaveAction.saveAndSync),
            ),
            const SizedBox(height: AppTokens.space8),
            OutlinedButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: Text(OperationsStrings.saveLocallyOnlyAction(arabic)),
              onPressed: () =>
                  Navigator.of(context).pop(ConfirmSaveAction.saveLocalOnly),
            ),
            const SizedBox(height: AppTokens.space4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(OperationsStrings.reviewAction(arabic)),
            ),
          ],
        ),
      ],
    );
  }
}
