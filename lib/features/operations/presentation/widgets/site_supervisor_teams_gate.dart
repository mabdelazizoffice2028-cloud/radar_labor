import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_screen.dart';
import 'package:radar_labor/features/operations/presentation/widgets/no_teams_empty_state.dart';

/// Observes the scoped team stream for a site supervisor. Shows loading and
/// error states, the create-team entry point when no team exists, and
/// otherwise the regular launcher [child].
final class SiteSupervisorTeamsGate extends StatefulWidget {
  const SiteSupervisorTeamsGate({
    required this.controller,
    required this.arabic,
    required this.child,
    this.teamSetupStore,
    this.actor,
    super.key,
  });

  final OperationsController controller;
  final bool arabic;
  final Widget child;
  final TeamSetupStore? teamSetupStore;
  final ActorContext? actor;

  @override
  State<SiteSupervisorTeamsGate> createState() =>
      _SiteSupervisorTeamsGateState();
}

final class _SiteSupervisorTeamsGateState
    extends State<SiteSupervisorTeamsGate> {
  late Stream<List<EntityOption>> _teams = widget.controller.watchTeams();

  @override
  void didUpdateWidget(covariant SiteSupervisorTeamsGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _teams = widget.controller.watchTeams();
    }
  }

  Future<void> _openWizard(TeamSetupStore store, ActorContext actor) async {
    await Navigator.of(context).push<EntityOption>(
      MaterialPageRoute(
        builder: (_) =>
            TeamWizardScreen(store: store, actor: actor, arabic: widget.arabic),
      ),
    );
    // The scoped team stream refreshes the launcher on its own.
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EntityOption>>(
      stream: _teams,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            key: const ValueKey('teams_stream_error'),
            child: Text(OperationsStrings.teamsLoadFailed(widget.arabic)),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            key: ValueKey('teams_loading'),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.requireData.isNotEmpty) return widget.child;
        final store = widget.teamSetupStore;
        final actor = widget.actor;
        return NoTeamsEmptyState(
          arabic: widget.arabic,
          onCreateTeam: store == null || actor == null
              ? null
              : () => _openWizard(store, actor),
        );
      },
    );
  }
}
