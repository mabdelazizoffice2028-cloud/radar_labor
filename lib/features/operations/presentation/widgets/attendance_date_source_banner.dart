import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

final class AttendanceDateSourceBanner extends StatelessWidget {
  const AttendanceDateSourceBanner({
    required this.initialSource,
    required this.initialSourceDate,
    required this.skippedDraftCount,
    required this.arabic,
    super.key,
  });

  final AttendanceInitialSource initialSource;
  final String? initialSourceDate;
  final int skippedDraftCount;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    String? text;
    IconData icon = Icons.history_outlined;
    if (initialSource == AttendanceInitialSource.draft) {
      text = skippedDraftCount > 0
          ? OperationsStrings.draftRestoredPartial(arabic, skippedDraftCount)
          : OperationsStrings.draftRestored(arabic);
      icon = Icons.restore_outlined;
    } else if (initialSource == AttendanceInitialSource.savedDay) {
      text = OperationsStrings.savedDayLoaded(arabic);
      icon = Icons.check_circle_outline;
    } else if (initialSource == AttendanceInitialSource.suggestion &&
        initialSourceDate != null) {
      text = OperationsStrings.suggestionFromDate(arabic, initialSourceDate!);
      icon = Icons.auto_awesome_outlined;
    }
    if (text == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space12, vertical: AppTokens.space8),
      decoration: BoxDecoration(
        color: AppTokens.background,
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        border: Border.all(color: AppTokens.outline),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTokens.primary),
          const SizedBox(width: AppTokens.space8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
