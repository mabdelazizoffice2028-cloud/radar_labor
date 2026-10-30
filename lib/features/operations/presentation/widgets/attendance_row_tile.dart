import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_row_content.dart';

class AttendanceRowTile extends StatelessWidget {
  const AttendanceRowTile({
    required this.row,
    required this.arabic,
    required this.onToggle,
    this.onRemoveGuest,
    this.searchQuery = '',
    super.key,
  });

  final AttendanceRow row;
  final bool arabic;
  final VoidCallback onToggle;
  final VoidCallback? onRemoveGuest;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final bgColor = row.isPresent
        ? AppTokens.statusOnSiteSoft
        : AppTokens.surface;
    final borderColor = row.isPresent
        ? AppTokens.statusOnSite
        : AppTokens.outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space8),
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius12),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radius12),
          onTap: row.isLocked
              ? null
              : () {
                  FieldHaptics.selection();
                  onToggle();
                },
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppTokens.minRowHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space12,
                vertical: AppTokens.space8,
              ),
              child: AttendanceRowContent(
                row: row,
                arabic: arabic,
                searchQuery: searchQuery,
                onRemoveGuest: onRemoveGuest,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
