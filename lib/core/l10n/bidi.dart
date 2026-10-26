/// Unicode bidirectional formatting markers and helpers (PRD §12.3).
abstract final class Bidi {
  /// Right-to-Left Mark (U+200F).
  static const String rlm = '\u200F';

  /// Left-to-Right Isolate (U+2066).
  static const String lri = '\u2066';

  /// Pop Directional Isolate (U+2069).
  static const String pdi = '\u2069';

  /// Wraps [value] in Left-to-Right Isolate (`U+2066 ... U+2069`).
  static String isolateLtr(String value) => '$lri$value$pdi';

  /// Prefixes [line] with Right-to-Left Mark (`U+200F`).
  static String rtlLine(String line) => '$rlm$line';

  /// Formats a signed delta (`+N` or `-N`) isolated for RTL when [arabic] is true.
  static String signedDelta(
    int value, {
    required bool arabic,
    required bool positive,
  }) {
    final text = positive ? '+$value' : '-$value';
    return arabic ? isolateLtr(text) : text;
  }
}
