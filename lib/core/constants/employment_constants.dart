abstract final class EmploymentConstants {
  static const String company = 'company';
  static const String rental = 'rental';

  static bool isRental(String? type) {
    if (type == null) return false;
    final t = type.trim().toLowerCase();
    return t == 'rental' || t == 'إيجار' || t == 'ايجار';
  }

  static String normalize(String? type) => isRental(type) ? rental : company;
}
