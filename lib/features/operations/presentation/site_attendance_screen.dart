import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_edit_screen.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_conflict_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_counter_bar.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_diff_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/cross_team_search_sheet.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_confirm_sync_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_sync_helper.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_whatsapp_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_attendance_header.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_worker_list_view.dart';

/// Smart daily site attendance screen with dedicated back button navigation.
final class SiteAttendanceScreen extends ConsumerStatefulWidget {
  const SiteAttendanceScreen({
    required this.controller,
    required this.arabic,
    this.teamSetupStore,
    this.actor,
    this.scope,
    super.key,
  });

  final OperationsController controller;
  final bool arabic;
  final TeamSetupStore? teamSetupStore;
  final ActorContext? actor;
  final ScopeSnapshot? scope;

  @override
  ConsumerState<SiteAttendanceScreen> createState() =>
      _SiteAttendanceScreenState();
}

final class _SiteAttendanceScreenState
    extends ConsumerState<SiteAttendanceScreen> {
  Future<void> _openEditTeam(EntityOption team) async {
    final store = widget.teamSetupStore;
    final actor = widget.actor;
    final scope = widget.scope;
    if (store == null || actor == null || scope == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TeamEditScreen(
          store: store,
          actor: actor,
          scope: scope,
          team: team,
          arabic: widget.arabic,
        ),
      ),
    );
    if (updated == true && mounted) {
      await ref.read(siteAttendanceNotifierProvider.notifier).reload();
    }
  }

  Future<void> _handleSave() async {
    final ar = widget.arabic;
    final notifier = ref.read(siteAttendanceNotifierProvider.notifier);
    final state = ref.read(siteAttendanceNotifierProvider);
    final prepared = await notifier.prepareSave();
    if (prepared == null || !mounted) return;

    final diffOk = await AttendanceDiffDialog.show(
      context: context,
      team: prepared.team,
      date: prepared.date,
      diff: prepared.diff,
      arabic: ar,
    );
    if (!diffOk || !mounted) return;

    var resolutions = <String, ConflictResolutionChoice>{};
    if (prepared.conflicts.isNotEmpty) {
      final res = await AttendanceConflictDialog.show(
        context: context,
        conflicts: prepared.conflicts,
        currentTeamName: prepared.team.displayName(arabic: ar),
        arabic: ar,
        currentDate: prepared.date,
      );
      if (res == null || !mounted) return;
      resolutions = res;
    }

    final presentWorkers = state.rows
        .where((r) => r.isPresent)
        .map((r) => r.worker)
        .toList();
    final action = await OperationConfirmSyncDialog.show(
      context: context,
      title: OperationsStrings.confirmSiteAttendanceTitle(ar),
      entityName: prepared.team.displayName(arabic: ar),
      date: prepared.date,
      countSummaryText: OperationsStrings.presentCountLabel(
        ar,
        state.presentCount,
      ),
      selectedWorkers: presentWorkers,
      emptySelectionText: OperationsStrings.zeroWorkersConfirmation(ar),
      arabic: ar,
    );
    if (action == null || !mounted) return;

    final result = await notifier.confirmSave(
      prepared: prepared,
      resolutions: resolutions,
    );
    if (result == null || !mounted) return;

    if (action == ConfirmSaveAction.saveAndSync) {
      await performOperationSync(
        ref: ref,
        context: context,
        actor: widget.actor,
        scope: widget.scope,
        arabic: ar,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(OperationsStrings.teamSavedLocally(ar)),
          duration: OperationsConstants.undoWindow,
          action: SnackBarAction(
            label: OperationsStrings.undoAction(ar),
            onPressed: () => unawaited(notifier.undoLastSave()),
          ),
        ),
      );
    }

    if (!mounted) return;
    await showOperationWhatsappDialog(
      context: context,
      messageText: result.summary.messageText,
      arabic: ar,
    );
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final notifier = ref.read(siteAttendanceNotifierProvider.notifier)
      ..setOverrideContext(actor: widget.actor, scope: widget.scope);
    final state = ref.watch(siteAttendanceNotifierProvider);

    final content = StreamBuilder<List<EntityOption>>(
      stream: widget.controller.watchTeams(),
      builder: (context, teamSnapshot) {
        if (!teamSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final teams = teamSnapshot.data ?? const <EntityOption>[];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(notifier.ensureInitialTeam(teams));
        });

        final selected = state.selectedTeam ?? teams.firstOrNull;
        final canEdit =
            widget.teamSetupStore != null &&
            (widget.actor?.capabilities.canEditOwnTeamMembers ?? false) &&
            selected != null;

        return Column(
          children: [
            SiteAttendanceHeader(
              teams: teams,
              selected: selected,
              state: state,
              arabic: ar,
              canEditTeam: canEdit,
              onTeamChanged: (id) => unawaited(
                notifier.selectTeam(teams.where((t) => t.id == id).firstOrNull),
              ),
              onDateSelected: (d) => unawaited(notifier.selectDate(d)),
              onEditTeam: selected == null
                  ? null
                  : () => _openEditTeam(selected),
              onSelectAll: notifier.selectAll,
              onAddGuest: () => CrossTeamSearchSheet.show(
                context: context,
                arabic: ar,
                onSearch: notifier.searchGuests,
                onWorkerSelected: notifier.addGuestWorker,
              ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                ),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (selected != null && state.rows.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space4,
                ),
                child: TextField(
                  key: const ValueKey('site_worker_search_field'),
                  decoration: InputDecoration(
                    hintText: OperationsStrings.searchWorkersHint(ar),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radius12),
                    ),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => notifier.setSearchQuery(''),
                          )
                        : null,
                  ),
                  onChanged: notifier.setSearchQuery,
                ),
              ),
            Expanded(
              child: SiteWorkerListView(
                state: state,
                selected: selected,
                arabic: ar,
                onToggle: notifier.toggleWorker,
                onRemoveGuest: notifier.removeGuestWorker,
              ),
            ),
            AttendanceCounterBar(
              presentCount: state.presentCount,
              arabic: ar,
              enabled: selected != null && !state.isLoading,
              isSaving: state.isSaving,
              onSave: _handleSave,
            ),
          ],
        );
      },
    );

    if (Navigator.of(context).canPop()) {
      return Scaffold(
        appBar: AppBar(
          title: Text(OperationsStrings.startSiteAttendanceAction(ar)),
        ),
        body: content,
      );
    }
    return content;
  }
}
