import 'package:radar_labor/core/l10n/name_collation.dart';

final class WorkerSearchFilter {
  static bool matches({
    required String query,
    required String code,
    required String nameAr,
    String? nameEn,
    String? id,
    String? iqamaNo,
  }) {
    final rawTrimmed = query.trim();
    if (rawTrimmed.length < 2) return true;

    final qRawLower = rawTrimmed.toLowerCase();

    // Fast-path 1: Substring match in worker code
    if (code.toLowerCase().contains(qRawLower)) return true;

    // Fast-path 2: Substring match in Iqama (including last 4 digits)
    final iqama = (iqamaNo ?? id ?? '').trim().toLowerCase();
    if (iqama.isNotEmpty && iqama.contains(qRawLower)) return true;

    // Fast-path 3: Substring match in English name
    if (nameEn != null && nameEn.toLowerCase().contains(qRawLower)) return true;

    // Normalized Arabic match with unified collation
    final qNorm = NameCollation.sortKey(rawTrimmed);
    if (NameCollation.sortKey(nameAr).contains(qNorm)) return true;
    if (nameEn != null && NameCollation.sortKey(nameEn).contains(qNorm)) return true;

    return false;
  }
}
