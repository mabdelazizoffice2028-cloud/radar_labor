import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';

abstract final class SiteAttendanceBaselineFinder {
  static Future<AttendanceBaseline> findPreviousSubmitted({
    required EventRepository events,
    required String teamId,
    required String date,
    required Map<String, Employee> activeById,
  }) async {
    final target = DateTime.parse(date);
    final fromDate = _formatDate(
      target.subtract(const Duration(days: OperationsConstants.suggestionLookbackDays)),
    );
    final toDate = _formatDate(target.subtract(const Duration(days: 1)));
    final rangeEvents = await events.readBusinessDateRange(fromDate: fromDate, toDate: toDate);
    if (rangeEvents.isEmpty) return const AttendanceBaseline(kind: BaselineKind.none);

    final byDate = <String, List<LocalEvent>>{};
    for (final event in rangeEvents) {
      byDate.putIfAbsent(event.businessDate, () => <LocalEvent>[]).add(event);
    }
    final sortedDates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final candidateDate in sortedDates) {
      final ledger = AttendanceLedger(byDate[candidateDate]!);
      if (ledger.isSiteSubmitted(teamId)) {
        final rawIds = ledger.presentWorkerIdsForTeam(teamId);
        final activeIds = rawIds.where(activeById.containsKey).toSet();
        return AttendanceBaseline(
          kind: BaselineKind.previousDay,
          date: candidateDate,
          workerIds: Set.unmodifiable(activeIds),
        );
      }
    }
    return const AttendanceBaseline(kind: BaselineKind.none);
  }

  static String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
