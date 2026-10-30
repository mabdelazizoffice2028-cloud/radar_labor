import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';
import 'package:radar_labor/core/status/status_models.dart';

final class DashboardIntegritySection extends StatelessWidget {
  const DashboardIntegritySection({
    required this.rows,
    required this.arabic,
    super.key,
  });

  final List<WorkerStatusResult> rows;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Card(
      child: ExpansionTile(
        title: Text(DashboardStrings.ledgerNotices(arabic, rows.length)),
        children: [
          for (final row in rows)
            ListTile(
              title: Text('${row.worker.fullName} • ${row.worker.code}'),
              subtitle: Text(_labels(row.flags, arabic)),
            ),
        ],
      ),
    );
  }

  String _labels(Set<StatusFlag> flags, bool arabic) {
    final values = <String>[];
    if (flags.contains(StatusFlag.inactiveWorkerEvent)) {
      values.add(DashboardStrings.noticeInactiveWorker(arabic));
    }
    if (flags.contains(StatusFlag.eventOutsideEmployment)) {
      values.add(DashboardStrings.noticeOutsideEmployment(arabic));
    }
    if (flags.contains(StatusFlag.lateEvent)) {
      values.add(DashboardStrings.noticeLateEntry(arabic));
    }
    if (flags.contains(StatusFlag.rejectedEvent)) {
      values.add(DashboardStrings.noticeRejectedEvent(arabic));
    }
    return values.join(' • ');
  }
}
