import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/leaves/leave_repository.dart';
import 'package:radar_labor/core/status/attendance_ledger.dart';
import 'package:radar_labor/core/status/worker_summary_calculator.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';

final class WorkerSummaryLoader {
  static Future<({WorkerSummary summary, bool isAbsentToday, String todayDate})> load({
    required AppDatabase database,
    required EventRepository events,
    required LeaveRepository leaves,
    required String employeeUid,
    required String jobCategory,
    required Clock clock,
  }) async {
    final allEvents = await events.watchAll().first;
    final allLeaves = await leaves.readAll();
    final teams = await database.select(database.teams).get();
    final teamNames = {
      for (final t in teams)
        t.teamId: (t.nameEn != null && t.nameEn!.trim().isNotEmpty) ? t.nameEn! : t.nameAr,
    };
    final summary = WorkerSummaryCalculator.calculate(
      employeeUid: employeeUid,
      jobCategory: jobCategory,
      allEvents: allEvents,
      leaves: allLeaves,
      teamNamesById: teamNames,
    );
    final today = businessDateFor(clock.nowUtc());
    final todayEvents = await events.readBusinessDate(today);
    final todayLedger = AttendanceLedger(todayEvents);
    final isAbsentToday = todayLedger.hasActiveHousingAbsent(employeeUid);
    return (summary: summary, isAbsentToday: isAbsentToday, todayDate: today);
  }
}
