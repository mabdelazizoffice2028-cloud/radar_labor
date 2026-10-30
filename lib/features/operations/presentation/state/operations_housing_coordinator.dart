import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/operations_store.dart';
import 'package:radar_labor/features/operations/presentation/state/prepared_operations.dart';

abstract final class OperationsHousingCoordinator {
  static Future<PreparedHousingCheck> prepare({
    required OperationsStore store,
    required Clock clock,
    required EntityOption housing,
    required Set<String> absentIds,
    required bool arabic,
  }) async {
    final date = businessDateFor(clock.nowUtc());
    final workers = await store.getHousingWorkers(housing.id, date: date);
    return PreparedHousingCheck(
      housing: housing,
      date: date,
      summary: AttendanceSummary.housingCheck(
        housing: housing,
        date: date,
        workers: workers,
        absentIds: absentIds,
        arabic: arabic,
        strings: AttendanceMessageStrings.fromLanguage(arabic: arabic),
      ),
    );
  }
}
