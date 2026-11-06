import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/features/operations/data/site_attendance_preparer.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

final class SiteAttendanceSummaryHelper {
  static AttendanceSummary build({
    required String date,
    required EntityOption team,
    required List<Employee> activeEmployees,
    required Set<String> presentIds,
    required bool arabic,
    String? supervisorName,
  }) {
    final isNoTeam = team.id == OperationsConstants.noTeamId;
    final workers = [
      for (final emp in activeEmployees)
        if ((isNoTeam
                ? (emp.currentTeamId == null || emp.currentTeamId!.isEmpty)
                : emp.currentTeamId == team.id) ||
            presentIds.contains(emp.employeeUid))
          SiteAttendancePreparer.toWorker(emp),
    ]..sort((a, b) => SiteAttendancePreparer.cmpWorker(a, b, arabic));

    return AttendanceSummary.siteAttendance(
      date: date,
      team: team,
      workers: workers,
      presentIds: presentIds,
      arabic: arabic,
      strings: AttendanceMessageStrings.fromLanguage(arabic: arabic),
      supervisorName: supervisorName,
    );
  }
}
