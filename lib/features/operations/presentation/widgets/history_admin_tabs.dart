import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/ui/components/app_empty_state.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/audit_log_tab_view.dart';
import 'package:radar_labor/features/operations/presentation/state/history_notifier.dart';
import 'package:radar_labor/features/operations/presentation/widgets/grouped_history_list.dart';

class HistoryAdminTabs extends ConsumerWidget {
  const HistoryAdminTabs({
    required this.arabic, required this.page, required this.isLoading,
    this.actor, this.onEditSiteDay, super.key,
  });

  final bool arabic; final HistoryPage? page; final bool isLoading;
  final ActorContext? actor;
  final void Function(EntityOption team, String date)? onEditSiteDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ar = arabic;
    final empty = AppEmptyState(icon: Icons.history_outlined, message: HistoryStrings.historyEmpty(ar));
    final hasData = page != null && page!.cards.isNotEmpty;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              tabs: [
                Tab(text: HistoryStrings.historyBySite(ar)),
                Tab(text: HistoryStrings.historyBySupervisor(ar)),
                Tab(text: AdminStrings.auditLogTab(ar)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                !hasData ? empty : GroupedHistoryList(
                  groups: page!.bySite, hasMore: page!.hasMore, isLoading: isLoading, arabic: ar,
                  onLoadMore: () => unawaited(ref.read(historyNotifierProvider.notifier).loadMore()),
                  onEditSiteDay: onEditSiteDay,
                ),
                !hasData ? empty : GroupedHistoryList(
                  groups: page!.bySupervisor, hasMore: page!.hasMore, isLoading: isLoading, arabic: ar,
                  onLoadMore: () => unawaited(ref.read(historyNotifierProvider.notifier).loadMore()),
                  onEditSiteDay: onEditSiteDay,
                ),
                AuditLogTabView(arabic: ar, actorOverride: actor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
