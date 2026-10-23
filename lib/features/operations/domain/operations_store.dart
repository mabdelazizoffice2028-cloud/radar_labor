import 'operations_models.dart';

/// Persistence boundary for the local housing and site workflows.
abstract interface class OperationsStore {
  Stream<List<EntityOption>> watchHousings();

  Stream<List<EntityOption>> watchTeams();

  Stream<List<WorkerOption>> watchHousingWorkers(String housingId);

  Stream<List<WorkerOption>> watchTeamWorkers(String teamId);

  Future<HousingCheckUndo> saveHousingCheck({
    required String date,
    required EntityOption housing,
    required Set<String> absentIds,
  });

  Future<void> undoHousingCheck(HousingCheckUndo undo);

  Future<SiteAttendanceUndo> saveSiteAttendance({
    required String date,
    required EntityOption team,
    required Set<String> presentIds,
  });

  Future<void> undoSiteAttendance(SiteAttendanceUndo undo);
}
