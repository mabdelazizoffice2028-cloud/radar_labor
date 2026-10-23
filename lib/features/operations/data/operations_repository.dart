import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
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
  }) async {
    final previous = await events.readBusinessDate(date);
    final previousAbsences = _latestSetIds(
      previous.where(
        (event) =>
            event.type == EventType.housingAbsent &&
            event.housingId == housing.id,
      ),
    );
    final oldCheck = previous
        .where(
          (event) =>
              event.type == EventType.housingCheck &&
              event.housingId == housing.id,
        )
        .lastOrNull;
    final ids = {...previousAbsences, ...absentIds};
    await events.appendBatch([
      EventDraft(
        type: EventType.housingCheck,
        action: EventAction.set,
        businessDate: date,
        housingId: housing.id,
      ),
      for (final id in ids)
        EventDraft(
          type: EventType.housingAbsent,
          action: absentIds.contains(id) ? EventAction.set : EventAction.clear,
          businessDate: date,
          employeeUid: id,
          housingId: housing.id,
        ),
    ]);
    return HousingCheckUndo(
      date: date,
      housingId: housing.id,
      previousAbsences: Set.unmodifiable(previousAbsences),
      currentAbsences: Set.unmodifiable(absentIds),
      wasChecked: oldCheck?.action == EventAction.set,
    );
  }

  @override
  Future<void> undoHousingCheck(HousingCheckUndo undo) => events.appendBatch([
    EventDraft(
      type: EventType.housingCheck,
      action: undo.wasChecked ? EventAction.set : EventAction.clear,
      businessDate: undo.date,
      housingId: undo.housingId,
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
      ),
  ]);

  @override
  Future<SiteAttendanceUndo> saveSiteAttendance({
    required String date,
    required EntityOption team,
    required Set<String> presentIds,
  }) async {
    final previous = await events.readBusinessDate(date);
    final previousPresent = _latestSetIds(
      previous.where(
        (event) =>
            event.type == EventType.sitePresent && event.teamId == team.id,
      ),
    );
    final oldSubmission = previous
        .where(
          (event) =>
              event.type == EventType.siteSubmitted && event.teamId == team.id,
        )
        .lastOrNull;
    final ids = {...previousPresent, ...presentIds};
    await events.appendBatch([
      for (final id in ids)
        EventDraft(
          type: EventType.sitePresent,
          action: presentIds.contains(id) ? EventAction.set : EventAction.clear,
          businessDate: date,
          employeeUid: id,
          teamId: team.id,
        ),
      EventDraft(
        type: EventType.siteSubmitted,
        action: EventAction.set,
        businessDate: date,
        teamId: team.id,
        payload: {'presentCount': presentIds.length},
      ),
    ]);
    return SiteAttendanceUndo(
      date: date,
      teamId: team.id,
      previousPresent: Set.unmodifiable(previousPresent),
      currentPresent: Set.unmodifiable(presentIds),
      wasSubmitted: oldSubmission?.action == EventAction.set,
    );
  }

  @override
  Future<void> undoSiteAttendance(SiteAttendanceUndo undo) =>
      events.appendBatch([
        for (final id in {...undo.previousPresent, ...undo.currentPresent})
          EventDraft(
            type: EventType.sitePresent,
            action: undo.previousPresent.contains(id)
                ? EventAction.set
                : EventAction.clear,
            businessDate: undo.date,
            employeeUid: id,
            teamId: undo.teamId,
          ),
        EventDraft(
          type: EventType.siteSubmitted,
          action: undo.wasSubmitted ? EventAction.set : EventAction.clear,
          businessDate: undo.date,
          teamId: undo.teamId,
        ),
      ]);

  List<String> _latestSetIds(Iterable<LocalEvent> source) {
    final latest = <String, LocalEvent>{};
    for (final event in source) {
      final id = event.employeeUid;
      if (id == null) continue;
      final prior = latest[id];
      if (prior == null || event.deviceSeq > prior.deviceSeq) {
        latest[id] = event;
      }
    }
    return [
      for (final entry in latest.entries)
        if (entry.value.action == EventAction.set) entry.key,
    ];
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
