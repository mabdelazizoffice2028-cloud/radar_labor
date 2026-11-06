import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/operations_store.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_housing_coordinator.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_site_coordinator.dart';
import 'package:radar_labor/features/operations/presentation/state/prepared_operations.dart';

export 'package:radar_labor/features/operations/presentation/state/prepared_operations.dart';

/// Coordinates daily operation rules while screens handle only presentation (BC-3).
final class OperationsController {
  OperationsController({
    required this.store, required this.clock, required this.actorUserId,
    required this.capabilities, this.allowedHousingIds = const [], this.allowedTeamIds = const [],
  });

  final OperationsStore store;
  final Clock clock;
  final String actorUserId;
  final RoleCapabilities capabilities;
  final List<String> allowedHousingIds;
  final List<String> allowedTeamIds;
  bool _isSavingHousing = false;
  bool _isSavingSite = false;

  bool get canHousing => capabilities.canRecordHousing;
  bool get canSite => capabilities.canRecordSite;
  bool _allowsHousing(String id) => canHousing && allowedHousingIds.contains(id);
  bool _allowsTeam(String id) => canSite && allowedTeamIds.contains(id);

  Stream<List<EntityOption>> watchHousings() =>
      store.watchHousings().map((items) => items.where((i) => _allowsHousing(i.id)).toList(growable: false));

  Stream<List<EntityOption>> watchTeams() =>
      store.watchTeams().map((items) => items.where((i) => _allowsTeam(i.id)).toList(growable: false));

  Stream<List<WorkerOption>> watchHousingWorkers(String housingId) =>
      _allowsHousing(housingId) ? store.watchHousingWorkers(housingId) : const Stream.empty();

  Stream<List<WorkerOption>> watchTeamWorkers(String teamId) =>
      _allowsTeam(teamId) ? store.watchTeamWorkers(teamId) : const Stream.empty();

  Future<PreparedHousingCheck> prepareHousingCheck({
    required EntityOption housing, required Set<String> absentIds, required bool arabic,
  }) async {
    await _guard(canHousing && _allowsHousing(housing.id));
    return OperationsHousingCoordinator.prepare(
      store: store, clock: clock, housing: housing, absentIds: absentIds, arabic: arabic,
    );
  }

  Future<HousingCheckUndo> saveHousingCheck(PreparedHousingCheck check) async {
    if (_isSavingHousing) throw const OperationException(DatabaseBusy());
    _isSavingHousing = true;
    try {
      await _guard(canHousing && _allowsHousing(check.housing.id));
      return await store.saveHousingCheck(
        date: check.date, housing: check.housing, absentIds: check.summary.workerIds, actorUserId: actorUserId,
      );
    } finally {
      _isSavingHousing = false;
    }
  }

  Future<void> undoHousingCheck(HousingCheckUndo undo) =>
      _guard(canHousing && _allowsHousing(undo.housingId))
          .then((_) => store.undoHousingCheck(undo, actorUserId: actorUserId));

  Future<PreparedSiteAttendance> prepareSiteAttendance({
    required EntityOption team, required Set<String> presentIds, required bool arabic,
  }) async {
    await _guard(canSite && _allowsTeam(team.id));
    return OperationsSiteCoordinator.prepare(
      store: store, clock: clock, team: team, presentIds: presentIds, arabic: arabic,
    );
  }

  Future<SiteAttendanceUndo> saveSiteAttendance(PreparedSiteAttendance attendance) async {
    if (_isSavingSite) throw const OperationException(DatabaseBusy());
    _isSavingSite = true;
    try {
      await _guard(canSite && _allowsTeam(attendance.team.id));
      return await store.saveSiteAttendance(
        date: attendance.date, team: attendance.team, presentIds: attendance.summary.workerIds, actorUserId: actorUserId,
      );
    } finally {
      _isSavingSite = false;
    }
  }

  Future<void> undoSiteAttendance(SiteAttendanceUndo undo) =>
      _guard(canSite && _allowsTeam(undo.teamId)).then((_) => store.undoSiteAttendance(undo, actorUserId: actorUserId));

  Future<void> _guard(bool allowed) async {
    if (!allowed) throw const OperationException(PermissionDenied());
  }
}
