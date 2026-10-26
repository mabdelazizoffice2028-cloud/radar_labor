import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/site_attendance_loader.dart';
import 'package:radar_labor/features/operations/data/site_attendance_save_builder.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_draft_store.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

/// Persistence implementation of [SiteAttendanceStore] (PRD §8, §9, §10).
final class SiteAttendanceRepository implements SiteAttendanceStore {
  const SiteAttendanceRepository({
    required this.database,
    required this.events,
    required this.draftStore,
    required this.clock,
  });

  final AppDatabase database;
  final EventRepository events;
  final AttendanceDraftStore draftStore;
  final Clock clock;

  SiteAttendanceLoader get _loader => SiteAttendanceLoader(
    database: database,
    events: events,
    draftStore: draftStore,
  );

  @override
  String currentBusinessDate() => businessDateFor(clock.nowUtc());

  @override
  Stream<List<EntityOption>> watchScopedTeams(Set<String> allowedTeamIds) =>
      (database.select(
        database.teams,
      )..where((row) => row.isActive)).watch().map(
        (rows) => List.unmodifiable([
          for (final r in rows)
            if (allowedTeamIds.contains(r.teamId))
              EntityOption(id: r.teamId, nameAr: r.nameAr, nameEn: r.nameEn),
        ]),
      );

  @override
  Future<LoadedSiteAttendanceDay> loadDay({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required EntityOption team,
    required String date,
    required bool arabic,
  }) async {
    _guardRecord(actor: actor, scope: scope, teamId: team.id, date: date);
    return _loader.load(
      team: team,
      date: date,
      today: currentBusinessDate(),
      arabic: arabic,
    );
  }

  @override
  Future<List<CrossTeamWorkerOption>> searchCrossTeamWorkers({
    required String query,
    required Set<String> excludeWorkerIds,
    required bool arabic,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < OperationsConstants.crossTeamSearchMinChars) {
      return const <CrossTeamWorkerOption>[];
    }
    final activeEmployees = await (database.select(
      database.employees,
    )..where((row) => row.isActive.equals(true))).get();
    final allTeams = await database.select(database.teams).get();
    final teamsById = {for (final t in allTeams) t.teamId: t};

    final qNorm = NameCollation.sortKey(trimmed);
    final qCode = trimmed.toLowerCase();

    final matches = <CrossTeamWorkerOption>[];
    for (final emp in activeEmployees) {
      if (excludeWorkerIds.contains(emp.employeeUid)) continue;
      final matchAr = NameCollation.sortKey(emp.fullNameAr).contains(qNorm);
      final matchEn = NameCollation.sortKey(emp.fullNameEn ?? '')
          .contains(qNorm);
      final matchCode = emp.employeeCode.toLowerCase().contains(qCode);
      if (!matchAr && !matchEn && !matchCode) continue;

      final team = emp.currentTeamId == null
          ? null
          : teamsById[emp.currentTeamId!];
      matches.add(
        CrossTeamWorkerOption(
          worker: _toWorker(emp),
          teamId: emp.currentTeamId,
          teamNameAr: team?.nameAr,
          teamNameEn: team?.nameEn,
        ),
      );
    }

    matches.sort((a, b) => _cmp(a.worker, b.worker, arabic));
    return List.unmodifiable(
      matches.take(OperationsConstants.crossTeamSearchMaxResults),
    );
  }

