import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/worker_summary_strings.dart';
import 'package:radar_labor/core/status/staff_category_resolver.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

class WorkerSummaryHeader extends StatelessWidget {
  const WorkerSummaryHeader({
    required this.worker,
    required this.isAbsentToday,
    required this.arabic,
    required this.onToggleAbsenceToday,
    super.key,
  });

  final Employee worker;
  final bool isAbsentToday;
  final bool arabic;
  final VoidCallback onToggleAbsenceToday;

  @override
  Widget build(BuildContext context) {
    final name = (worker.fullNameEn != null && worker.fullNameEn!.trim().isNotEmpty)
        ? worker.fullNameEn!
        : worker.fullNameAr;
    final isStaff = StaffCategoryResolver.isAutoPresentStaff(worker.jobCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  Text('${worker.jobCategory} • ${worker.iqamaNo}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.space8),
        Wrap(
          spacing: AppTokens.space8,
          children: [
            if (isStaff)
              Chip(
                avatar: const Icon(Icons.verified, size: 16),
                label: Text(WorkerSummaryStrings.staffAutoPresent(arabic), style: const TextStyle(fontSize: 11)),
              ),
            OutlinedButton.icon(
              onPressed: onToggleAbsenceToday,
              icon: Icon(isAbsentToday ? Icons.check_circle_outline : Icons.cancel_outlined, size: 16),
              label: Text(isAbsentToday
                  ? WorkerSummaryStrings.clearAbsentToday(arabic)
                  : WorkerSummaryStrings.markAbsentToday(arabic)),
            ),
          ],
        ),
      ],
    );
  }
}
