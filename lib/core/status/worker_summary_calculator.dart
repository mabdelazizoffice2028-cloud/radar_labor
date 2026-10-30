import 'package:radar_labor/core/leaves/worker_leave.dart';
import 'package:radar_labor/core/status/attendance_ledger.dart';
import 'package:radar_labor/core/status/staff_category_resolver.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';

final class TeamWorkCount {
  const TeamWorkCount({required this.teamName, required this.days});
  final String teamName;
  final int days;
}

final class WorkerSummary {
  const WorkerSummary({
    required this.employeeUid,
    required this.totalDaysWorked,
    required this.totalDaysAbsent,
    required this.teamHistory,
    required this.activeLeaves,
  });

  final String employeeUid;
  final int totalDaysWorked;
  final int totalDaysAbsent;
  final List<TeamWorkCount> teamHistory;
  final List<WorkerLeave> activeLeaves;
}

abstract final class WorkerSummaryCalculator {
  static WorkerSummary calculate({
    required String employeeUid,
    required String jobCategory,
    required Iterable<LocalEvent> allEvents,
    required List<WorkerLeave> leaves,
    required Map<String, String> teamNamesById,
  }) {
    final workerLeaves = leaves.where((l) => l.employeeUid == employeeUid).toList();
    final isStaff = StaffCategoryResolver.isAutoPresentStaff(jobCategory);
    final eventsByDate = <String, List<LocalEvent>>{};
    for (final e in allEvents) {
      eventsByDate.putIfAbsent(e.businessDate, () => []).add(e);
    }

    var totalDaysWorked = 0;
    var totalDaysAbsent = 0;
    final daysPerTeam = <String, int>{};

    for (final entry in eventsByDate.entries) {
      final date = entry.key;
      if (workerLeaves.any((l) => l.coversDate(date))) continue;

      final ledger = AttendanceLedger(entry.value);
      final hasSitePresent = ledger.hasActiveSitePresence(employeeUid);
      final hasJustification = ledger.hasActiveJustification(employeeUid);
      final hasHousingAbsent = ledger.hasActiveHousingAbsent(employeeUid);
      final isFriday = isFridayBusinessDate(date);

      if (hasSitePresent || hasJustification || (isStaff && !isFriday && !hasHousingAbsent)) {
        totalDaysWorked++;
      }
      if (!isFriday && hasHousingAbsent && !hasJustification && !hasSitePresent) {
        totalDaysAbsent++;
      }
      for (final teamId in ledger.activeTeamsForWorker(employeeUid)) {
        daysPerTeam[teamId] = (daysPerTeam[teamId] ?? 0) + 1;
      }
    }

    final teamHistory = [
      for (final e in daysPerTeam.entries)
        TeamWorkCount(teamName: teamNamesById[e.key] ?? e.key, days: e.value),
    ]..sort((a, b) => b.days.compareTo(a.days));

    return WorkerSummary(
      employeeUid: employeeUid, totalDaysWorked: totalDaysWorked, totalDaysAbsent: totalDaysAbsent,
      teamHistory: List.unmodifiable(teamHistory), activeLeaves: List.unmodifiable(workerLeaves),
    );
  }
}
