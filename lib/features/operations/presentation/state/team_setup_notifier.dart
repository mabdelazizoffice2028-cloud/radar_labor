import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/state/team_setup_state.dart';

export 'package:radar_labor/features/operations/presentation/state/team_setup_state.dart';

final class TeamSetupNotifier extends Notifier<TeamSetupState> {
  StreamSubscription<List<SelectableWorker>>? _workersSub;
  TeamSetupStore? _store;

  @override
  TeamSetupState build() { ref.onDispose(() => _workersSub?.cancel()); return const TeamSetupState(); }

  void bindStore({required TeamSetupStore store, required bool arabic, String? editingTeamId}) {
    if (state.editingTeamId == editingTeamId && _store == store) {
      if (state.arabic != arabic) state = state.recomputeLists(arabic: arabic);
      return;
    }
    _store = store;
    _workersSub?.cancel();
    state = TeamSetupState(editingTeamId: editingTeamId, arabic: arabic);
    var initializedSelection = false;
    _workersSub = store.watchActiveWorkersWithTeams().listen((workers) {
      var selected = state.selectedWorkerIds;
      if (!initializedSelection && editingTeamId != null) {
        initializedSelection = true;
        selected = {for (final w in workers) if (w.currentTeamId == editingTeamId) w.id};
      }
      state = state.recomputeLists(allWorkers: workers, selectedWorkerIds: selected);
    });
  }

  void setNameAr(String value) => state = state.copyWith(nameAr: value, clearFailure: true);
  void setNameEn(String value) => state = state.copyWith(nameEn: value, clearFailure: true);
  void setSearchQuery(String query) => state = state.recomputeLists(searchQuery: query);

  void toggleWorker(String workerId) {
    final worker = state.allWorkers.where((w) => w.id == workerId).firstOrNull;
    if (worker == null || !state.isWorkerSelectable(worker)) return;
    final next = {...state.selectedWorkerIds};
    if (!next.remove(workerId)) next.add(workerId);
    state = state.recomputeLists(selectedWorkerIds: next);
  }

  void selectAllVisible() => state = state.recomputeLists(selectedWorkerIds: {
    ...state.selectedWorkerIds, for (final w in state.visibleWorkers) if (state.isWorkerSelectable(w)) w.id,
  });

  void clearAllVisible() => state = state.recomputeLists(selectedWorkerIds: {
    for (final id in state.selectedWorkerIds)
      if (!state.visibleWorkers.any((w) => w.id == id && state.isWorkerSelectable(w))) id,
  });

  bool advanceFromNameStep() {
    final trimmed = state.nameAr.trim();
    if (trimmed.isEmpty || trimmed.length > OperationsConstants.teamNameMaxLength) {
      state = state.copyWith(failure: const TeamNameInvalid());
      return false;
    }
    state = state.copyWith(step: 2, clearFailure: true);
    return true;
  }

  void goToStep(int step) => state = state.copyWith(step: step.clamp(1, 3), clearFailure: true);

  Future<EntityOption?> submitCreateTeam({required ActorContext actor}) => _runSave<EntityOption?>(
    fallback: null, op: (s) => s.createTeam(actor: actor, nameAr: state.nameAr, nameEn: state.nameEn, workerIds: state.selectedWorkerIds),
  );

  Future<bool> submitEditTeam({required ActorContext actor, required ScopeSnapshot scope, required String teamId}) => _runSave<bool>(
    fallback: false, op: (s) => s.updateTeamMembers(actor: actor, scope: scope, teamId: teamId, workerIds: state.selectedWorkerIds).then((_) => true),
  );

  Future<T> _runSave<T>({required T fallback, required Future<T> Function(TeamSetupStore) op}) async {
    final store = _store;
    if (store == null || state.isSaving) return fallback;
    state = state.copyWith(isSaving: true, clearFailure: true);
    try {
      final res = await op(store);
      state = state.copyWith(isSaving: false, clearFailure: true);
      return res;
    } on OperationException catch (e) {
      if (e.failure case WorkersUnavailable(:final workerIds)) {
        state = state.recomputeLists(selectedWorkerIds: state.selectedWorkerIds.difference(workerIds));
      }
      state = state.copyWith(isSaving: false, failure: e.failure);
    } on Exception { state = state.copyWith(isSaving: false, failure: const SaveFailed()); }
    return fallback;
  }
}

final teamSetupNotifierProvider = NotifierProvider<TeamSetupNotifier, TeamSetupState>(TeamSetupNotifier.new);
