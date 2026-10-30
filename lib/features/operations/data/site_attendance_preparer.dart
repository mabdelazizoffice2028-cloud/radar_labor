import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

final class SiteAttendancePreparer {
  const SiteAttendancePreparer({required this.database, required this.events});
  final AppDatabase database;
  final EventRepository events;

  Future<List<CrossTeamWorkerOption>> searchCrossTeamWorkers({
    required String query, required Set<String> excludeWorkerIds, required bool arabic,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < OperationsConstants.crossTeamSearchMinChars) return const [];
    final activeEmployees = await (database.select(database.employees)..where((r) => r.archivedAt.isNull())).get();
    final allTeams = await database.select(database.teams).get();
    final teamsById = {for (final t in allTeams) t.teamId: t};
    final qNorm = NameCollation.sortKey(trimmed);
    final qCode = trimmed.toLowerCase();
    final matches = <CrossTeamWorkerOption>[];

    for (final emp in activeEmployees) {
      if (excludeWorkerIds.contains(emp.employeeUid)) continue;
      final mAr = NameCollation.sortKey(emp.fullNameAr).contains(qNorm);
      final mEn = NameCollation.sortKey(emp.fullNameEn ?? '').contains(qNorm);
      final mCode = emp.employeeCode.toLowerCase().contains(qCode);
      if (!mAr && !mEn && !mCode) continue;
      final team = emp.currentTeamId == null ? null : teamsById[emp.currentTeamId!];
      matches.add(CrossTeamWorkerOption(
        worker: toWorker(emp), teamId: emp.currentTeamId, teamNameAr: team?.nameAr, teamNameEn: team?.nameEn,
      ));
    }
    matches.sort((a, b) => cmpWorker(a.worker, b.worker, arabic));
    return List.unmodifiable(matches.take(OperationsConstants.crossTeamSearchMaxResults));
  }

  Future<PreparedSiteSave> prepareSave({
    required EntityOption team, required String date,
    required List<AttendanceRow> rows, required AttendanceBaseline baseline, required bool arabic,
  }) async {
    final selectedIds = {for (final row in rows) if (!row.isLocked && row.isPresent) row.worker.id};
    final allEmployees = await database.select(database.employees).get();
    final workersById = {for (final emp in allEmployees) emp.employeeUid: toWorker(emp)};
    final activeIds = {for (final emp in allEmployees) if (emp.isActive) emp.employeeUid};
    final unavailable = selectedIds.difference(activeIds);
    if (unavailable.isNotEmpty) throw OperationException(WorkersUnavailable(unavailable));

    final diff = AttendanceDiff.compute(baseline: baseline, selectedIds: selectedIds, workersById: workersById, arabic: arabic);
    final dayEvents = await events.readBusinessDate(date);
    final allTeams = await database.select(database.teams).get();
    final teamsById = {for (final t in allTeams) t.teamId: EntityOption(id: t.teamId, nameAr: t.nameAr, nameEn: t.nameEn)};
    final conflicts = ConflictDetector.detect(
      ledger: AttendanceLedger(dayEvents), currentTeamId: team.id,
      selectedWorkerIds: selectedIds, workersById: workersById, teamsById: teamsById, arabic: arabic,
    );
    return PreparedSiteSave(
      team: team, date: date, selectedWorkerIds: Set.unmodifiable(selectedIds),
      diff: diff, conflicts: conflicts, workersById: Map.unmodifiable(workersById),
    );
  }

  static WorkerOption toWorker(Employee e) => WorkerOption(
    id: e.employeeUid, code: e.employeeCode, nameAr: e.fullNameAr,
    nameEn: e.fullNameEn, employmentType: e.employmentType, jobCategory: e.jobCategory,
  );

  static int cmpWorker(WorkerOption a, WorkerOption b, bool ar) => NameCollation.compareWorkers(
    nameA: a.displayName(arabic: ar), codeA: a.code, idA: a.id,
    nameB: b.displayName(arabic: ar), codeB: b.code, idB: b.id,
  );
}
