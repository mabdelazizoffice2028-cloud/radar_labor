final class WorkerSearchFilter {
  static final RegExp _digitsFourOrMore = RegExp(r'^\d{4,}$');

  static bool matches({
    required String query,
    required String code,
    required String nameAr,
    String? nameEn,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    if (_digitsFourOrMore.hasMatch(q)) {
      return code.trim().endsWith(q);
    }

    final nAr = nameAr.toLowerCase();
    final nEn = (nameEn ?? '').toLowerCase();
    final c = code.toLowerCase();
    return nAr.contains(q) || nEn.contains(q) || c.contains(q);
  }
}
