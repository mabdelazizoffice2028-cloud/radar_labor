/// Pure Dart resolver determining whether a worker's job category represents
/// non-labor staff (Engineers, Safety, HR, PM, Admin, etc.) that the system
/// marks auto-present on site unless HR/Admin records an explicit absence.
abstract final class StaffCategoryResolver {
  static const _staffKeywords = [
    'staff',
    'engineer',
    'safety',
    'hr',
    'manager',
    'admin',
    'superintendent',
    'foreman',
    'timekeeper',
    'document controller',
    'مهندس',
    'سلامة',
    'إداري',
    'اداري',
    'مدير',
    'موارد بشرية',
    'مراقب',
  ];

  static bool isAutoPresentStaff(String category) {
    final norm = category.trim().toLowerCase();
    if (norm.isEmpty || norm == 'direct_labor' || norm == 'worker') {
      return false;
    }
    return _staffKeywords.any(norm.contains);
  }
}
