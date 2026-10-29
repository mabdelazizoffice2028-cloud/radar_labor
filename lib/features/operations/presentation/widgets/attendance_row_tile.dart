import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/widgets/search_highlight_text.dart';

/// Accessible 64dp worker row tile for smart daily check-in (PRD §8.1, §17.1).
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
    final name = row.worker.displayName(arabic: arabic);
    final statusText = row.isPresent
        ? OperationsStrings.presentLabel(arabic)
        : OperationsStrings.notPresentLabel(arabic);
    final badgeText = _badgeText();
    final bgColor = row.isPresent
        ? AppTokens.statusOnSiteSoft
        : AppTokens.surface;
    final borderColor = row.isPresent
        ? AppTokens.statusOnSite
        : AppTokens.outline;

    return Semantics(
      checked: row.isPresent,
      enabled: !row.isLocked,
      label: '$name, $statusText${badgeText == null ? '' : ', $badgeText'}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppTokens.space8),
        child: Material(
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radius12),
            side: BorderSide(color: borderColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTokens.radius12),
            onTap: row.isLocked ? null : onToggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppTokens.minRowHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space12,
                  vertical: AppTokens.space8,
                ),
                child: Row(
                  children: [
                    Icon(
                      row.isLocked
                          ? Icons.lock_outline
                          : (row.isPresent
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked),
                      color: row.isPresent
                          ? AppTokens.statusOnSite
                          : AppTokens.statusNotRecorded,
                    ),
                    const SizedBox(width: AppTokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SearchHighlightText(
                            text: name,
                            query: searchQuery,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: AppTokens.space8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SearchHighlightText(
                                text: row.worker.code,
                                query: searchQuery,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (badgeText != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTokens.space8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTokens.background,
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.radiusChip,
                                    ),
                                    border: Border.all(
                                      color: AppTokens.outline,
                                    ),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                ),
                            ],
                          ),
                        ],
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
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _badgeText() {
    if (row.isLocked) {
      return OperationsStrings.inactiveBadge(arabic);
    }
    if (row.isGuest) {
      final teamName =
          row.originTeamDisplayName(arabic: arabic) ??
          OperationsStrings.noTeam(arabic);
      return OperationsStrings.fromTeamBadge(arabic, teamName);
    }
    return null;
  }
}
