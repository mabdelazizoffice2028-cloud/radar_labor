import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/leaves/worker_leave.dart';
import 'package:radar_labor/core/l10n/worker_summary_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

class WorkerSummaryLeavesSection extends StatelessWidget {
  const WorkerSummaryLeavesSection({
    required this.leaves,
    required this.arabic,
    required this.onAddLeave,
    required this.onDeleteLeave,
    super.key,
  });

  final List<WorkerLeave> leaves;
  final bool arabic;
  final VoidCallback onAddLeave;
  final ValueChanged<String> onDeleteLeave;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(WorkerSummaryStrings.leaveManagement(arabic), style: Theme.of(context).textTheme.titleSmall),
                TextButton.icon(
                  onPressed: onAddLeave,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(WorkerSummaryStrings.addLeave(arabic)),
                ),
              ],
            ),
            if (leaves.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTokens.space8),
                child: Text(WorkerSummaryStrings.noLeavesYet(arabic), style: Theme.of(context).textTheme.bodySmall),
              )
            else
              ...leaves.map((l) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.beach_access, size: 20),
                title: Text('${l.startDate}  ➔  ${l.endDate}'),
                subtitle: l.note != null ? Text(l.note!) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => onDeleteLeave(l.leaveId),
                ),
              )),
          ],
        ),
      ),
    );
  }
}
