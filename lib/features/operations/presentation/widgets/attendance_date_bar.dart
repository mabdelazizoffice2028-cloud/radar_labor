import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_date_picker_helper.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_date_source_banner.dart';

class AttendanceDateBar extends StatelessWidget {
  const AttendanceDateBar({
    required this.selectedDate, required this.todayDate, required this.isPastDate,
    required this.initialSource, required this.skippedDraftCount, required this.arabic,
    required this.onDateSelected, this.initialSourceDate, this.canPickDate = false, super.key,
  });

  final String selectedDate;
  final String todayDate;
  final bool isPastDate;
  final AttendanceInitialSource initialSource;
  final String? initialSourceDate;
  final int skippedDraftCount;
  final bool arabic;
  final ValueChanged<String> onDateSelected;
  final bool canPickDate;

  @override
  Widget build(BuildContext context) {
    final dateTitle = OperationsStrings.recordingForDate(arabic, selectedDate);
    final isFriday = isFridayBusinessDate(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: canPickDate, label: dateTitle,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTokens.radius12),
            onTap: canPickDate ? () => AttendanceDatePickerHelper.pickDate(
              context: context, todayDate: todayDate, selectedDate: selectedDate, onDateSelected: onDateSelected,
            ) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTokens.space8, horizontal: AppTokens.space4),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 18, color: AppTokens.primary),
                  const SizedBox(width: AppTokens.space8),
                  Expanded(child: Text(dateTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                  if (isFriday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTokens.statusOnSiteSoft, borderRadius: BorderRadius.circular(AppTokens.radius12)),
                      child: Text(OperationsStrings.fridayOvertimeMode(arabic), style: const TextStyle(color: AppTokens.statusOnSite, fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  else if (canPickDate)
                    Text(OperationsStrings.changeDate(arabic), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTokens.primary, decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ),
        ),
        if (isPastDate)
          Container(
            padding: const EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(color: AppTokens.statusUnknownSoft, borderRadius: BorderRadius.circular(AppTokens.radius12), border: Border.all(color: AppTokens.statusUnknown)),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTokens.statusUnknown),
                const SizedBox(width: AppTokens.space8),
                Expanded(child: Text(OperationsStrings.pastDateWarning(arabic), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        AttendanceDateSourceBanner(initialSource: initialSource, initialSourceDate: initialSourceDate, skippedDraftCount: skippedDraftCount, arabic: arabic),
      ],
    );
  }
}
