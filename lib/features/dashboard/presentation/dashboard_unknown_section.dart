import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class DashboardUnknownSection extends StatelessWidget {
  const DashboardUnknownSection({
    required this.rows,
    required this.arabic,
    required this.onJustify,
    super.key,
  });

  final List<WorkerStatusResult> rows;
  final bool arabic;
  final ValueChanged<WorkerStatusResult>? onJustify;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            top: AppTokens.space16,
            bottom: AppTokens.space4,
          ),
          child: Text(
            DashboardStrings.unknownWorkers(arabic),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        for (final row in rows)
          Card(
            child: ListTile(
              leading: Icon(
                row.isSlaBreached
                    ? Icons.timer_off_outlined
                    : Icons.help_outline,
                color: row.isSlaBreached
                    ? AppTokens.statusUnknown
                    : AppTokens.statusHousingOnly,
              ),
              title: Text('${row.worker.fullName} • ${row.worker.code}'),
              subtitle: Text(
                row.isSlaBreached
                    ? DashboardStrings.slaExceeded(arabic)
                    : DashboardStrings.campusAbsenceNoJustification(arabic),
              ),
              trailing: IconButton(
                tooltip: DashboardStrings.addJustification(arabic),
                onPressed: onJustify == null ? null : () => onJustify!(row),
                icon: const Icon(Icons.note_add_outlined),
              ),
            ),
          ),
      ],
    );
  }
}
