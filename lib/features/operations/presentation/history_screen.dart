import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/time/time_format.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/audit_log_tab_view.dart';
import 'package:radar_labor/features/operations/presentation/history_day_detail_sheet.dart';
import 'package:radar_labor/features/operations/presentation/state/history_notifier.dart';

/// Supervisor and Admin History screen (PRD §11.1, §11.3).
final class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({
    required this.arabic,
    this.actor,
    this.scope,
    this.onEditSiteDay,
    super.key,
  });

  final bool arabic;
  final ActorContext? actor;
  final ScopeSnapshot? scope;
  final void Function(EntityOption team, String date)? onEditSiteDay;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

final class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  void _refresh() {
    if (!mounted) return;
    final notifier = ref.read(historyNotifierProvider.notifier)
      ..setOverrideContext(actor: widget.actor, scope: widget.scope);
    unawaited(notifier.refresh());
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final state = ref.watch(historyNotifierProvider);
    final session = ref.watch(currentSessionProvider);
    final capabilities =
        widget.actor?.capabilities ??
        session?.role.capabilities ??
        RoleCapabilities.viewer;

    if (state.isLoading && state.page == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.page == null) {
      return Center(child: Text(state.errorMessage!));
    }

    final page = state.page;
    if (capabilities.canViewAllHistory) {
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
                  page == null || page.cards.isEmpty
                      ? Center(child: Text(HistoryStrings.historyEmpty(ar)))
                      : _GroupedHistoryList(
                          groups: page.bySite,
                          hasMore: page.hasMore,
                          isLoading: state.isLoading,
                          arabic: ar,
                          onLoadMore: () => unawaited(
                            ref
                                .read(historyNotifierProvider.notifier)
                                .loadMore(),
                          ),
                          onEditSiteDay: widget.onEditSiteDay,
                        ),
                  page == null || page.cards.isEmpty
                      ? Center(child: Text(HistoryStrings.historyEmpty(ar)))
                      : _GroupedHistoryList(
                          groups: page.bySupervisor,
                          hasMore: page.hasMore,
                          isLoading: state.isLoading,
                          arabic: ar,
                          onLoadMore: () => unawaited(
                            ref
                                .read(historyNotifierProvider.notifier)
                                .loadMore(),
                          ),
                          onEditSiteDay: widget.onEditSiteDay,
                        ),
                  AuditLogTabView(arabic: ar, actorOverride: widget.actor),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (page == null || page.cards.isEmpty) {
      return Center(child: Text(HistoryStrings.historyEmpty(ar)));
    }

    return ListView(
      padding: const EdgeInsets.all(AppTokens.space16),
      children: [
        for (final card in page.cards)
          _HistoryCardTile(
            card: card,
            arabic: ar,
            onEditSiteDay: widget.onEditSiteDay,
          ),
        if (page.hasMore) ...[
          const SizedBox(height: AppTokens.space12),
          SizedBox(
            height: AppTokens.minTouchTarget,
            child: OutlinedButton(
              onPressed: state.isLoading
                  ? null
                  : () => unawaited(
                      ref.read(historyNotifierProvider.notifier).loadMore(),
                    ),
              child: Text(HistoryStrings.historyLoadMore(ar)),
            ),
          ),
        ],
      ],
    );
  }
}

class _GroupedHistoryList extends StatelessWidget {
  const _GroupedHistoryList({
    required this.groups,
    required this.hasMore,
    required this.isLoading,
    required this.arabic,
    required this.onLoadMore,
    this.onEditSiteDay,
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
                    child: _HistoryCardTile(
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

class _HistoryCardTile extends StatelessWidget {
  const _HistoryCardTile({
    required this.card,
    required this.arabic,
    this.onEditSiteDay,
  });

  final HistoryDayCard card;
  final bool arabic;
  final void Function(EntityOption team, String date)? onEditSiteDay;

  @override
  Widget build(BuildContext context) {
    final entityName = card.entity.displayName(arabic: arabic);
    final countText = card.kind == HistoryEntryKind.site
        ? HistoryStrings.historyPresentCount(arabic, card.count)
        : HistoryStrings.historyAbsentCount(arabic, card.count);
    final actorName =
        card.lastActorName ?? HistoryStrings.historyUnknownActor(arabic);
    final timeSuffix = card.recordedAtUtc == null
        ? ''
        : ' • ${RiyadhTimeFormat.hhMm(card.recordedAtUtc!)}';
    final editCallback = card.canEdit && onEditSiteDay != null
        ? () => onEditSiteDay!(card.entity, card.businessDate)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.space8),
      child: ListTile(
        onTap: () => HistoryDayDetailSheet.show(
          context: context,
          card: card,
          arabic: arabic,
          onEdit: editCallback,
        ),
        title: Text('$entityName — ${card.businessDate}'),
        subtitle: Text(
          '$countText\n${HistoryStrings.historyLastRecordedBy(arabic, actorName)}$timeSuffix',
        ),
        isThreeLine: true,
        trailing: editCallback != null
            ? TextButton.icon(
                onPressed: editCallback,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(HistoryStrings.historyEdit(arabic)),
              )
            : Text(
                HistoryStrings.historyLocked(arabic),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppTokens.textSecondary),
              ),
      ),
    );
  }
}
