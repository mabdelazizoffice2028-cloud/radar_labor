import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_worker_tile.dart';

/// Step 2 of Team Setup Wizard (and reusable body for Team Edit): Worker selection (PRD §7.2, §16).
final class TeamWizardWorkersStep extends StatelessWidget {
  const TeamWizardWorkersStep({
    required this.arabic, required this.workers, required this.selectedIds,
    required this.isSelectable, required this.onSearchChanged, required this.onToggleWorker,
    required this.onSelectAllVisible, required this.onClearAllVisible, required this.onNext,
    this.onBack, this.stepHeader, required this.primaryActionLabel, super.key,
  });

  final bool arabic;
  final List<SelectableWorker> workers;
  final Set<String> selectedIds;
  final bool Function(SelectableWorker) isSelectable;
  final ValueChanged<String> onSearchChanged, onToggleWorker;
  final VoidCallback onSelectAllVisible, onClearAllVisible, onNext;
  final VoidCallback? onBack;
  final String? stepHeader;
  final String primaryActionLabel;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(AppTokens.space16, AppTokens.space12, AppTokens.space16, AppTokens.space8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (stepHeader != null) ...[
            Text(stepHeader!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space8),
          ],
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: OperationsStrings.searchWorkersHint(arabic), border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppTokens.space8),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: onSelectAllVisible, icon: const Icon(Icons.done_all), label: Text(OperationsStrings.selectAll(arabic)))),
            const SizedBox(width: AppTokens.space8),
            Expanded(child: OutlinedButton.icon(onPressed: onClearAllVisible, icon: const Icon(Icons.deselect), label: Text(OperationsStrings.clearAll(arabic)))),
          ]),
        ]),
      ),
      Expanded(
        child: workers.isEmpty
            ? Center(child: Text(OperationsStrings.noSearchResults(arabic)))
            : ListView.builder(
                itemCount: workers.length,
                itemBuilder: (context, index) => TeamWizardWorkerTile(
                  worker: workers[index], selectable: isSelectable(workers[index]),
                  selected: selectedIds.contains(workers[index].id), arabic: arabic,
                  onToggle: () => onToggleWorker(workers[index].id),
                ),
              ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(OperationsStrings.workersSelected(arabic, selectedIds.length), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppTokens.space8),
            Row(children: [
              if (onBack != null) ...[
                Expanded(child: OutlinedButton(
                  onPressed: onBack, style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppTokens.minTouchTarget)),
                  child: Text(OperationsStrings.wizardBack(arabic)),
                )),
                const SizedBox(width: AppTokens.space12),
              ],
              Expanded(flex: 2, child: FilledButton(
                onPressed: onNext, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppTokens.minTouchTarget)),
                child: Text(primaryActionLabel),
              )),
            ]),
          ]),
        ),
      ),
    ],
  );
}
