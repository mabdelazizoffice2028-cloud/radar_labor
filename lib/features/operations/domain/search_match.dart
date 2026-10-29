/// A run of text that either matches the active search query or not.
typedef SearchTextSegment = ({String text, bool matched});

/// Pure search-match splitting used to highlight query hits in worker rows.
abstract final class SearchMatch {
  /// Splits [text] into segments, flagging every case-insensitive [query] hit.
  /// Returns a single unmatched segment when there is nothing to highlight.
  static List<SearchTextSegment> split(String text, String query) {
    final needle = query.trim().toLowerCase();
    final haystack = text.toLowerCase();
    if (needle.isEmpty || haystack.length != text.length) {
      return [(text: text, matched: false)];
    }
    final segments = <SearchTextSegment>[];
    var cursor = 0;
    while (true) {
      final hit = haystack.indexOf(needle, cursor);
      if (hit < 0) break;
      if (hit > cursor) {
        segments.add((text: text.substring(cursor, hit), matched: false));
      }
      segments.add((
        text: text.substring(hit, hit + needle.length),
        matched: true,
      ));
      cursor = hit + needle.length;
    }
    if (cursor < text.length) {
      segments.add((text: text.substring(cursor), matched: false));
    }
    return segments.isEmpty ? [(text: text, matched: false)] : segments;
  }
}
