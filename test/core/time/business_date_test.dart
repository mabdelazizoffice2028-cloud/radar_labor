import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/time/business_date.dart';

void main() {
  group('businessDateFor', () {
    test('beforeRiyadhCutoff_usesPreviousBusinessDate', () {
      expect(
        businessDateFor(DateTime.utc(2026, 10, 22, 23, 30)),
        '2026-10-22',
      );
    });

    test('atRiyadhCutoff_startsNewBusinessDate', () {
      expect(
        businessDateFor(DateTime.utc(2026, 10, 23, 0)),
        '2026-10-23',
      );
    });

    test('afterRiyadhMidnight_beforeCutoff_usesPreviousBusinessDate', () {
      expect(
        businessDateFor(DateTime.utc(2026, 10, 22, 23, 59)),
        '2026-10-22',
      );
    });

    test('utcDayBoundary_convertsToRiyadhDate', () {
      expect(businessDateFor(DateTime.utc(2026, 10, 23, 1)), '2026-10-23');
    });

    test('yearBoundary_usesWesternZeroPaddedDate', () {
      expect(businessDateFor(DateTime.utc(2026, 1, 1, 0)), '2026-01-01');
    });

    test('customCutoff_isHonored', () {
      expect(
        businessDateFor(DateTime.utc(2026, 10, 23, 0, 59), cutoffHour: 4),
        '2026-10-22',
      );
    });

    test('invalidCutoff_throws', () {
      expect(
        () => businessDateFor(DateTime.utc(2026), cutoffHour: 24),
        throwsArgumentError,
      );
    });
  });
}
