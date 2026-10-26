import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Sticky bottom bar with live selection count and 56dp Save button (PRD §8.1).
class AttendanceCounterBar extends StatelessWidget {
  const AttendanceCounterBar({
    required this.presentCount,
    required this.arabic,
    required this.enabled,
    required this.isSaving,
    required this.onSave,
    super.key,
  });

  final int presentCount;
  final bool arabic;
  final bool enabled;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space12),
      decoration: const BoxDecoration(
        color: AppTokens.surface,
        border: Border(top: BorderSide(color: AppTokens.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                OperationsStrings.workersSelected(arabic, presentCount),
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppTokens.space12),
            SizedBox(
              height: AppTokens.minTouchTarget,
              child: FilledButton.icon(
                onPressed: enabled && !isSaving ? onSave : null,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  isSaving
                      ? OperationsStrings.savingLabel(arabic)
                      : OperationsStrings.confirmTeamSubmission(arabic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
