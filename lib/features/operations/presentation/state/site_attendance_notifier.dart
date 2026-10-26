import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';

export 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart'
    show scopedSiteTeamsProvider;

/// Controller for smart daily site attendance (PRD §8, §9, §10).
final class SiteAttendanceNotifier extends Notifier<SiteAttendanceState> {
  Timer? _draftTimer;
  ActorContext? _overrideActor;
  ScopeSnapshot? _overrideScope;

  @override
  SiteAttendanceState build() {
    ref.onDispose(() => _draftTimer?.cancel());
    final today = _store.currentBusinessDate();
    return SiteAttendanceState(selectedDate: today, todayDate: today);
  }

  SiteAttendanceStore get _store => ref.read(siteAttendanceStoreProvider);
  bool get _isArabic => ref.read(appLocaleProvider) == 'ar';

  void setOverrideContext({ActorContext? actor, ScopeSnapshot? scope}) =>
      (_overrideActor = actor, _overrideScope = scope);

  ({ActorContext actor, ScopeSnapshot scope})? _actorAndScope() {
    if (_overrideActor != null && _overrideScope != null) {
      return (actor: _overrideActor!, scope: _overrideScope!);
    }
    final s = ref.read(currentSessionProvider);
    if (s == null) return null;
    final scope =
        ref.read(userScopesProvider(s.id)).value ??
        ScopeSnapshot(
          teamIds: s.teamIds.toSet(),
          housingIds: s.housingIds.toSet(),
        );
    return (actor: ActorContext(userId: s.id, role: s.role), scope: scope);
  }

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
        await _load(team: cur, date: state.selectedDate);
      }
      return;
    }
    await selectTeam(teams.first);
  }

  Future<void> selectTeam(EntityOption? team) async {
    await flushDraft();
    if (team != null) return _load(team: team, date: state.selectedDate);
    state = state.copyWith(
      clearSelectedTeam: true,
      rows: const [],
      clearError: true,
    );
  }

  Future<void> selectDate(String date) async {
    await flushDraft();
    final team = state.selectedTeam;
    if (team != null) return _load(team: team, date: date);
    final today = _store.currentBusinessDate();
    state = state.copyWith(
      selectedDate: date,
      todayDate: today,
      isPastDate: date.compareTo(today) < 0,
    );
  }

  Future<void> openTeamAndDate({
    required EntityOption team,
    required String date,
  }) => flushDraft().then((_) => _load(team: team, date: date));

  Future<void> reload() async => state.selectedTeam == null
      ? null
      : _load(team: state.selectedTeam!, date: state.selectedDate);

  Future<void> _load({required EntityOption team, required String date}) async {
    final ctx = _actorAndScope();
    if (ctx == null) return;
    final today = _store.currentBusinessDate();
    state = state.copyWith(
      selectedTeam: team,
      selectedDate: date,
      todayDate: today,
      isPastDate: date.compareTo(today) < 0,
      isLoading: true,
      clearError: true,
    );
    try {
      final d = await _store.loadDay(
        actor: ctx.actor,
        scope: ctx.scope,
        team: team,
        date: date,
        arabic: _isArabic,
      );
      state = state.withLoadedDay(d, today);
    } on OperationException catch (error) {
      _setFailure(error);
    }
  }

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void toggleWorker(String workerId) => _updateRows([
    for (final row in state.rows)
      if (row.worker.id == workerId && !row.isLocked)
        row.copyWith(isPresent: !row.isPresent)
      else
        row,
  ]);

  void selectAll(bool present) {
    final visibleIds = state.filteredRows.map((r) => r.worker.id).toSet();
    _updateRows([
      for (final row in state.rows)
        if (!row.isLocked && visibleIds.contains(row.worker.id))
          row.copyWith(isPresent: present)
        else
          row,
    ]);
  }

  void addGuestWorker(CrossTeamWorkerOption guest) {
    if (state.existingWorkerIds.contains(guest.worker.id)) return;
    final ar = _isArabic;
    final updated = [
      ...state.rows,
      AttendanceRow(
        worker: guest.worker,
        isPresent: true,
        origin: WorkerRowOrigin.guest,
        originTeamNameAr: guest.teamNameAr,
        originTeamNameEn: guest.teamNameEn,
      ),
    ]..sort((a, b) => _cmp(a.worker, b.worker, ar));
    _updateRows(updated);
  }

  int _cmp(WorkerOption a, WorkerOption b, bool ar) =>
      NameCollation.compareWorkers(
        nameA: a.displayName(arabic: ar),
        codeA: a.code,
        idA: a.id,
        nameB: b.displayName(arabic: ar),
        codeB: b.code,
        idB: b.id,
      );

  void removeGuestWorker(String workerId) => _updateRows([
    for (final row in state.rows)
      if (!(row.isGuest && row.worker.id == workerId)) row,
  ]);

  void _updateRows(List<AttendanceRow> rows) {
    state = state.copyWith(
      rows: List.unmodifiable(rows),
      skippedDraftCount: 0,
      clearError: true,
    );
    _draftTimer?.cancel();
    _draftTimer = Timer(
      OperationsConstants.draftDebounce,
      () => unawaited(flushDraft()),
    );
  }

  Future<List<CrossTeamWorkerOption>> searchGuests(String query) =>
      _store.searchCrossTeamWorkers(
        query: query,
        excludeWorkerIds: state.existingWorkerIds,
        arabic: _isArabic,
      );

  Future<PreparedSiteSave?> prepareSave() async {
    await flushDraft();
    final ctx = _actorAndScope();
    final team = state.selectedTeam;
    if (ctx == null || team == null) return null;
    try {
      return await _store.prepareSave(
        actor: ctx.actor,
        scope: ctx.scope,
        team: team,
        date: state.selectedDate,
        rows: state.rows,
        baseline: state.baseline,
        arabic: _isArabic,
      );
    } on OperationException catch (e) {
      _setFailure(e);
      return null;
    }
  }

  Future<({LedgerUndoPlan undoPlan, AttendanceSummary summary})?> confirmSave({
    required PreparedSiteSave prepared,
    required Map<String, ConflictResolutionChoice> resolutions,
  }) async {
    _draftTimer?.cancel();
    final ctx = _actorAndScope();
    if (ctx == null) return null;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final res = await _store.save(
        actor: ctx.actor,
        scope: ctx.scope,
        prepared: prepared,
        resolutions: resolutions,
        arabic: _isArabic,
      );
      await _load(team: prepared.team, date: prepared.date);
      state = state.copyWith(
        isSaving: false,
        lastUndoPlan: res.undoPlan,
        lastSummary: res.summary,
      );
      return res;
    } on OperationException catch (e) {
      _setFailure(e);
      return null;
    }
  }

  Future<bool> undoLastSave() async {
    final ctx = _actorAndScope();
    final team = state.selectedTeam;
    final plan = state.lastUndoPlan;
    if (ctx == null || team == null || plan == null) return false;
    try {
      await _store.undo(
        actor: ctx.actor,
        scope: ctx.scope,
        teamId: team.id,
        plan: plan,
      );
      state = state.copyWith(clearUndoPlan: true, clearSummary: true);
      await _load(team: team, date: state.selectedDate);
      return true;
    } on OperationException catch (e) {
      _setFailure(e);
      return false;
    }
  }

  Future<void> flushDraft() async {
    final pending = _draftTimer;
    if (pending == null || !pending.isActive) return;
    pending.cancel();
    final team = state.selectedTeam;
    if (team == null) return;
    final drafts = ref.read(attendanceDraftStoreProvider);
    await drafts.writeDraft(
      teamId: team.id,
      date: state.selectedDate,
      workerIds: state.selectedActiveWorkerIds,
    );
  }

  void _setFailure(OperationException e) => state = state.copyWith(
    isLoading: false,
    isSaving: false,
    errorMessage: OperationFailureMessage.of(e.failure, _isArabic),
  );
}

final siteAttendanceNotifierProvider =
    NotifierProvider<SiteAttendanceNotifier, SiteAttendanceState>(
      SiteAttendanceNotifier.new,
    );
