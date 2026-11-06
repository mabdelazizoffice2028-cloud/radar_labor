import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/operations_store.dart';
import 'package:radar_labor/features/operations/presentation/state/prepared_operations.dart';

abstract final class OperationsSiteCoordinator {
  static Future<PreparedSiteAttendance> prepare({
    required OperationsStore store,
    required Clock clock,
    required EntityOption team,
    required Set<String> presentIds,
    required bool arabic,
  }) async {
    final workers = await store.watchTeamWorkers(team.id).first;
    final date = businessDateFor(clock.nowUtc());
    return PreparedSiteAttendance(
      team: team,
      date: date,
      summary: AttendanceSummary.siteAttendance(
        team: team,
        date: date,
        workers: workers,
        presentIds: presentIds,
        arabic: arabic,
        strings: AttendanceMessageStrings.fromLanguage(arabic: arabic),
      ),
    );
  }
}
