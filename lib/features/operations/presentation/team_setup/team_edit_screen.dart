import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/state/team_setup_notifier.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_workers_step.dart';

/// Supervisor screen for editing members of an assigned team (PRD §7.4).
final class TeamEditScreen extends ConsumerStatefulWidget {
  const TeamEditScreen({
    required this.store,
    required this.actor,
    required this.scope,
    required this.team,
    required this.arabic,
    super.key,
  });

  final TeamSetupStore store;
  final ActorContext actor;
  final ScopeSnapshot scope;
  final EntityOption team;
  final bool arabic;

  @override
  ConsumerState<TeamEditScreen> createState() => _TeamEditScreenState();
}

final class _TeamEditScreenState extends ConsumerState<TeamEditScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(teamSetupNotifierProvider.notifier)
          .bindStore(
            store: widget.store,
            arabic: widget.arabic,
            editingTeamId: widget.team.id,
          );
    });
  }

  Future<void> _save() async {
    final notifier = ref.read(teamSetupNotifierProvider.notifier);
    final ar = widget.arabic;
    final ok = await notifier.submitEditTeam(
      actor: widget.actor,
      scope: widget.scope,
      teamId: widget.team.id,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(OperationsStrings.teamMembersSaved(ar))),
      );
      Navigator.pop(context, true);
      return;
    }
    final failure = ref.read(teamSetupNotifierProvider).failure;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(OperationFailureMessage.of(failure, ar))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamSetupNotifierProvider);
    final notifier = ref.read(teamSetupNotifierProvider.notifier);
    final ar = widget.arabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${OperationsStrings.editTeam(ar)}: ${widget.team.displayName(arabic: ar)}',
        ),
      ),
      body: TeamWizardWorkersStep(
        arabic: ar,
        workers: state.visibleWorkers,
        selectedIds: state.selectedWorkerIds,
        isSelectable: state.isWorkerSelectable,
        onSearchChanged: notifier.setSearchQuery,
        onToggleWorker: notifier.toggleWorker,
        onSelectAllVisible: notifier.selectAllVisible,
        onClearAllVisible: notifier.clearAllVisible,
        onNext: _save,
        primaryActionLabel: state.isSaving
            ? OperationsStrings.savingLabel(ar)
            : AppStrings.save(ar),
      ),
    );
  }
}
