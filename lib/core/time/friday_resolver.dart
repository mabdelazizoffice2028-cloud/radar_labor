/// Pure Dart resolver for Friday business date detection.
abstract final class FridayResolver {
  static bool isFriday(String businessDate) {
    final parsed = DateTime.tryParse(businessDate);
    if (parsed == null) return false;
    return parsed.weekday == DateTime.friday;
  }
}
