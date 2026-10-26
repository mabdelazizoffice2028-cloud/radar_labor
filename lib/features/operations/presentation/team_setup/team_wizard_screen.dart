import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/state/team_setup_notifier.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_confirm_step.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_name_step.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_workers_step.dart';

/// 3-step supervisor Team Setup Wizard (PRD §7).
final class TeamWizardScreen extends ConsumerStatefulWidget {
  const TeamWizardScreen({
    required this.store,
    required this.actor,
    required this.arabic,
    this.onTeamCreated,
    this.embedded = false,
    super.key,
  });

  final TeamSetupStore store;
  final ActorContext actor;
  final bool arabic;
  final ValueChanged<EntityOption>? onTeamCreated;
  final bool embedded;

  @override
  ConsumerState<TeamWizardScreen> createState() => _TeamWizardScreenState();
}

final class _TeamWizardScreenState extends ConsumerState<TeamWizardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(teamSetupNotifierProvider.notifier)
          .bindStore(store: widget.store, arabic: widget.arabic);
    });
  }

  @override
  void didUpdateWidget(covariant TeamWizardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.arabic != widget.arabic || oldWidget.store != widget.store) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(teamSetupNotifierProvider.notifier)
            .bindStore(store: widget.store, arabic: widget.arabic);
      });
    }
  }

  Future<void> _confirmAndCreate() async {
    final notifier = ref.read(teamSetupNotifierProvider.notifier);
    final state = ref.read(teamSetupNotifierProvider);
    final ar = widget.arabic;

    if (state.selectedWorkerIds.isEmpty) {
      final confirmEmpty = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(OperationsStrings.setupTeamWizardTitle(ar)),
          content: Text(OperationsStrings.confirmCreateEmptyTeam(ar)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.cancel(ar)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(OperationsStrings.confirmAction(ar)),
            ),
          ],
        ),
      );
      if (confirmEmpty != true || !mounted) return;
    }

    final created = await notifier.submitCreateTeam(actor: widget.actor);
    if (!mounted) return;
    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(OperationsStrings.teamCreated(ar))),
      );
      widget.onTeamCreated?.call(created);
      if (!widget.embedded && Navigator.canPop(context)) {
        Navigator.pop(context, created);
      }
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

    final stepContent = switch (state.step) {
      1 => TeamWizardNameStep(
        arabic: ar,
        nameAr: state.nameAr,
        nameEn: state.nameEn,
        onNameArChanged: notifier.setNameAr,
        onNameEnChanged: notifier.setNameEn,
        onNext: () {
          if (!notifier.advanceFromNameStep()) {
            final failure = ref.read(teamSetupNotifierProvider).failure;
            if (failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(OperationFailureMessage.of(failure, ar)),
                ),
              );
            }
          }
        },
      ),
      2 => TeamWizardWorkersStep(
        arabic: ar,
        stepHeader: OperationsStrings.wizardStepOf(ar, 2, 3),
        workers: state.visibleWorkers,
        selectedIds: state.selectedWorkerIds,
        isSelectable: state.isWorkerSelectable,
        onSearchChanged: notifier.setSearchQuery,
        onToggleWorker: notifier.toggleWorker,
        onSelectAllVisible: notifier.selectAllVisible,
        onClearAllVisible: notifier.clearAllVisible,
        onBack: () => notifier.goToStep(1),
        onNext: () => notifier.goToStep(3),
        primaryActionLabel: OperationsStrings.wizardNext(ar),
      ),
      _ => TeamWizardConfirmStep(
        arabic: ar,
        teamNameAr: state.nameAr,
        teamNameEn: state.nameEn,
        selectedWorkers: state.selectedWorkersSorted,
        isSaving: state.isSaving,
        onBack: () => notifier.goToStep(2),
        onConfirm: _confirmAndCreate,
      ),
    };

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              OperationsStrings.noTeamsYetSupervisor(ar),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(child: stepContent),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(OperationsStrings.setupTeamWizardTitle(ar))),
      body: stepContent,
    );
  }
}
