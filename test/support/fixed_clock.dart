import 'package:radar_labor/core/time/clock.dart';

final class FixedClock implements Clock {
  const FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime nowUtc() => _now;
}
