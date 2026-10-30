import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/dashboard/domain/daily_report_generator.dart';

final class DailyReportCompiler {
  static Future<String> compile({
    required AppDatabase database,
    required StatusSnapshot snapshot,
    required String date,
    required bool arabic,
  }) async {
    final employees = await (database.select(database.employees)..where((r) => r.archivedAt.isNull())).get();
    final empMap = {for (final e in employees) e.iqamaNo: e};

    final presentWorkers = snapshot.workers.where((w) => w.status == WorkerStatus.onSite).toList(growable: false);
    var companyCount = 0;
    final rentalMap = <String, int>{};

    for (final w in presentWorkers) {
      final emp = empMap[w.worker.code] ?? empMap[w.worker.employeeUid];
      final isRental = emp?.employmentType == 'rental';
      if (isRental) {
        final company = emp?.rentalCompany?.trim() ?? '';
        rentalMap[company] = (rentalMap[company] ?? 0) + 1;
      } else {
        companyCount++;
      }
    }

    final absentCount = snapshot.count(WorkerStatus.housingOnly) + snapshot.count(WorkerStatus.unknown);
    final unreviewedCount = snapshot.count(WorkerStatus.notRecorded);

    return DailyReportGenerator.generate(
      date: date,
      totalPresent: presentWorkers.length,
      totalAbsent: absentCount,
      totalUnreviewed: unreviewedCount,
      companyPresent: companyCount,
      rentalPresentByCompany: rentalMap,
      arabic: arabic,
    );
  }
}
