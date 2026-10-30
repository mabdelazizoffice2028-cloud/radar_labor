import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/widgets/search_highlight_text.dart';

final class AttendanceRowInfo extends StatelessWidget {
  const AttendanceRowInfo({
    required this.row,
    required this.arabic,
    required this.searchQuery,
    super.key,
  });

  final AttendanceRow row;
  final bool arabic;
  final String searchQuery;

  String? _badgeText() {
    if (row.isLocked) return OperationsStrings.inactiveBadge(arabic);
    if (row.isGuest) {
      final team =
          row.originTeamDisplayName(arabic: arabic) ??
          OperationsStrings.noTeam(arabic);
      return OperationsStrings.fromTeamBadge(arabic, team);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final name = row.worker.displayName(arabic: arabic);
    final badge = _badgeText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SearchHighlightText(
          text: name,
          query: searchQuery,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTokens.space2),
        Wrap(
          spacing: AppTokens.space8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SearchHighlightText(
              text: row.worker.code,
              query: searchQuery,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space8,
                  vertical: AppTokens.space2,
                ),
                decoration: BoxDecoration(
                  color: AppTokens.background,
                  borderRadius: BorderRadius.circular(AppTokens.radiusChip),
                  border: Border.all(color: AppTokens.outline),
                ),
                child: Text(
                  badge,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
