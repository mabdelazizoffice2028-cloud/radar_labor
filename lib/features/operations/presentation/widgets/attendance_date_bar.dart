import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

/// Date selector bar and contextual banners for daily check-in (PRD §8.1, §8.3).
class AttendanceDateBar extends StatelessWidget {
  const AttendanceDateBar({
    required this.selectedDate,
    required this.todayDate,
    required this.isPastDate,
    required this.initialSource,
    required this.skippedDraftCount,
    required this.arabic,
    required this.onDateSelected,
    this.initialSourceDate,
    super.key,
  });

  final String selectedDate;
  final String todayDate;
  final bool isPastDate;
  final AttendanceInitialSource initialSource;
  final String? initialSourceDate;
  final int skippedDraftCount;
  final bool arabic;
  final ValueChanged<String> onDateSelected;

  Future<void> _pickDate(BuildContext context) async {
    final today = DateTime.tryParse(todayDate);
    final initial = DateTime.tryParse(selectedDate) ?? today;
    if (today == null || initial == null) return;
    final firstDate = today.subtract(
      const Duration(days: OperationsConstants.maxBackdateDays),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate)
          ? firstDate
          : (initial.isAfter(today) ? today : initial),
      firstDate: firstDate,
      lastDate: today,
    );
    if (picked == null) return;
    final formatted =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    onDateSelected(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final sourceBanner = _buildSourceBanner(context);
    final dateTitle = OperationsStrings.recordingForDate(arabic, selectedDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: dateTitle,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
              alignment: AlignmentDirectional.centerStart,
            ),
            onPressed: () => _pickDate(context),
            icon: const Icon(Icons.calendar_today_outlined),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateTitle, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  OperationsStrings.changeDate(arabic),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
        if (isPastDate) ...[
          const SizedBox(height: AppTokens.space8),
          Container(
            padding: const EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: AppTokens.statusUnknownSoft,
              borderRadius: BorderRadius.circular(AppTokens.radius12),
              border: Border.all(color: AppTokens.statusUnknown),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTokens.statusUnknown,
                ),
                const SizedBox(width: AppTokens.space8),
                Expanded(
                  child: Text(
                    OperationsStrings.pastDateWarning(arabic),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (sourceBanner != null) ...[
          const SizedBox(height: AppTokens.space8),
          sourceBanner,
        ],
      ],
    );
  }

  Widget? _buildSourceBanner(BuildContext context) {
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
    if (text == null) return null;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space8,
      ),
      decoration: BoxDecoration(
        color: AppTokens.background,
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        border: Border.all(color: AppTokens.outline),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTokens.primary),
          const SizedBox(width: AppTokens.space8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
