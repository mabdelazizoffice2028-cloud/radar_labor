final class EmploymentPeriod {
  const EmploymentPeriod(this.startDate, {this.endDate});

  final String startDate;
  final String? endDate;

  bool contains(String date) =>
      date.compareTo(startDate) >= 0 &&
      (endDate == null || date.compareTo(endDate!) <= 0);
}

final class WorkerProfile {
  const WorkerProfile({
    required this.employeeUid,
    required this.code,
    required this.fullName,
    required this.employmentPeriods,
    this.currentTeamId,
    this.housingId,
    this.isActive = true,
    this.jobCategory = 'direct_labor',
    this.isOnLeave = false,
  });

  final String employeeUid;
  final String code;
  final String fullName;
  final String? currentTeamId;
  final String? housingId;
  final bool isActive;
  final String jobCategory;
  final bool isOnLeave;
  final List<EmploymentPeriod> employmentPeriods;

  bool employedOn(String businessDate) =>
      employmentPeriods.isEmpty ||
      employmentPeriods.any((period) => period.contains(businessDate));
}
