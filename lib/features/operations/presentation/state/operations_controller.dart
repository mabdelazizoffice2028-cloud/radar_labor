import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/operations_store.dart';

final class PreparedHousingCheck {
  const PreparedHousingCheck({
    required this.housing,
    required this.date,
    required this.summary,
  });

  final EntityOption housing;
  final String date;
  final AttendanceSummary summary;
}

final class PreparedSiteAttendance {
  const PreparedSiteAttendance({
    required this.team,
    required this.date,
    required this.summary,
  });

  final EntityOption team;
  final String date;
  final AttendanceSummary summary;
}

final class OperationPermissionException implements Exception {
  const OperationPermissionException();
}

/// Coordinates daily operation rules while screens handle only presentation.
final class OperationsController {
  const OperationsController({
    required this.store,
    required this.clock,
    this.role,
    this.allowedHousingIds = const [],
    this.allowedTeamIds = const [],
  });

  final OperationsStore store;
  final Clock clock;
  final AuthRole? role;
  final List<String> allowedHousingIds;
  final List<String> allowedTeamIds;

  bool get _isAdmin =>
      role == null || role == AuthRole.projectManager || role == AuthRole.hr;
  bool get canHousing => _isAdmin || role == AuthRole.housingSupervisor;
  bool get canSite => _isAdmin || role == AuthRole.siteSupervisor;
  bool _allowsHousing(String id) => _isAdmin || allowedHousingIds.contains(id);
  bool _allowsTeam(String id) => _isAdmin || allowedTeamIds.contains(id);

  Stream<List<EntityOption>> watchHousings() => store.watchHousings().map(
    (items) =>
        items.where((item) => _allowsHousing(item.id)).toList(growable: false),
  );

  Stream<List<EntityOption>> watchTeams() => store.watchTeams().map(
    (items) =>
        items.where((item) => _allowsTeam(item.id)).toList(growable: false),
  );

  Stream<List<WorkerOption>> watchHousingWorkers(String housingId) =>
      _allowsHousing(housingId)
      ? store.watchHousingWorkers(housingId)
      : const Stream.empty();

  Stream<List<WorkerOption>> watchTeamWorkers(String teamId) =>
      _allowsTeam(teamId)
      ? store.watchTeamWorkers(teamId)
      : const Stream.empty();

  Future<PreparedHousingCheck> prepareHousingCheck({
    required EntityOption housing,
    required Set<String> absentIds,
    required bool arabic,
  }) async {
    final workers = await watchHousingWorkers(housing.id).first;
    final date = businessDateFor(clock.nowUtc());
    return PreparedHousingCheck(
      housing: housing,
      date: date,
      summary: AttendanceSummary.housingCheck(
        housing: housing,
        date: date,
        workers: workers,
        absentIds: absentIds,
        arabic: arabic,
        strings: AttendanceMessageStrings.fromLanguage(arabic: arabic),
      ),
    );
  }

  Future<HousingCheckUndo> saveHousingCheck(PreparedHousingCheck check) =>
      _guard(canHousing && _allowsHousing(check.housing.id)).then(
        (_) => store.saveHousingCheck(
          date: check.date,
          housing: check.housing,
          absentIds: check.summary.workerIds,
        ),
      );

  Future<void> undoHousingCheck(HousingCheckUndo undo) =>
      _guard(canHousing && _allowsHousing(undo.housingId))
          .then((_) => store.undoHousingCheck(undo));

  Future<PreparedSiteAttendance> prepareSiteAttendance({
    required EntityOption team,
    required Set<String> presentIds,
    required bool arabic,
  }) async {
    final workers = await watchTeamWorkers(team.id).first;
    final date = businessDateFor(clock.nowUtc());
    return PreparedSiteAttendance(
      team: team,
      date: date,
      summary: AttendanceSummary.siteAttendance(
        team: team,
        date: date,
        workers: workers,
        presentIds: presentIds,
        arabic: arabic,
        strings: AttendanceMessageStrings.fromLanguage(arabic: arabic),
      ),
    );
  }

  Future<SiteAttendanceUndo> saveSiteAttendance(
    PreparedSiteAttendance attendance,
  ) => _guard(canSite && _allowsTeam(attendance.team.id)).then(
    (_) => store.saveSiteAttendance(
      date: attendance.date,
      team: attendance.team,
      presentIds: attendance.summary.workerIds,
    ),
  );

  Future<void> undoSiteAttendance(SiteAttendanceUndo undo) =>
      _guard(canSite && _allowsTeam(undo.teamId))
          .then((_) => store.undoSiteAttendance(undo));

  Future<void> _guard(bool allowed) async {
    if (!allowed) throw const OperationPermissionException();
  }
}
