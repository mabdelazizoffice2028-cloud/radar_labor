import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/operations_store.dart';

/// Owns local reference queries and daily event transactions for operations.
final class OperationsRepository implements OperationsStore {
  const OperationsRepository({required this.database, required this.events});

  final AppDatabase database;
  final EventRepository events;

  @override
  Stream<List<EntityOption>> watchHousings() =>
      (database.select(
        database.housings,
      )..where((row) => row.isActive)).watch().map(
        (rows) => List.unmodifiable(
          rows.map(
            (row) => EntityOption(
              id: row.housingId,
              nameAr: row.nameAr,
              nameEn: row.nameEn,
            ),
          ),
        ),
      );

  @override
  Stream<List<EntityOption>> watchTeams() =>
      (database.select(
        database.teams,
      )..where((row) => row.isActive)).watch().map(
        (rows) => List.unmodifiable(
          rows.map(
            (row) => EntityOption(
              id: row.teamId,
              nameAr: row.nameAr,
              nameEn: row.nameEn,
            ),
          ),
        ),
      );

  @override
  Stream<List<WorkerOption>> watchHousingWorkers(String housingId) =>
      (database.select(database.employees)..where(
            (row) =>
                row.isActive.equals(true) & row.housingId.equals(housingId),
          ))
          .watch()
          .map(_toWorkers);

  @override
  Stream<List<WorkerOption>> watchTeamWorkers(String teamId) =>
      (database.select(database.employees)..where(
            (row) =>
                row.isActive.equals(true) & row.currentTeamId.equals(teamId),
          ))
          .watch()
          .map(_toWorkers);

  @override
  Future<HousingCheckUndo> saveHousingCheck({
    required String date,
    required EntityOption housing,
    required Set<String> absentIds,
    required String actorUserId,
  }) async {
    final previous = await events.readBusinessDate(date);
    final ledger = AttendanceLedger(previous);
    final previousAbsences = ledger.absentWorkerIdsForHousing(housing.id);
    final wasChecked = ledger.isHousingChecked(housing.id);
    final ids = {...previousAbsences, ...absentIds};
    await events.appendBatch([
      EventDraft(
        type: EventType.housingCheck,
        action: EventAction.set,
        businessDate: date,
        housingId: housing.id,
        userId: actorUserId,
      ),
      for (final id in ids)
        EventDraft(
          type: EventType.housingAbsent,
          action: absentIds.contains(id) ? EventAction.set : EventAction.clear,
          businessDate: date,
          employeeUid: id,
          housingId: housing.id,
          userId: actorUserId,
        ),
    ]);
    return HousingCheckUndo(
      date: date,
      housingId: housing.id,
      previousAbsences: Set.unmodifiable(previousAbsences),
      currentAbsences: Set.unmodifiable(absentIds),
      wasChecked: wasChecked,
    );
  }

  @override
  Future<void> undoHousingCheck(
    HousingCheckUndo undo, {
    required String actorUserId,
  }) => events.appendBatch([
    EventDraft(
      type: EventType.housingCheck,
      action: undo.wasChecked ? EventAction.set : EventAction.clear,
      businessDate: undo.date,
      housingId: undo.housingId,
      userId: actorUserId,
    ),
    for (final id in {...undo.previousAbsences, ...undo.currentAbsences})
      EventDraft(
        type: EventType.housingAbsent,
        action: undo.previousAbsences.contains(id)
            ? EventAction.set
            : EventAction.clear,
        businessDate: undo.date,
        employeeUid: id,
        housingId: undo.housingId,
        userId: actorUserId,
      ),
  ]);

  @override
  Future<SiteAttendanceUndo> saveSiteAttendance({
    required String date,
    required EntityOption team,
    required Set<String> presentIds,
    required String actorUserId,
  }) async {
    final previous = await events.readBusinessDate(date);
    final ledger = AttendanceLedger(previous);
    final previousPresent = ledger.presentWorkerIdsForTeam(team.id);
    final wasSubmitted = ledger.isSiteSubmitted(team.id);
    final ids = {...previousPresent, ...presentIds};
    await events.appendBatch([
      for (final id in ids)
        EventDraft(
          type: EventType.sitePresent,
          action: presentIds.contains(id) ? EventAction.set : EventAction.clear,
          businessDate: date,
          employeeUid: id,
          teamId: team.id,
          userId: actorUserId,
        ),
      EventDraft(
        type: EventType.siteSubmitted,
        action: EventAction.set,
        businessDate: date,
        teamId: team.id,
        userId: actorUserId,
        payload: {'presentCount': presentIds.length},
      ),
    ]);
    return SiteAttendanceUndo(
      date: date,
      teamId: team.id,
      previousPresent: Set.unmodifiable(previousPresent),
      currentPresent: Set.unmodifiable(presentIds),
      wasSubmitted: wasSubmitted,
    );
  }

  @override
  Future<void> undoSiteAttendance(
    SiteAttendanceUndo undo, {
    required String actorUserId,
  }) => events.appendBatch([
    for (final id in {...undo.previousPresent, ...undo.currentPresent})
      EventDraft(
        type: EventType.sitePresent,
        action: undo.previousPresent.contains(id)
            ? EventAction.set
            : EventAction.clear,
        businessDate: undo.date,
        employeeUid: id,
        teamId: undo.teamId,
        userId: actorUserId,
      ),
    EventDraft(
      type: EventType.siteSubmitted,
      action: undo.wasSubmitted ? EventAction.set : EventAction.clear,
      businessDate: undo.date,
      teamId: undo.teamId,
      userId: actorUserId,
    ),
  ]);

  /// Executes a [LedgerUndoPlan] by appending compensating events stamped with [actorUserId].
  Future<void> executeUndoPlan(
    LedgerUndoPlan plan, {
    required String actorUserId,
  }) async {
    if (plan.entries.isEmpty) return;
    await events.appendBatch([
      for (final entry in plan.entries)
        EventDraft(
          type: entry.key.type,
          action: entry.restoreAction,
          businessDate: plan.businessDate,
          employeeUid: entry.key.employeeUid,
          teamId: entry.key.teamId,
          housingId: entry.key.housingId,
          userId: actorUserId,
          payload: {
            if (entry.key.type == EventType.resolution &&
                entry.resolutionKind != null)
              'kind': entry.resolutionKind!.key,
          },
        ),
    ]);
  }

  List<WorkerOption> _toWorkers(List<Employee> rows) => List.unmodifiable(
    rows.map(
      (row) => WorkerOption(
        id: row.employeeUid,
        code: row.employeeCode,
        nameAr: row.fullNameAr,
        nameEn: row.fullNameEn,
      ),
    ),
  );
}
