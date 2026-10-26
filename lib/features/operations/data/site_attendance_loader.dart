import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_draft_store.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

/// Helper that loads and assembles smart daily check-in rows and baselines.
final class SiteAttendanceLoader {
  const SiteAttendanceLoader({
    required this.database,
    required this.events,
    required this.draftStore,
  });

  final AppDatabase database;
  final EventRepository events;
  final AttendanceDraftStore draftStore;

  Future<LoadedSiteAttendanceDay> load({
    required EntityOption team,
    required String date,
    required String today,
    required bool arabic,
  }) async {
    await draftStore.cleanupExpiredDrafts(todayBusinessDate: today);

    final allEmployees = await database.select(database.employees).get();
    final allTeams = await database.select(database.teams).get();
    final teamsById = {for (final t in allTeams) t.teamId: t};
    final employeesById = {for (final e in allEmployees) e.employeeUid: e};
    final activeById = {
      for (final e in allEmployees)
        if (e.isActive) e.employeeUid: e,
    };

    final dayEvents = await events.readBusinessDate(date);
    final dayLedger = AttendanceLedger(dayEvents);
    final isSavedDay = dayLedger.isSiteSubmitted(team.id);
    final savedPresentIds = dayLedger.presentWorkerIdsForTeam(team.id);

    final baseline = isSavedDay
        ? AttendanceBaseline(
            kind: BaselineKind.lastSave,
            date: date,
            workerIds: Set.unmodifiable(savedPresentIds),
          )
        : await _findPreviousSubmittedBaseline(
            teamId: team.id,
            date: date,
            activeById: activeById,
          );

    final draft = await draftStore.readDraft(teamId: team.id, date: date);

    var initialSource = AttendanceInitialSource.empty;
    String? initialSourceDate;
    var skippedDraftCount = 0;
    final selectedIds = <String>{};
    final lockedIds = <String>{};

    if (draft != null) {
      initialSource = AttendanceInitialSource.draft;
      for (final id in draft.workerIds) {
        if (activeById.containsKey(id)) {
          selectedIds.add(id);
        } else {
          skippedDraftCount++;
        }
      }
    } else if (isSavedDay) {
      initialSource = AttendanceInitialSource.savedDay;
      initialSourceDate = date;
      for (final id in savedPresentIds) {
        if (activeById.containsKey(id)) {
          selectedIds.add(id);
        } else if (employeesById.containsKey(id)) {
          lockedIds.add(id);
        }
      }
    } else if (baseline.kind == BaselineKind.previousDay) {
      initialSource = AttendanceInitialSource.suggestion;
      initialSourceDate = baseline.date;
      selectedIds.addAll(baseline.workerIds);
    }

    final rows = _buildRows(
      teamId: team.id,
      activeById: activeById,
      employeesById: employeesById,
      teamsById: teamsById,
      selectedIds: selectedIds,
      lockedIds: lockedIds,
      arabic: arabic,
    );

    return LoadedSiteAttendanceDay(
      team: team,
      date: date,
      isPastDate: date.compareTo(today) < 0,
      rows: rows,
      baseline: baseline,
      initialSource: initialSource,
      initialSourceDate: initialSourceDate,
      skippedDraftCount: skippedDraftCount,
    );
  }

  Future<AttendanceBaseline> _findPreviousSubmittedBaseline({
    required String teamId,
    required String date,
    required Map<String, Employee> activeById,
  }) async {
    final target = DateTime.parse(date);
    final fromDate = _formatDate(
      target.subtract(
        const Duration(days: OperationsConstants.suggestionLookbackDays),
      ),
    );
    final toDate = _formatDate(target.subtract(const Duration(days: 1)));
    final rangeEvents = await events.readBusinessDateRange(
      fromDate: fromDate,
      toDate: toDate,
    );
    if (rangeEvents.isEmpty) {
      return const AttendanceBaseline(kind: BaselineKind.none);
    }

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

  List<AttendanceRow> _buildRows({
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
        rows.add(
          AttendanceRow(
            worker: _toWorker(emp),
            isPresent: selectedIds.contains(emp.employeeUid),
            origin: WorkerRowOrigin.member,
          ),
        );
        addedIds.add(emp.employeeUid);
      }
    }

    for (final id in selectedIds) {
      if (addedIds.contains(id)) continue;
      final emp = activeById[id];
      if (emp == null) continue;
      final originTeam = emp.currentTeamId == null
          ? null
          : teamsById[emp.currentTeamId!];
      rows.add(
        AttendanceRow(
          worker: _toWorker(emp),
          isPresent: true,
          origin: WorkerRowOrigin.guest,
          originTeamNameAr: originTeam?.nameAr,
          originTeamNameEn: originTeam?.nameEn,
        ),
      );
      addedIds.add(id);
    }

    for (final id in lockedIds) {
      if (addedIds.contains(id)) continue;
      final emp = employeesById[id];
      if (emp == null) continue;
      rows.add(
        AttendanceRow(
          worker: _toWorker(emp),
          isPresent: true,
          origin: WorkerRowOrigin.locked,
        ),
      );
      addedIds.add(id);
    }

    rows.sort(
      (a, b) => NameCollation.compareWorkers(
        nameA: a.worker.displayName(arabic: arabic),
        codeA: a.worker.code,
        idA: a.worker.id,
        nameB: b.worker.displayName(arabic: arabic),
        codeB: b.worker.code,
        idB: b.worker.id,
      ),
    );
    return List.unmodifiable(rows);
  }

  static WorkerOption _toWorker(Employee row) => WorkerOption(
    id: row.employeeUid,
    code: row.employeeCode,
    nameAr: row.fullNameAr,
    nameEn: row.fullNameEn,
  );

  static String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}
