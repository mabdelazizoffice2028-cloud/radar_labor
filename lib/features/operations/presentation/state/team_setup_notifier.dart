import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';

/// Immutable presentation state for the supervisor Team Setup Wizard and Team Editor (PRD §7).
final class TeamSetupState {
  const TeamSetupState({
    this.step = 1,
    this.nameAr = '',
    this.nameEn = '',
    this.searchQuery = '',
    this.allWorkers = const [],
    this.visibleWorkers = const [],
    this.selectedWorkerIds = const {},
    this.selectedWorkersSorted = const [],
    this.editingTeamId,
    this.arabic = false,
    this.isSaving = false,
    this.failure,
  });

  final int step;
  final String nameAr;
  final String nameEn;
  final String searchQuery;
  final List<SelectableWorker> allWorkers;
  final List<SelectableWorker> visibleWorkers;
  final Set<String> selectedWorkerIds;
  final List<SelectableWorker> selectedWorkersSorted;
  final String? editingTeamId;
  final bool arabic;
  final bool isSaving;
  final OperationFailure? failure;

  bool isWorkerSelectable(SelectableWorker worker) =>
      worker.currentTeamId == null ||
      (editingTeamId != null && worker.currentTeamId == editingTeamId);

  TeamSetupState copyWith({
    int? step,
    String? nameAr,
    String? nameEn,
    String? searchQuery,
    List<SelectableWorker>? allWorkers,
    List<SelectableWorker>? visibleWorkers,
    Set<String>? selectedWorkerIds,
    List<SelectableWorker>? selectedWorkersSorted,
    String? editingTeamId,
    bool? arabic,
    bool? isSaving,
    OperationFailure? failure,
    bool clearFailure = false,
  }) => TeamSetupState(
    step: step ?? this.step,
    nameAr: nameAr ?? this.nameAr,
    nameEn: nameEn ?? this.nameEn,
    searchQuery: searchQuery ?? this.searchQuery,
    allWorkers: allWorkers ?? this.allWorkers,
    visibleWorkers: visibleWorkers ?? this.visibleWorkers,
    selectedWorkerIds: selectedWorkerIds ?? this.selectedWorkerIds,
    selectedWorkersSorted: selectedWorkersSorted ?? this.selectedWorkersSorted,
    editingTeamId: editingTeamId ?? this.editingTeamId,
    arabic: arabic ?? this.arabic,
    isSaving: isSaving ?? this.isSaving,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

/// Riverpod Notifier managing team wizard and team member editing state without UI logic.
final class TeamSetupNotifier extends Notifier<TeamSetupState> {
  StreamSubscription<List<SelectableWorker>>? _workersSub;
  TeamSetupStore? _store;

  @override
  TeamSetupState build() {
    ref.onDispose(() => _workersSub?.cancel());
    return const TeamSetupState();
  }

  void bindStore({
    required TeamSetupStore store,
    required bool arabic,
    String? editingTeamId,
  }) {
    final modeChanged = state.editingTeamId != editingTeamId || _store != store;
    _store = store;
    if (!modeChanged) {
      if (state.arabic != arabic) {
        _recomputeLists(arabic: arabic);
      }
      return;
    }

    _workersSub?.cancel();
    state = TeamSetupState(editingTeamId: editingTeamId, arabic: arabic);
    var initializedSelection = false;
    _workersSub = store.watchActiveWorkersWithTeams().listen((workers) {
      var selected = state.selectedWorkerIds;
      if (!initializedSelection && editingTeamId != null) {
        initializedSelection = true;
        selected = {
          for (final w in workers)
            if (w.currentTeamId == editingTeamId) w.id,
        };
      }
      _recomputeLists(allWorkers: workers, selectedWorkerIds: selected);
    });
  }

  void setNameAr(String value) {
    state = state.copyWith(nameAr: value, clearFailure: true);
  }

  void setNameEn(String value) {
    state = state.copyWith(nameEn: value, clearFailure: true);
  }

  void setSearchQuery(String query) {
    _recomputeLists(searchQuery: query);
  }

  void toggleWorker(String workerId) {
    final worker = state.allWorkers.where((w) => w.id == workerId).firstOrNull;
    if (worker == null || !state.isWorkerSelectable(worker)) return;
    final next = {...state.selectedWorkerIds};
    if (!next.remove(workerId)) {
      next.add(workerId);
    }
    _recomputeLists(selectedWorkerIds: next);
  }

  void selectAllVisible() {
    final next = {...state.selectedWorkerIds};
    for (final worker in state.visibleWorkers) {
      if (state.isWorkerSelectable(worker)) {
        next.add(worker.id);
      }
    }
    _recomputeLists(selectedWorkerIds: next);
  }

  void clearAllVisible() {
    final next = {...state.selectedWorkerIds};
    for (final worker in state.visibleWorkers) {
      if (state.isWorkerSelectable(worker)) {
        next.remove(worker.id);
      }
    }
    _recomputeLists(selectedWorkerIds: next);
  }

  bool advanceFromNameStep() {
    final trimmed = state.nameAr.trim();
    if (trimmed.isEmpty ||
        trimmed.length > OperationsConstants.teamNameMaxLength) {
      state = state.copyWith(failure: const TeamNameInvalid());
      return false;
    }
    state = state.copyWith(step: 2, clearFailure: true);
    return true;
  }

  void goToStep(int step) {
    state = state.copyWith(step: step.clamp(1, 3), clearFailure: true);
  }

  Future<EntityOption?> submitCreateTeam({required ActorContext actor}) async {
    final store = _store;
    if (store == null || state.isSaving) return null;
    state = state.copyWith(isSaving: true, clearFailure: true);
    try {
      final created = await store.createTeam(
        actor: actor,
        nameAr: state.nameAr,
        nameEn: state.nameEn,
        workerIds: state.selectedWorkerIds,
      );
      state = state.copyWith(isSaving: false, clearFailure: true);
      return created;
    } on OperationException catch (e) {
      _handleOperationFailure(e.failure);
      return null;
    } on Exception {
      state = state.copyWith(isSaving: false, failure: const SaveFailed());
      return null;
    }
  }

  Future<bool> submitEditTeam({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
  }) async {
    final store = _store;
    if (store == null || state.isSaving) return false;
    state = state.copyWith(isSaving: true, clearFailure: true);
    try {
      await store.updateTeamMembers(
        actor: actor,
        scope: scope,
        teamId: teamId,
        workerIds: state.selectedWorkerIds,
      );
      state = state.copyWith(isSaving: false, clearFailure: true);
      return true;
    } on OperationException catch (e) {
      _handleOperationFailure(e.failure);
      return false;
    } on Exception {
      state = state.copyWith(isSaving: false, failure: const SaveFailed());
      return false;
    }
  }

  void _handleOperationFailure(OperationFailure failure) {
    if (failure is WorkersUnavailable) {
      final cleaned = state.selectedWorkerIds.difference(failure.workerIds);
      _recomputeLists(selectedWorkerIds: cleaned);
    }
    state = state.copyWith(isSaving: false, failure: failure);
  }

  void _recomputeLists({
    List<SelectableWorker>? allWorkers,
    String? searchQuery,
    Set<String>? selectedWorkerIds,
    bool? arabic,
  }) {
    final all = allWorkers ?? state.allWorkers;
    final query = searchQuery ?? state.searchQuery;
    final selected = selectedWorkerIds ?? state.selectedWorkerIds;
    final ar = arabic ?? state.arabic;
    final normQuery = NameCollation.sortKey(query);

    final sortedAll = [...all]
      ..sort(
        (a, b) => NameCollation.compareWorkers(
          nameA: a.displayName(arabic: ar),
          codeA: a.code,
          idA: a.id,
          nameB: b.displayName(arabic: ar),
          codeB: b.code,
          idB: b.id,
        ),
      );

    final visible = normQuery.isEmpty
        ? sortedAll
        : sortedAll
              .where((w) {
                final keyAr = NameCollation.sortKey(w.nameAr);
                final keyEn = NameCollation.sortKey(w.nameEn ?? '');
                final keyCode = w.code.toLowerCase();
                return keyAr.contains(normQuery) ||
                    keyEn.contains(normQuery) ||
                    keyCode.contains(normQuery);
              })
              .toList(growable: false);

    final selectedSorted = [
      for (final w in sortedAll)
        if (selected.contains(w.id)) w,
    ];

    state = state.copyWith(
      allWorkers: List.unmodifiable(sortedAll),
      visibleWorkers: List.unmodifiable(visible),
      selectedWorkerIds: Set.unmodifiable(selected),
      selectedWorkersSorted: List.unmodifiable(selectedSorted),
      searchQuery: query,
      arabic: ar,
      clearFailure: true,
    );
  }
}

final teamSetupNotifierProvider =
    NotifierProvider<TeamSetupNotifier, TeamSetupState>(TeamSetupNotifier.new);
