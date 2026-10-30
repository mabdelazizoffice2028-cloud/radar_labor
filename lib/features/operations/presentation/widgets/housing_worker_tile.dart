import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_worker_info.dart';

final class HousingWorkerTile extends StatelessWidget {
  const HousingWorkerTile({
    required this.row, required this.arabic, required this.onStateChanged,
    this.searchQuery = '', super.key,
  });

  final HousingWorkerRow row;
  final bool arabic;
  final ValueChanged<HousingReviewState> onStateChanged;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final isAbsent = row.isAbsent;
    final bg = isAbsent ? AppTokens.statusUnknownSoft : AppTokens.surface;
    final border = isAbsent ? AppTokens.statusUnknown : AppTokens.outline;
    final iconColor = isAbsent ? AppTokens.statusUnknown : AppTokens.textSecondary;
    final checkIcon = isAbsent ? Icons.check_box : Icons.check_box_outline_blank;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppTokens.space12, vertical: AppTokens.space4),
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        side: BorderSide(color: border, width: isAbsent ? 1.5 : 1.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        onTap: () {
          FieldHaptics.selection();
          onStateChanged(isAbsent ? HousingReviewState.reviewedPresent : HousingReviewState.absent);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space12),
          child: Row(
            children: [
              Icon(checkIcon, color: iconColor, size: 26),
              const SizedBox(width: AppTokens.space12),
              Expanded(child: HousingWorkerInfo(worker: row.worker, arabic: arabic, searchQuery: searchQuery)),
              if (isAbsent)
                Text(
                  HousingReviewStrings.reviewStateAbsent(arabic),
                  style: const TextStyle(color: AppTokens.statusUnknown, fontWeight: FontWeight.bold, fontSize: 13),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
