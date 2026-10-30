final class WhatsappWorkerItem {
  const WhatsappWorkerItem({
    required this.code,
    required this.name,
    this.employmentType = 'company',
    this.jobCategory = 'direct_labor',
  });

  final String code;
  final String name;
  final String employmentType;
  final String jobCategory;

  bool get isRental =>
      employmentType.trim().toLowerCase() == 'rental' ||
      employmentType.trim() == 'إيجار';

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
