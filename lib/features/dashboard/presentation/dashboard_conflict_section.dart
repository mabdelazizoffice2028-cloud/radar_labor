import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class DashboardConflictSection extends StatelessWidget {
  const DashboardConflictSection({
    required this.rows,
    required this.arabic,
    required this.onResolve,
    super.key,
  });

  final List<WorkerStatusResult> rows;
  final bool arabic;
  final ValueChanged<WorkerStatusResult>? onResolve;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DashboardStrings.conflictsToReview(arabic),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        for (final row in rows)
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.compare_arrows,
                color: AppTokens.statusHousingOnly,
              ),
              title: Text('${row.worker.fullName} • ${row.worker.code}'),
              subtitle: Text(_conflictLabel(row.flags, arabic)),
              trailing: TextButton(
                onPressed: onResolve == null ? null : () => onResolve!(row),
                child: Text(DashboardStrings.resolve(arabic)),
              ),
            ),
          ),
      ],
    );
  }

  String _conflictLabel(Set<StatusFlag> flags, bool arabic) {
    final labels = <String>[];
    if (flags.contains(StatusFlag.housingSiteConflict)) {
      labels.add(DashboardStrings.conflictHousingAndSite(arabic));
    }
    if (flags.contains(StatusFlag.multipleSiteTeams)) {
      labels.add(DashboardStrings.conflictMultipleTeams(arabic));
    }
    return labels.join(' • ');
  }
}
