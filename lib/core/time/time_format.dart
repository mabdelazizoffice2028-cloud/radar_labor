import 'package:radar_labor/core/constants/operations_constants.dart';

/// Pure Riyadh time (UTC+3) formatting utilities using Latin digits (PRD §9.2, §17.1).
abstract final class RiyadhTimeFormat {
  static const Duration _riyadhOffset = Duration(
    hours: OperationsConstants.riyadhUtcOffsetHours,
  );

  /// Formats [utcTime] as `HH:mm` in Riyadh local time (`UTC+3`) using Latin digits `0-9`.
  static String hhMm(DateTime utcTime) {
    final riyadh = utcTime.toUtc().add(_riyadhOffset);
    final hh = riyadh.hour.toString().padLeft(2, '0');
    final mm = riyadh.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
