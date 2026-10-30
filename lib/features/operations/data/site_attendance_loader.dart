import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/features/operations/data/site_attendance_baseline_finder.dart';
import 'package:radar_labor/features/operations/data/site_attendance_row_builder.dart';
import 'package:radar_labor/features/operations/data/site_attendance_source_resolver.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_draft_store.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

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
    required EntityOption team, required String date,
    required String today, required bool arabic,
  }) async {
    await draftStore.cleanupExpiredDrafts(todayBusinessDate: today);

    final leavesSetting = await (database.select(database.settings)
          ..where((s) => s.key.equals(AppSettingKeys.workerLeaves)))
        .getSingleOrNull();
    final onLeaveIds = SiteAttendanceSourceResolver.parseOnLeaveIds(leavesSetting?.value, date);

    final allEmployees = await database.select(database.employees).get();
    final allTeams = await database.select(database.teams).get();
    final teamsById = {for (final t in allTeams) t.teamId: t};
    final employeesById = {for (final e in allEmployees) e.employeeUid: e};
    final activeById = {
      for (final e in allEmployees)
        if (e.isActive && !onLeaveIds.contains(e.employeeUid)) e.employeeUid: e,
    };

    final dayEvents = await events.readBusinessDate(date);
    final dayLedger = AttendanceLedger(dayEvents);
    final isSavedDay = dayLedger.isSiteSubmitted(team.id);
    final savedPresentIds = dayLedger.presentWorkerIdsForTeam(team.id);

    final baseline = isSavedDay
        ? AttendanceBaseline(kind: BaselineKind.lastSave, date: date, workerIds: Set.unmodifiable(savedPresentIds))
        : await SiteAttendanceBaselineFinder.findPreviousSubmitted(
            events: events, teamId: team.id, date: date, activeById: activeById,
          );

    final draft = await draftStore.readDraft(teamId: team.id, date: date);
    final (initSource, initDate, skipped, selected, locked) = SiteAttendanceSourceResolver.resolve(
      draft: draft, isSavedDay: isSavedDay, baseline: baseline, date: date,
      savedPresentIds: savedPresentIds, activeById: activeById, employeesById: employeesById,
    );

    final rows = SiteAttendanceRowBuilder.buildRows(
      teamId: team.id, activeById: activeById, employeesById: employeesById,
      teamsById: teamsById, selectedIds: selected, lockedIds: locked, arabic: arabic,
    );

    return LoadedSiteAttendanceDay(
      team: team, date: date, isPastDate: date.compareTo(today) < 0,
      rows: rows, baseline: baseline, initialSource: initSource,
      initialSourceDate: initDate, skippedDraftCount: skipped,
    );
  }
}
