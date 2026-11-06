/// Deterministic Arabic/Latin name normalization and collation (PRD §8.7).
abstract final class NameCollation {
  static final RegExp _diacriticsAndTatweel = RegExp(
    r'[\u0640\u064B-\u065F\u0670]',
  );
  static final RegExp _whitespace = RegExp(r'\s+');

  /// Normalizes Arabic alef/hamza/ya/ta-marbuta, strips diacritics/tatweel, and lowercases Latin.
  static String sortKey(String name) {
    final stripped = name.replaceAll(_diacriticsAndTatweel, '');
    final buffer = StringBuffer();
    for (final rune in stripped.runes) {
      final char = switch (rune) {
        0x0621 || 0x0622 || 0x0623 || 0x0624 || 0x0625 || 0x0626 || 0x0671 => 'ا', // ء آ أ ؤ إ ئ ٱ -> ا
        0x0649 || 0x064A => 'ي', // ى ي -> ي
        0x0629 || 0x0647 => 'ه', // ة ه -> ه
        _ => String.fromCharCode(rune),
      };
      buffer.write(char);
    }
    return buffer.toString().toLowerCase().trim().replaceAll(_whitespace, ' ');
  }

  /// Compares two worker records by normalized display name, then code, then id.
  static int compareWorkers({
    required String nameA,
    required String codeA,
    required String idA,
    required String nameB,
    required String codeB,
    required String idB,
  }) {
    final byName = sortKey(nameA).compareTo(sortKey(nameB));
    if (byName != 0) return byName;
    final byCode = codeA.toLowerCase().compareTo(codeB.toLowerCase());
    if (byCode != 0) return byCode;
    return idA.compareTo(idB);
  }
}
