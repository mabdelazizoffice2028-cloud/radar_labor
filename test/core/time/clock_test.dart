import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/time/clock.dart';

import '../../support/fixed_clock.dart';

void main() {
  test('toRiyadh_afterUtcMidnightShift_crossesIntoNextRiyadhDay', () {
    final utc = DateTime.utc(2026, 10, 23, 21, 30);
    expect(utc.toRiyadh(), DateTime.utc(2026, 10, 24, 0, 30));
  });

  test('toRiyadh_localInput_isNormalizedThroughUtc', () {
    final utc = DateTime.utc(2026, 1, 1, 0, 0);
    expect(utc.toLocal().toRiyadh(), DateTime.utc(2026, 1, 1, 3, 0));
  });

  test('fixedClock_returnsInjectedInstant', () {
    final instant = DateTime.utc(2026, 10, 23);
    expect(FixedClock(instant).nowUtc(), instant);
  });
}
