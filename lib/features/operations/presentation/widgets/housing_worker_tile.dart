import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';

/// Single worker card with explicit 3-state review actions (Phase 4).
final class HousingWorkerTile extends StatelessWidget {
  const HousingWorkerTile({
    required this.row,
    required this.arabic,
    required this.onStateChanged,
    super.key,
  });

  final HousingWorkerRow row;
  final bool arabic;
  final ValueChanged<HousingReviewState> onStateChanged;

  @override
  Widget build(BuildContext context) {
    final worker = row.worker;
    final isUnreviewed = row.reviewState == HousingReviewState.unreviewed;
    final isPresent = row.reviewState == HousingReviewState.reviewedPresent;
    final isAbsent = row.reviewState == HousingReviewState.absent;

    final Color statusColor;
    final IconData statusIcon;
    final String statusLabel;

    if (isPresent) {
      statusColor = AppTokens.statusOnSite;
      statusIcon = Icons.check_circle_outline;
      statusLabel = HousingReviewStrings.reviewStateReviewed(arabic);
    } else if (isAbsent) {
      statusColor = AppTokens.statusHousingOnly;
      statusIcon = Icons.person_off_outlined;
      statusLabel = HousingReviewStrings.reviewStateAbsent(arabic);
    } else {
      statusColor = AppTokens.statusNotRecorded;
      statusIcon = Icons.help_outline;
      statusLabel = HousingReviewStrings.reviewStateUnreviewed(arabic);
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        side: BorderSide(
          color: isUnreviewed
              ? AppTokens.outline
              : statusColor.withValues(alpha: 0.5),
          width: isUnreviewed ? 1 : 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space12),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 28),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    worker.displayName(arabic: arabic),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${OperationsStrings.codeLabel(arabic)}: ${worker.code} • $statusLabel',
                    style: TextStyle(
                      color: isUnreviewed
                          ? AppTokens.textSecondary
                          : statusColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTokens.space8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: HousingReviewStrings.reviewStateReviewed(arabic),
                  icon: Icon(
                    Icons.check_circle,
                    color: isPresent
                        ? AppTokens.statusOnSite
                        : AppTokens.outline,
                  ),
                  onPressed: () => onStateChanged(
                    isPresent
                        ? HousingReviewState.unreviewed
                        : HousingReviewState.reviewedPresent,
                  ),
                ),
                IconButton(
                  tooltip: HousingReviewStrings.reviewStateAbsent(arabic),
                  icon: Icon(
                    Icons.cancel,
                    color: isAbsent
                        ? AppTokens.statusHousingOnly
                        : AppTokens.outline,
                  ),
                  onPressed: () => onStateChanged(
                    isAbsent
                        ? HousingReviewState.unreviewed
                        : HousingReviewState.absent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
