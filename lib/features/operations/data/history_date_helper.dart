/// Helper to format and calculate business date ranges for history queries.
final class HistoryDateHelper {
  const HistoryDateHelper();

  static String formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  static (String, String, String) computeRange({
    required String today,
    required int daysWindow,
  }) {
    final todayDt = DateTime.parse(today);
    final days = daysWindow < 1 ? 1 : daysWindow;
    final fromDt = todayDt.subtract(Duration(days: days - 1));
    final fromDate = formatDate(fromDt);
    final olderTo = formatDate(fromDt.subtract(const Duration(days: 1)));
    final olderFrom = formatDate(fromDt.subtract(const Duration(days: 365)));
    return (fromDate, olderFrom, olderTo);
  }
}
