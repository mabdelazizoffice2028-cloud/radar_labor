import 'dart:async';

import 'package:flutter/services.dart';
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
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_screen.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_conflict_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_counter_bar.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_diff_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_row_tile.dart';
import 'package:radar_labor/features/operations/presentation/widgets/cross_team_search_sheet.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_attendance_header.dart';

/// Smart daily site attendance screen (PRD §8, §9, §10).
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
  Future<void> _openCreateTeamWizard() async {
    final store = widget.teamSetupStore;
    final actor = widget.actor;
    if (store == null || actor == null) return;
    final created = await Navigator.push<EntityOption>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TeamWizardScreen(store: store, actor: actor, arabic: widget.arabic),
      ),
    );
    if (created != null && mounted) {
      await ref
          .read(siteAttendanceNotifierProvider.notifier)
          .selectTeam(created);
    }
  }

  Future<void> _openEditTeam(EntityOption team) async {
    final store = widget.teamSetupStore;
    final actor = widget.actor;
    final scope = widget.scope;
    if (store == null || actor == null || scope == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TeamEditScreen(
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
    final prepared = await notifier.prepareSave();
    if (prepared == null || !mounted) return;

    final diffConfirmed = await AttendanceDiffDialog.show(
      context: context,
      team: prepared.team,
      date: prepared.date,
      diff: prepared.diff,
      arabic: ar,
    );
    if (!diffConfirmed || !mounted) return;

    var resolutions = <String, ConflictResolutionChoice>{};
    if (prepared.conflicts.isNotEmpty) {
      final resolved = await AttendanceConflictDialog.show(
        context: context,
        conflicts: prepared.conflicts,
        currentTeamName: prepared.team.displayName(arabic: ar),
        arabic: ar,
      );
      if (resolved == null || !mounted) return;
      resolutions = resolved;
    }

    final result = await notifier.confirmSave(
      prepared: prepared,
      resolutions: resolutions,
    );
    if (result == null || !mounted) return;

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

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(OperationsStrings.whatsappSummaryTitle(ar)),
        content: SelectableText(result.summary.messageText),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: result.summary.messageText),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(OperationsStrings.copyTextAction(ar)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(OperationsStrings.closeAction(ar)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final notifier = ref.read(siteAttendanceNotifierProvider.notifier)
      ..setOverrideContext(actor: widget.actor, scope: widget.scope);
    final state = ref.watch(siteAttendanceNotifierProvider);

    return StreamBuilder<List<EntityOption>>(
      stream: widget.controller.watchTeams(),
      builder: (context, teamSnapshot) {
        if (!teamSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final teams = teamSnapshot.data ?? const <EntityOption>[];
        if (teams.isEmpty &&
            widget.teamSetupStore != null &&
            widget.actor != null &&
            widget.actor!.capabilities.canSetupTeam) {
          return TeamWizardScreen(
            store: widget.teamSetupStore!,
            actor: widget.actor!,
            arabic: ar,
            embedded: true,
            onTeamCreated: (created) => unawaited(notifier.selectTeam(created)),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(notifier.ensureInitialTeam(teams));
        });

        final selected = state.selectedTeam ?? teams.firstOrNull;
        return Column(
          children: [
            SiteAttendanceHeader(
              teams: teams,
              selected: selected,
              state: state,
              arabic: ar,
              canEditTeam:
                  widget.teamSetupStore != null &&
                  (widget.actor?.capabilities.canEditOwnTeamMembers ?? false) &&
                  selected != null,
              canCreateTeam:
                  widget.teamSetupStore != null &&
                  (widget.actor?.capabilities.canSetupTeam ?? false),
              onTeamChanged: (id) {
                final next = teams.where((t) => t.id == id).firstOrNull;
                unawaited(notifier.selectTeam(next));
              },
              onDateSelected: (date) => unawaited(notifier.selectDate(date)),
              onEditTeam: selected == null
                  ? null
                  : () => _openEditTeam(selected),
              onCreateTeam: _openCreateTeamWizard,
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
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : selected == null
                  ? Center(child: Text(OperationsStrings.addTeamToStart(ar)))
                  : state.rows.isEmpty
                  ? Center(child: Text(OperationsStrings.noWorkersInTeam(ar)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space8,
                      ),
                      itemCount: state.rows.length,
                      itemBuilder: (context, index) {
                        final row = state.rows[index];
                        return AttendanceRowTile(
                          row: row,
                          arabic: ar,
                          onToggle: () => notifier.toggleWorker(row.worker.id),
                          onRemoveGuest: row.isGuest
                              ? () => notifier.removeGuestWorker(row.worker.id)
                              : null,
                        );
                      },
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
  }
}
