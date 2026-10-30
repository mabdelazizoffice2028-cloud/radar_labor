import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/worker_summary_strings.dart';
import 'package:radar_labor/core/status/worker_summary_calculator.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

class WorkerSummaryKpiCards extends StatelessWidget {
  const WorkerSummaryKpiCards({required this.summary, required this.arabic, super.key});
  final WorkerSummary summary;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(padding: const EdgeInsets.all(AppTokens.space12), child: Column(children: [
            Text('${summary.totalDaysWorked}', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppTokens.space4),
            Text(WorkerSummaryStrings.totalDaysWorked(arabic), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            Text(WorkerSummaryStrings.includesJustified(arabic), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
          ])),
        )),
        const SizedBox(width: AppTokens.space8),
        Expanded(child: Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(padding: const EdgeInsets.all(AppTokens.space12), child: Column(children: [
            Text('${summary.totalDaysAbsent}', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppTokens.space4),
            Text(WorkerSummaryStrings.totalDaysAbsent(arabic), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ])),
        )),
      ]),
      const SizedBox(height: AppTokens.space8),
      Card(
        child: Padding(padding: const EdgeInsets.all(AppTokens.space12), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(WorkerSummaryStrings.teamsHistory(arabic), style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppTokens.space4),
            if (summary.teamHistory.isEmpty)
              Text(WorkerSummaryStrings.noTeamsYet(arabic), style: Theme.of(context).textTheme.bodySmall)
            else
              ...summary.teamHistory.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(t.teamName, style: Theme.of(context).textTheme.bodyMedium),
                  Text(WorkerSummaryStrings.daysCount(arabic, t.days), style: Theme.of(context).textTheme.bodySmall),
                ]),
              )),
          ],
        )),
      ),
    ]);
  }
}
