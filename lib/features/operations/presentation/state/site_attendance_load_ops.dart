import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/state/site_draft_persistence.dart';

mixin SiteAttendanceLoadOps on Notifier<SiteAttendanceState>, SiteDraftPersistence {
  SiteAttendanceStore get store;
  bool get isArabic;
  ({ActorContext actor, ScopeSnapshot scope})? actorAndScope();
  void setFailure(Exception e);

  Future<void> ensureInitialTeam(List<EntityOption> teams) async {
    if (teams.isEmpty) {
      if (state.selectedTeam != null) {
        state = state.copyWith(clearSelectedTeam: true, rows: const []);
      }
      return;
    }
    final cur = state.selectedTeam;
    if (cur != null && teams.any((t) => t.id == cur.id)) {
      if (state.rows.isEmpty && !state.isLoading) {
        await loadTeamDay(team: cur, date: state.selectedDate);
      }
      return;
    }
    await selectTeam(teams.first);
  }

  Future<void> selectTeam(EntityOption? team) async {
    await flushDraft();
    if (team != null) return loadTeamDay(team: team, date: state.selectedDate);
    state = state.copyWith(clearSelectedTeam: true, rows: const [], clearError: true);
  }

  Future<void> selectDate(String date) async {
    await flushDraft();
    final team = state.selectedTeam;
    if (team != null) return loadTeamDay(team: team, date: date);
    final today = store.currentBusinessDate();
    state = state.copyWith(selectedDate: date, todayDate: today, isPastDate: date.compareTo(today) < 0);
  }

  Future<void> openTeamAndDate({required EntityOption team, required String date}) =>
      flushDraft().then((_) => loadTeamDay(team: team, date: date));

  Future<void> reload() async =>
      state.selectedTeam == null ? null : loadTeamDay(team: state.selectedTeam!, date: state.selectedDate);

  Future<void> loadTeamDay({required EntityOption team, required String date}) async {
    final ctx = actorAndScope();
    if (ctx == null) return;
    final today = store.currentBusinessDate();
    state = state.copyWith(
      selectedTeam: team, selectedDate: date, todayDate: today,
      isPastDate: date.compareTo(today) < 0, isLoading: true, clearError: true,
    );
    try {
      final d = await store.loadDay(
        actor: ctx.actor, scope: ctx.scope, team: team, date: date, arabic: isArabic,
      );
      state = state.withLoadedDay(d, today);
    } on Exception catch (error) {
      setFailure(error);
    }
  }
}
