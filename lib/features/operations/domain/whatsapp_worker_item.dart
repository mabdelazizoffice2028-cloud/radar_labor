import 'package:radar_labor/core/constants/employment_constants.dart';

final class WhatsappWorkerItem {
  const WhatsappWorkerItem({
    required this.code,
    required this.name,
    this.employmentType = EmploymentConstants.company,
    this.jobCategory = 'direct_labor',
    this.supplier,
  });

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
