import 'dart:convert';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/leaves/worker_leave.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_draft_store.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

abstract final class SiteAttendanceSourceResolver {
  static (AttendanceInitialSource, String?, int, Set<String>, Set<String>) resolve({
    required AttendanceDraftData? draft,
    required bool isSavedDay,
    required AttendanceBaseline baseline,
    required String date,
    required Set<String> savedPresentIds,
    required Map<String, Employee> activeById,
    required Map<String, Employee> employeesById,
  }) {
    var source = AttendanceInitialSource.empty;
    String? sourceDate;
    var skipped = 0;
    final selected = <String>{};
    final locked = <String>{};

    if (draft != null) {
      source = AttendanceInitialSource.draft;
      for (final id in draft.workerIds) {
        if (activeById.containsKey(id)) {
          selected.add(id);
        } else {
          skipped++;
        }
      }
    } else if (isSavedDay) {
      source = AttendanceInitialSource.savedDay;
      sourceDate = date;
      for (final id in savedPresentIds) {
        if (activeById.containsKey(id)) {
          selected.add(id);
        } else if (employeesById.containsKey(id)) {
          locked.add(id);
        }
      }
    } else if (baseline.kind == BaselineKind.previousDay) {
      source = AttendanceInitialSource.suggestion;
      sourceDate = baseline.date;
      selected.addAll(baseline.workerIds);
    }
    return (source, sourceDate, skipped, selected, locked);
  }

  static Set<String> parseOnLeaveIds(String? raw, String date) {
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => WorkerLeave.fromJson(e as Map<String, dynamic>))
          .where((l) => l.coversDate(date))
          .map((l) => l.employeeUid)
          .toSet();
    } on Exception {
      return const {};
    }
  }
}
