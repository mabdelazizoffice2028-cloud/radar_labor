import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/worker_summary_sheet.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

class WorkerListTile extends StatelessWidget {
  const WorkerListTile({required this.worker, required this.arabic, super.key});

  final Employee worker;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final title = (worker.fullNameEn != null && worker.fullNameEn!.trim().isNotEmpty)
        ? worker.fullNameEn!
        : worker.fullNameAr;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(title),
        subtitle: Text('${AppStrings.workerCode(arabic)}: ${worker.iqamaNo}'),
        onTap: () => WorkerSummarySheet.show(context, worker: worker, arabic: arabic),
      ),
    );
  }
}
