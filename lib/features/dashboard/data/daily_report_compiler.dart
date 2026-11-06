import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/attendance_breakdown_calculator.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/features/dashboard/domain/daily_report_generator.dart';

final class DailyReportCompiler {
  static Future<String> compile({
    required AppDatabase database,
    required StatusSnapshot snapshot,
    required String date,
    required bool arabic,
  }) async {
    final employees = await (database.select(database.employees)..where((r) => r.archivedAt.isNull())).get();
    final empMap = {for (final e in employees) e.iqamaNo: e, for (final e in employees) e.employeeCode: e};

    final presentWorkers = snapshot.workers.where((w) => w.status == WorkerStatus.onSite).toList(growable: false);
    final items = presentWorkers.map((w) {
      final emp = empMap[w.worker.employeeUid] ?? empMap[w.worker.code];
      return AttendanceBreakdownItem(
        id: w.worker.employeeUid,
        code: w.worker.code,
        name: w.worker.fullName,
        employmentType: emp?.employmentType ?? w.worker.employmentType,
        jobCategory: w.worker.jobCategory,
        supplier: emp?.rentalCompany ?? w.worker.rentalCompany,
      );
    });

    final breakdown = AttendanceBreakdownCalculator.calculate(items);
    final rentalMap = {for (final e in breakdown.rentalBySupplier.entries) e.key: e.value.length};

    final isFriday = isFridayBusinessDate(date);
    final absentCount = isFriday
        ? 0
        : snapshot.count(WorkerStatus.unknown);
    final unreviewedCount = isFriday ? 0 : snapshot.count(WorkerStatus.notRecorded);

    return DailyReportGenerator.generate(
      date: date,
      totalPresent: breakdown.totalCount,
      totalAbsent: absentCount,
      totalUnreviewed: unreviewedCount,
      companyPresent: breakdown.companyCount,
      rentalPresentByCompany: rentalMap,
      arabic: arabic,
    );
  }
}
