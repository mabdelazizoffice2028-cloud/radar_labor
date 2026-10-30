import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_load_ops.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/state/site_draft_persistence.dart';

mixin SiteAttendanceSaveOps
    on Notifier<SiteAttendanceState>, SiteDraftPersistence, SiteAttendanceLoadOps {
  Future<List<CrossTeamWorkerOption>> searchGuests(String query) =>
      store.searchCrossTeamWorkers(
        query: query,
        excludeWorkerIds: state.existingWorkerIds,
        arabic: isArabic,
      );

  Future<PreparedSiteSave?> prepareSave() async {
    await flushDraft();
    final ctx = actorAndScope();
    final team = state.selectedTeam;
    if (ctx == null || team == null) return null;
    try {
      return await store.prepareSave(
        actor: ctx.actor, scope: ctx.scope, team: team, date: state.selectedDate,
        rows: state.rows, baseline: state.baseline, arabic: isArabic,
      );
    } on Exception catch (e) {
      setFailure(e);
      return null;
    }
  }

  Future<({LedgerUndoPlan undoPlan, AttendanceSummary summary})?> confirmSave({
    required PreparedSiteSave prepared,
    required Map<String, ConflictResolutionChoice> resolutions,
  }) async {
    draftTimer?.cancel();
    final ctx = actorAndScope();
    if (ctx == null) return null;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final res = await store.save(
        actor: ctx.actor, scope: ctx.scope, prepared: prepared,
        resolutions: resolutions, arabic: isArabic,
      );
      await loadTeamDay(team: prepared.team, date: prepared.date);
      state = state.copyWith(isSaving: false, lastUndoPlan: res.undoPlan, lastSummary: res.summary);
      return res;
    } on Exception catch (e) {
      setFailure(e);
      return null;
    }
  }

  Future<bool> undoLastSave() async {
    final ctx = actorAndScope();
    final team = state.selectedTeam;
    final plan = state.lastUndoPlan;
    if (ctx == null || team == null || plan == null) return false;
    try {
      await store.undo(actor: ctx.actor, scope: ctx.scope, teamId: team.id, plan: plan);
      state = state.copyWith(clearUndoPlan: true, clearSummary: true);
      await loadTeamDay(team: team, date: state.selectedDate);
      return true;
    } on Exception catch (e) {
      setFailure(e);
      return false;
    }
  }
}
