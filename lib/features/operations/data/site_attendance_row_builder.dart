import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

abstract final class SiteAttendanceRowBuilder {
  static List<AttendanceRow> buildRows({
    required String teamId,
    required Map<String, Employee> activeById,
    required Map<String, Employee> employeesById,
    required Map<String, Team> teamsById,
    required Set<String> selectedIds,
    required Set<String> lockedIds,
    required bool arabic,
  }) {
    final rows = <AttendanceRow>[];
    final addedIds = <String>{};

    for (final emp in activeById.values) {
      if (emp.currentTeamId == teamId) {
        rows.add(AttendanceRow(
          worker: toWorker(emp),
          isPresent: selectedIds.contains(emp.employeeUid),
          origin: WorkerRowOrigin.member,
        ));
        addedIds.add(emp.employeeUid);
      }
    }

    for (final id in selectedIds) {
      if (addedIds.contains(id)) continue;
      final emp = activeById[id];
      if (emp == null) continue;
      final originTeam = emp.currentTeamId == null ? null : teamsById[emp.currentTeamId!];
      rows.add(AttendanceRow(
        worker: toWorker(emp),
        isPresent: true,
        origin: WorkerRowOrigin.guest,
        originTeamNameAr: originTeam?.nameAr,
        originTeamNameEn: originTeam?.nameEn,
      ));
      addedIds.add(id);
    }

    for (final id in lockedIds) {
      if (addedIds.contains(id)) continue;
      final emp = employeesById[id];
      if (emp == null) continue;
      rows.add(AttendanceRow(
        worker: toWorker(emp),
        isPresent: true,
        origin: WorkerRowOrigin.locked,
      ));
      addedIds.add(id);
    }

    rows.sort((a, b) => NameCollation.compareWorkers(
      nameA: a.worker.displayName(arabic: arabic), codeA: a.worker.code, idA: a.worker.id,
      nameB: b.worker.displayName(arabic: arabic), codeB: b.worker.code, idB: b.worker.id,
    ));
    return List.unmodifiable(rows);
  }

  static WorkerOption toWorker(Employee row) => WorkerOption(
    id: row.employeeUid, code: row.employeeCode, nameAr: row.fullNameAr, nameEn: row.fullNameEn,
    employmentType: row.employmentType, jobCategory: row.jobCategory,
  );
}
