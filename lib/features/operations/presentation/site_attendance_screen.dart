import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/site_attendance_screen_helpers.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_attendance_body.dart';
import 'package:radar_labor/features/operations/presentation/widgets/unsaved_changes_guard.dart';

final class SiteAttendanceScreen extends ConsumerStatefulWidget {
  const SiteAttendanceScreen({
    required this.controller, required this.arabic,
    this.teamSetupStore, this.actor, this.scope, this.initialTeamId, super.key,
  });

  final OperationsController controller; final bool arabic;
  final TeamSetupStore? teamSetupStore; final ActorContext? actor;
  final ScopeSnapshot? scope; final String? initialTeamId;

  @override
  ConsumerState<SiteAttendanceScreen> createState() => _SiteAttendanceScreenState();
}

final class _SiteAttendanceScreenState extends ConsumerState<SiteAttendanceScreen> {
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
        final teams = SiteAttendanceScreenHelpers.buildTeams(teamSnapshot.data);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) SiteAttendanceScreenHelpers.ensureSelected(notifier, state, teams, widget.initialTeamId);
        });
        final selected = SiteAttendanceScreenHelpers.resolveSelected(state, teams, widget.initialTeamId);
        final canEdit = SiteAttendanceScreenHelpers.canEdit(widget.actor, widget.teamSetupStore, selected);

        return SiteAttendanceBody(
          teams: teams, selected: selected, state: state, arabic: ar, canEditTeam: canEdit,
          notifier: notifier,
          onOpenEditTeam: () => SiteAttendanceScreenHelpers.openEdit(context, ref, widget.teamSetupStore, widget.actor, widget.scope, selected!, ar),
          onOpenCreateTeam: () => SiteAttendanceScreenHelpers.openCreate(context, ref, widget.teamSetupStore, widget.actor, ar),
          onSave: () => SiteAttendanceScreenHelpers.save(context, ref, ar, widget.actor, widget.scope),
        );
      },
    );

    return Navigator.of(context).canPop()
        ? Scaffold(
            appBar: AppBar(title: Text(OperationsStrings.startSiteAttendanceAction(ar))),
            body: UnsavedChangesGuard(hasUnsavedChanges: state.hasUnsavedChanges, persistDraft: notifier.flushDraft, arabic: ar, child: content),
          )
        : content;
  }
}
