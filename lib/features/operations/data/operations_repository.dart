import 'package:drift/drift.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/features/operations/data/operations_dev_tools.dart';
import 'package:radar_labor/features/operations/data/operations_housing_operations.dart';
import 'package:radar_labor/features/operations/data/operations_site_operations.dart';
import 'package:radar_labor/features/operations/data/operations_undo_executor.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/operations_store.dart';

final class OperationsRepository implements OperationsStore {
  OperationsRepository({required this.database, required this.events})
    : _housing = OperationsHousingOperations(events),
      _site = OperationsSiteOperations(events);

  final AppDatabase database;
  final EventRepository events;
  final OperationsHousingOperations _housing;
  final OperationsSiteOperations _site;

  @override
  Stream<List<EntityOption>> watchHousings() => Stream.value(const [
    EntityOption(
      id: HousingConstants.defaultHousingId,
      nameAr: HousingConstants.defaultHousingNameAr,
      nameEn: HousingConstants.defaultHousingName,
    ),
  ]);

  @override
  Stream<List<EntityOption>> watchTeams() =>
      (database.select(database.teams)..where((r) => r.isActive)).watch().map(
        (rows) => List.unmodifiable(rows.map((r) => EntityOption(id: r.teamId, nameAr: r.nameAr, nameEn: r.nameEn))),
      );

  @override
  Stream<List<WorkerOption>> watchHousingWorkers(String housingId) =>
      (database.select(database.employees)..where((r) => r.archivedAt.isNull())).watch().map(_toWorkers);

  @override
  Future<List<WorkerOption>> getHousingWorkers(String housingId) async {
    final rows = await (database.select(database.employees)..where((r) => r.archivedAt.isNull())).get();
    return _toWorkers(rows);
  }

  @override
  Stream<List<WorkerOption>> watchTeamWorkers(String teamId) =>
      (database.select(database.employees)..where((r) => r.archivedAt.isNull() & r.currentTeamId.equals(teamId))).watch().map(_toWorkers);

  @override
  Future<HousingCheckUndo> saveHousingCheck({required String date, required EntityOption housing, required Set<String> absentIds, required String actorUserId}) =>
      _housing.save(date: date, housing: housing, absentIds: absentIds, actorUserId: actorUserId);

  @override
  Future<void> undoHousingCheck(HousingCheckUndo undo, {required String actorUserId}) =>
      _housing.undo(undo, actorUserId: actorUserId);

  @override
  Future<SiteAttendanceUndo> saveSiteAttendance({required String date, required EntityOption team, required Set<String> presentIds, required String actorUserId}) =>
      _site.save(date: date, team: team, presentIds: presentIds, actorUserId: actorUserId);

  @override
  Future<void> undoSiteAttendance(SiteAttendanceUndo undo, {required String actorUserId}) =>
      _site.undo(undo, actorUserId: actorUserId);

  @override
  Future<void> clearTestData() => OperationsDevTools.clearTestData(database);

  Future<void> executeUndoPlan(LedgerUndoPlan plan, {required String actorUserId}) =>
      OperationsUndoExecutor.execute(events, plan, actorUserId: actorUserId);

  List<WorkerOption> _toWorkers(List<Employee> rows) => List.unmodifiable(
    rows.map((r) => WorkerOption(id: r.employeeUid, code: r.employeeCode, nameAr: r.fullNameAr, nameEn: r.fullNameEn)),
  );
}
