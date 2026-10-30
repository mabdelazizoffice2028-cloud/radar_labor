import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/site_attendance_save_handler.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_edit_screen.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_attendance_body.dart';
import 'package:radar_labor/features/operations/presentation/widgets/unsaved_changes_guard.dart';

final class SiteAttendanceScreen extends ConsumerStatefulWidget {
  const SiteAttendanceScreen({
    required this.controller, required this.arabic,
    this.teamSetupStore, this.actor, this.scope, super.key,
  });

  final OperationsController controller;
  final bool arabic;
  final TeamSetupStore? teamSetupStore;
  final ActorContext? actor;
  final ScopeSnapshot? scope;

  @override
  ConsumerState<SiteAttendanceScreen> createState() => _SiteAttendanceScreenState();
}

final class _SiteAttendanceScreenState extends ConsumerState<SiteAttendanceScreen> {
  Future<void> _openEditTeam(EntityOption team) async {
    final s = widget.teamSetupStore; final a = widget.actor; final sc = widget.scope;
    if (s == null || a == null || sc == null) return;
    final updated = await Navigator.push<bool>(context, MaterialPageRoute(
      builder: (_) => TeamEditScreen(store: s, actor: a, scope: sc, team: team, arabic: widget.arabic),
    ));
    if (updated == true && mounted) await ref.read(siteAttendanceNotifierProvider.notifier).reload();
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
        if (!teamSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        final teams = teamSnapshot.data ?? const <EntityOption>[];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(notifier.ensureInitialTeam(teams));
        });
        final selected = state.selectedTeam ?? teams.firstOrNull;
        final canEdit = widget.teamSetupStore != null && (widget.actor?.capabilities.canEditOwnTeamMembers ?? false) && selected != null;

        return SiteAttendanceBody(
          teams: teams, selected: selected, state: state, arabic: ar, canEditTeam: canEdit,
          notifier: notifier, onOpenEditTeam: () => _openEditTeam(selected!),
          onSave: () => SiteAttendanceSaveHandler.handleSave(context: context, ref: ref, arabic: ar, actor: widget.actor, scope: widget.scope),
        );
      },
    );

    if (Navigator.of(context).canPop()) {
      return Scaffold(
        appBar: AppBar(title: Text(OperationsStrings.startSiteAttendanceAction(ar))),
        body: UnsavedChangesGuard(hasUnsavedChanges: state.hasUnsavedChanges, persistDraft: notifier.flushDraft, arabic: ar, child: content),
      );
    }
    return content;
  }
}
