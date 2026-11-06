import 'package:radar_labor/core/constants/employment_constants.dart';

final class AttendanceBreakdownItem {
  const AttendanceBreakdownItem({
    required this.id,
    required this.code,
    required this.name,
    this.employmentType = EmploymentConstants.company,
    this.jobCategory = 'direct_labor',
    this.supplier,
  });

  final String id;
  final String code;
  final String name;
  final String employmentType;
  final String jobCategory;
  final String? supplier;

  bool get isRental => EmploymentConstants.isRental(employmentType);

  bool get isOperator {
    final cat = jobCategory.trim().toLowerCase();
    return cat == 'operator' ||
        cat.contains('operator') ||
        cat.contains('مشغل') ||
        cat.contains('معدات') ||
        cat.contains('equipment') ||
        cat.contains('سائق') ||
        cat.contains('driver');
  }
}

final class AttendanceBreakdown {
  const AttendanceBreakdown({
    required this.totalCount,
    required this.companyWorkers,
    required this.rentalWorkers,
    required this.laborWorkers,
    required this.operatorWorkers,
    required this.rentalBySupplier,
  });

  final int totalCount;
  final List<AttendanceBreakdownItem> companyWorkers;
  final List<AttendanceBreakdownItem> rentalWorkers;
  final List<AttendanceBreakdownItem> laborWorkers;
  final List<AttendanceBreakdownItem> operatorWorkers;
  final Map<String, List<AttendanceBreakdownItem>> rentalBySupplier;

  int get companyCount => companyWorkers.length;
  int get rentalCount => rentalWorkers.length;
  int get laborCount => laborWorkers.length;
  int get operatorCount => operatorWorkers.length;
}

abstract final class AttendanceBreakdownCalculator {
  static AttendanceBreakdown calculate(Iterable<AttendanceBreakdownItem> items) {
    final list = items.toList(growable: false);
    final company = <AttendanceBreakdownItem>[];
    final rental = <AttendanceBreakdownItem>[];
    final labor = <AttendanceBreakdownItem>[];
    final operators = <AttendanceBreakdownItem>[];
    final bySupplier = <String, List<AttendanceBreakdownItem>>{};

    for (final item in list) {
      if (item.isRental) {
        rental.add(item);
        final key = (item.supplier != null && item.supplier!.trim().isNotEmpty) ? item.supplier!.trim() : '';
        bySupplier.putIfAbsent(key, () => []).add(item);
      } else {
        company.add(item);
      }
      if (item.isOperator) {
        operators.add(item);
      } else {
        labor.add(item);
      }
    }
    return AttendanceBreakdown(
      totalCount: list.length,
      companyWorkers: List.unmodifiable(company),
      rentalWorkers: List.unmodifiable(rental),
      laborWorkers: List.unmodifiable(labor),
      operatorWorkers: List.unmodifiable(operators),
      rentalBySupplier: Map.unmodifiable(bySupplier),
    );
  }
}