  @override
  Future<PreparedSiteSave> prepareSave({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required EntityOption team,
    required String date,
    required List<AttendanceRow> rows,
    required AttendanceBaseline baseline,
    required bool arabic,
  }) async {
    _guardRecord(actor: actor, scope: scope, teamId: team.id, date: date);
    final selectedIds = {
      for (final row in rows)
        if (!row.isLocked && row.isPresent) row.worker.id,
    };

    final allEmployees = await database.select(database.employees).get();
    final workersById = {
      for (final emp in allEmployees) emp.employeeUid: _toWorker(emp),
    };
    final activeIds = {
      for (final emp in allEmployees)
        if (emp.isActive) emp.employeeUid,
    };
    final unavailable = selectedIds.difference(activeIds);
    if (unavailable.isNotEmpty) {
      throw OperationException(WorkersUnavailable(unavailable));
    }

    final diff = AttendanceDiff.compute(
      baseline: baseline,
      selectedIds: selectedIds,
      workersById: workersById,
      arabic: arabic,
    );

    final dayEvents = await events.readBusinessDate(date);
    final allTeams = await database.select(database.teams).get();
    final teamsById = {
      for (final t in allTeams)
        t.teamId: EntityOption(
          id: t.teamId,
          nameAr: t.nameAr,
          nameEn: t.nameEn,
        ),
    };
    final conflicts = ConflictDetector.detect(
      ledger: AttendanceLedger(dayEvents),
      currentTeamId: team.id,
      selectedWorkerIds: selectedIds,
      workersById: workersById,
      teamsById: teamsById,
      arabic: arabic,
    );

    return PreparedSiteSave(
      team: team,
      date: date,
      selectedWorkerIds: Set.unmodifiable(selectedIds),
      diff: diff,
      conflicts: conflicts,
      workersById: Map.unmodifiable(workersById),
    );
  }

  @override
  Future<({LedgerUndoPlan undoPlan, AttendanceSummary summary})> save({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required PreparedSiteSave prepared,
    required Map<String, ConflictResolutionChoice> resolutions,
    required bool arabic,
  }) async {
    _guardRecord(
      actor: actor,
      scope: scope,
      teamId: prepared.team.id,
      date: prepared.date,
    );

    for (final c in prepared.conflicts) {
      if (!resolutions.containsKey(c.worker.id)) {
        throw const OperationException(UnresolvedConflicts());
      }
    }

    final activeRows = await (database.select(
      database.employees,
    )..where((row) => row.isActive.equals(true))).get();
    final activeIds = {for (final emp in activeRows) emp.employeeUid};

    final dayEvents = await events.readBusinessDate(prepared.date);
    final built = SiteAttendanceSaveBuilder.build(
      prepared: prepared,
      resolutions: resolutions,
      ledger: AttendanceLedger(dayEvents),
      actorUserId: actor.userId,
    );

    final unavailable = built.finalSelectedIds.difference(activeIds);
    if (unavailable.isNotEmpty) {
      throw OperationException(WorkersUnavailable(unavailable));
    }

    await events.appendBatch(built.drafts);
    await draftStore.deleteDraft(teamId: prepared.team.id, date: prepared.date);

    final summaryWorkers = [
      for (final emp in activeRows)
        if (emp.currentTeamId == prepared.team.id ||
            built.finalSelectedIds.contains(emp.employeeUid))
          _toWorker(emp),
    ]..sort((a, b) => _cmp(a, b, arabic));
    final summary = AttendanceSummary.siteAttendance(
      date: prepared.date,
      team: prepared.team,
      workers: summaryWorkers,
      presentIds: built.finalSelectedIds,
      arabic: arabic,
      strings: AttendanceMessageStrings.fromLanguage(arabic: arabic),
    );
    return (undoPlan: built.undoPlan, summary: summary);
  }

  @override
  Future<void> undo({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
    required LedgerUndoPlan plan,
  }) async {
    _guardRecord(
      actor: actor,
      scope: scope,
      teamId: teamId,
      date: plan.businessDate,
    );
    if (plan.entries.isEmpty) return;
    await events.appendBatch(
      SiteAttendanceSaveBuilder.buildUndoDrafts(
        plan: plan,
        actorUserId: actor.userId,
      ),
    );
  }

  int _cmp(WorkerOption a, WorkerOption b, bool ar) =>
      NameCollation.compareWorkers(
        nameA: a.displayName(arabic: ar),
        codeA: a.code,
        idA: a.id,
        nameB: b.displayName(arabic: ar),
        codeB: b.code,
        idB: b.id,
      );

  void _guardRecord({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
    required String date,
  }) => ScopeGuard.guardSiteRecord(
    actor: actor,
    scope: scope,
    teamId: teamId,
    date: date,
    todayBusinessDate: currentBusinessDate(),
  );

  static WorkerOption _toWorker(Employee e) => WorkerOption(
    id: e.employeeUid,
    code: e.employeeCode,
    nameAr: e.fullNameAr,
    nameEn: e.fullNameEn,
  );
}
