import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart' as model;

final class StatusSnapshotWorkerBuilder {
  static List<model.WorkerProfile> buildProfiles({
    required List<Employee> employees,
    required List<EmploymentPeriod> periods,
    required bool arabic,
    Set<String> onLeaveIds = const {},
  }) {
    final periodGroups = <String, List<model.EmploymentPeriod>>{};
    for (final period in periods) {
      periodGroups
          .putIfAbsent(period.employeeUid, () => [])
          .add(model.EmploymentPeriod(period.startDate, endDate: period.endDate));
    }
    return employees.map((employee) {
      final name = (employee.fullNameEn != null && employee.fullNameEn!.trim().isNotEmpty)
          ? employee.fullNameEn!
          : employee.fullNameAr;
      return model.WorkerProfile(
        employeeUid: employee.employeeUid,
        code: employee.employeeCode,
        fullName: name,
        currentTeamId: employee.currentTeamId,
        housingId: employee.housingId,
        isActive: employee.isActive,
        jobCategory: employee.jobCategory,
        isOnLeave: onLeaveIds.contains(employee.employeeUid),
        employmentPeriods: List.unmodifiable(
          periodGroups[employee.employeeUid] ?? const [],
        ),
      );
    }).toList(growable: false);
  }
}
