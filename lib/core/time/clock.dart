import 'package:radar_labor/core/constants/app_constants.dart';

/// Injectable time source. The only place allowed to read the system clock.
abstract interface class Clock {
  DateTime nowUtc();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

extension RiyadhTime on DateTime {
  /// Wall-clock time in Riyadh, expressed as a UTC-flagged [DateTime].
  DateTime toRiyadh() => toUtc().add(TimeConstants.riyadhUtcOffset);
}
