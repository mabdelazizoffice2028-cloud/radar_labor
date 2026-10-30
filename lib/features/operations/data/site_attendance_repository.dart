import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/site_attendance_guardian.dart';
import 'package:radar_labor/features/operations/data/site_attendance_loader.dart';
import 'package:radar_labor/features/operations/data/site_attendance_preparer.dart';
import 'package:radar_labor/features/operations/data/site_attendance_saver.dart';
import 'package:radar_labor/features/operations/data/site_attendance_summary_helper.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_draft_store.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

final class SiteAttendanceRepository implements SiteAttendanceStore {
  const SiteAttendanceRepository({required this.database, required this.events, required this.draftStore, required this.clock});
  final AppDatabase database;
  final EventRepository events;
  final AttendanceDraftStore draftStore;
  final Clock clock;

  SiteAttendanceLoader get _loader => SiteAttendanceLoader(database: database, events: events, draftStore: draftStore);
  SiteAttendancePreparer get _preparer => SiteAttendancePreparer(database: database, events: events);
  SiteAttendanceSaver get _saver => SiteAttendanceSaver(database: database, events: events, draftStore: draftStore, clock: clock);

  @override
  String currentBusinessDate() => businessDateFor(clock.nowUtc());
  @override
  Stream<List<EntityOption>> watchScopedTeams(Set<String> allowed) => SiteAttendanceGuardian.watchScopedTeams(database, allowed);

  @override
  Future<LoadedSiteAttendanceDay> loadDay({
    required ActorContext actor, required ScopeSnapshot scope, required EntityOption team, required String date, required bool arabic,
  }) async {
    await _guard(actor, scope, team.id, date);
    return _loader.load(team: team, date: date, today: currentBusinessDate(), arabic: arabic);
  }

  @override
  Future<List<CrossTeamWorkerOption>> searchCrossTeamWorkers({
    required String query, required Set<String> excludeWorkerIds, required bool arabic,
  }) => _preparer.searchCrossTeamWorkers(query: query, excludeWorkerIds: excludeWorkerIds, arabic: arabic);

  @override
  Future<PreparedSiteSave> prepareSave({
    required ActorContext actor, required ScopeSnapshot scope, required EntityOption team, required String date,
    required List<AttendanceRow> rows, required AttendanceBaseline baseline, required bool arabic,
  }) async {
    await _guard(actor, scope, team.id, date);
    return _preparer.prepareSave(team: team, date: date, rows: rows, baseline: baseline, arabic: arabic);
  }

  @override
  Future<({LedgerUndoPlan undoPlan, AttendanceSummary summary})> save({
    required ActorContext actor, required ScopeSnapshot scope, required PreparedSiteSave prepared,
    required Map<String, ConflictResolutionChoice> resolutions, required bool arabic,
  }) async {
    await _guard(actor, scope, prepared.team.id, prepared.date);
    final built = await _saver.executeSave(actor: actor, prepared: prepared, resolutions: resolutions);
    final activeRows = await (database.select(database.employees)..where((r) => r.archivedAt.isNull())).get();
    final summary = SiteAttendanceSummaryHelper.build(
      date: prepared.date, team: prepared.team, activeEmployees: activeRows,
      presentIds: built.finalSelectedIds, arabic: arabic, supervisorName: actor.displayName,
    );
    return (undoPlan: built.undoPlan, summary: summary);
  }

  @override
  Future<void> undo({required ActorContext actor, required ScopeSnapshot scope, required String teamId, required LedgerUndoPlan plan}) async {
    await _guard(actor, scope, teamId, plan.businessDate); await _saver.undo(plan, actor.userId);
  }

  Future<void> _guard(ActorContext actor, ScopeSnapshot scope, String teamId, String date) => SiteAttendanceGuardian.guard(
    database: database, clock: clock, actor: actor, scope: scope, teamId: teamId, date: date, todayBusinessDate: currentBusinessDate(),
  );
}
