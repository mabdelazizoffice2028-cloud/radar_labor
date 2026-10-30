import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_row_info.dart';

final class AttendanceRowContent extends StatelessWidget {
  const AttendanceRowContent({
    required this.row,
    required this.arabic,
    required this.searchQuery,
    this.onRemoveGuest,
    super.key,
  });

  final AttendanceRow row;
  final bool arabic;
  final String searchQuery;
  final VoidCallback? onRemoveGuest;

  @override
  Widget build(BuildContext context) {
    final statusText = row.isPresent
        ? OperationsStrings.presentLabel(arabic)
        : OperationsStrings.notPresentLabel(arabic);

    return Row(
      children: [
        Icon(
          row.isLocked
              ? Icons.lock_outline
              : (row.isPresent
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked),
          color: row.isPresent
              ? AppTokens.statusOnSite
              : AppTokens.textSecondary,
        ),
        const SizedBox(width: AppTokens.space12),
        Expanded(
          child: AttendanceRowInfo(
            row: row,
            arabic: arabic,
            searchQuery: searchQuery,
          ),
        ),
        const SizedBox(width: AppTokens.space8),
        Text(
          statusText,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: row.isPresent
                ? AppTokens.statusOnSite
                : AppTokens.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (row.isGuest && onRemoveGuest != null) ...[
          const SizedBox(width: AppTokens.space4),
          IconButton(
            tooltip: OperationsStrings.removeGuest(arabic),
            constraints: const BoxConstraints(
              minWidth: AppTokens.minTouchTarget,
              minHeight: AppTokens.minTouchTarget,
            ),
            onPressed: onRemoveGuest,
            icon: const Icon(Icons.close, size: AppTokens.space20),
          ),
        ],
      ],
    );
  }
}
