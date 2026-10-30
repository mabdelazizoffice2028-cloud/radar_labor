import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/widgets/history_card_tile.dart';

class GroupedHistoryList extends StatelessWidget {
  const GroupedHistoryList({
    required this.groups,
    required this.hasMore,
    required this.isLoading,
    required this.arabic,
    required this.onLoadMore,
    this.onEditSiteDay,
    super.key,
  });

  final Map<String, List<HistoryDayCard>> groups;
  final bool hasMore;
  final bool isLoading;
  final bool arabic;
  final VoidCallback onLoadMore;
  final void Function(EntityOption team, String date)? onEditSiteDay;

  @override
  Widget build(BuildContext context) {
    final keys = groups.keys.toList();
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space16),
      children: [
        for (final key in keys)
          Card(
            margin: const EdgeInsets.only(bottom: AppTokens.space8),
            child: ExpansionTile(
              title: Text(
                '$key (${groups[key]!.length})',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              children: [
                for (final card in groups[key]!)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space8,
                    ),
                    child: HistoryCardTile(
                      card: card,
                      arabic: arabic,
                      onEditSiteDay: onEditSiteDay,
                    ),
                  ),
              ],
            ),
          ),
        if (hasMore) ...[
          const SizedBox(height: AppTokens.space12),
          SizedBox(
            height: AppTokens.minTouchTarget,
            child: OutlinedButton(
              onPressed: isLoading ? null : onLoadMore,
              child: Text(HistoryStrings.historyLoadMore(arabic)),
            ),
          ),
        ],
      ],
    );
  }
}
