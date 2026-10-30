import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/ui/components/app_empty_state.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/history_notifier.dart';
import 'package:radar_labor/features/operations/presentation/widgets/history_admin_tabs.dart';
import 'package:radar_labor/features/operations/presentation/widgets/history_single_list.dart';

final class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({
    required this.arabic, this.actor, this.scope, this.onEditSiteDay, super.key,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(historyNotifierProvider.notifier);
      notifier.setOverrideContext(actor: widget.actor, scope: widget.scope);
      unawaited(notifier.refresh());
    });
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final state = ref.watch(historyNotifierProvider);
    final capabilities = widget.actor?.capabilities ??
        ref.watch(currentSessionProvider)?.role.capabilities ?? RoleCapabilities.viewer;

    if (state.isLoading && state.page == null) return const Center(child: CircularProgressIndicator());
    if (state.errorMessage != null && state.page == null) return Center(child: Text(state.errorMessage!));

    final page = state.page;
    if (capabilities.canViewAllHistory) {
      return HistoryAdminTabs(
        arabic: ar, page: page, isLoading: state.isLoading,
        actor: widget.actor, onEditSiteDay: widget.onEditSiteDay,
      );
    }
    if (page == null || page.cards.isEmpty) {
      return AppEmptyState(icon: Icons.history_outlined, message: HistoryStrings.historyEmpty(ar));
    }
    return HistorySingleList(page: page, isLoading: state.isLoading, arabic: ar, onEditSiteDay: widget.onEditSiteDay);
  }
}
