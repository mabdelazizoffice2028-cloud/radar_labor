import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/state/team_setup_notifier.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_create_action.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_step_body.dart';

final class TeamWizardScreen extends ConsumerStatefulWidget {
  const TeamWizardScreen({
    required this.store, required this.actor, required this.arabic,
    this.onTeamCreated, this.embedded = false, super.key,
  });

  final TeamSetupStore store; final ActorContext actor; final bool arabic;
  final ValueChanged<EntityOption>? onTeamCreated; final bool embedded;

  @override
  ConsumerState<TeamWizardScreen> createState() => _TeamWizardScreenState();
}

final class _TeamWizardScreenState extends ConsumerState<TeamWizardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamSetupNotifierProvider.notifier).bindStore(store: widget.store, arabic: widget.arabic);
    });
  }

  @override
  void didUpdateWidget(covariant TeamWizardScreen old) {
    super.didUpdateWidget(old);
    if (old.arabic != widget.arabic || old.store != widget.store) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(teamSetupNotifierProvider.notifier).bindStore(store: widget.store, arabic: widget.arabic);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final stepContent = TeamWizardStepBody(
      arabic: ar,
      onConfirm: () => confirmAndCreateTeam(
        context: context, ref: ref, actor: widget.actor, arabic: ar,
        embedded: widget.embedded, onTeamCreated: widget.onTeamCreated,
      ),
    );

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTokens.space16, AppTokens.space12, AppTokens.space16, 0),
            child: Text(OperationsStrings.noTeamsYetSupervisor(ar), style: Theme.of(context).textTheme.bodyMedium),
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
