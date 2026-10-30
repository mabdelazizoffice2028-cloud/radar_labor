import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/time/friday_resolver.dart';

export 'package:radar_labor/core/time/friday_resolver.dart';

/// Returns the Riyadh business date for an instant, using the configured
/// start-of-day cutoff and a fixed UTC+3 offset.
String businessDateFor(
  DateTime instant, {
  int cutoffHour = TimeConstants.defaultDayCutoffHour,
}) {
  if (cutoffHour < 0 || cutoffHour > 23) {
    throw ArgumentError.value(
      cutoffHour,
      'cutoffHour',
      'must be between 0 and 23',
    );
  }

  final riyadhWallTime = instant.toUtc().add(TimeConstants.riyadhUtcOffset);
  final calendarDate = DateTime.utc(
    riyadhWallTime.year,
    riyadhWallTime.month,
    riyadhWallTime.day,
  );
  final businessDate = riyadhWallTime.hour < cutoffHour
      ? calendarDate.subtract(const Duration(days: 1))
      : calendarDate;
  final year = businessDate.year.toString().padLeft(4, '0');
  final month = businessDate.month.toString().padLeft(2, '0');
  final day = businessDate.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Returns true if the Riyadh business date represents a Friday.
bool isFridayBusinessDate(String businessDate) => FridayResolver.isFriday(businessDate);
