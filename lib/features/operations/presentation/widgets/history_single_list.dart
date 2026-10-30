import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/history_notifier.dart';
import 'package:radar_labor/features/operations/presentation/widgets/history_card_tile.dart';

class HistorySingleList extends ConsumerWidget {
  const HistorySingleList({
    required this.page,
    required this.isLoading,
    required this.arabic,
    this.onEditSiteDay,
    super.key,
  });

  final HistoryPage page;
  final bool isLoading;
  final bool arabic;
  final void Function(EntityOption team, String date)? onEditSiteDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: const EdgeInsets.all(AppTokens.space16),
    children: [
      for (final card in page.cards)
        HistoryCardTile(
          card: card,
          arabic: arabic,
          onEditSiteDay: onEditSiteDay,
        ),
      if (page.hasMore) ...[
        const SizedBox(height: AppTokens.space12),
        SizedBox(
          height: AppTokens.minTouchTarget,
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () => unawaited(
                    ref.read(historyNotifierProvider.notifier).loadMore(),
                  ),
            child: Text(HistoryStrings.historyLoadMore(arabic)),
          ),
        ),
      ],
    ],
  );
}
