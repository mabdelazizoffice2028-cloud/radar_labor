import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';

/// Single worker card with clean binary absence checkbox (Phase 4 refactored).
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
    final isAbsent = row.isAbsent;

    final backgroundColor = isAbsent
        ? AppTokens.statusUnknownSoft
        : AppTokens.surface;
    final borderColor = isAbsent ? AppTokens.statusUnknown : AppTokens.outline;
    final iconColor = isAbsent
        ? AppTokens.statusUnknown
        : AppTokens.textSecondary;
    final checkIcon = isAbsent
        ? Icons.check_box
        : Icons.check_box_outline_blank;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space4,
      ),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        side: BorderSide(color: borderColor, width: isAbsent ? 1.5 : 1.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        onTap: () => onStateChanged(
          isAbsent
              ? HousingReviewState.reviewedPresent
              : HousingReviewState.absent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space12),
          child: Row(
            children: [
              Icon(checkIcon, color: iconColor, size: 26),
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
                      '${OperationsStrings.codeLabel(arabic)}: ${worker.code}',
                      style: const TextStyle(
                        color: AppTokens.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAbsent)
                Text(
                  HousingReviewStrings.reviewStateAbsent(arabic),
                  style: const TextStyle(
                    color: AppTokens.statusUnknown,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
