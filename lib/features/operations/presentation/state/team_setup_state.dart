import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/domain/worker_search_filter.dart';

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
    int? step, String? nameAr, String? nameEn, String? searchQuery,
    List<SelectableWorker>? allWorkers, List<SelectableWorker>? visibleWorkers,
    Set<String>? selectedWorkerIds, List<SelectableWorker>? selectedWorkersSorted,
    String? editingTeamId, bool? arabic, bool? isSaving,
    OperationFailure? failure, bool clearFailure = false,
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

  TeamSetupState recomputeLists({
    List<SelectableWorker>? allWorkers,
    String? searchQuery,
    Set<String>? selectedWorkerIds,
    bool? arabic,
  }) {
    final all = allWorkers ?? this.allWorkers;
    final query = searchQuery ?? this.searchQuery;
    final selected = selectedWorkerIds ?? this.selectedWorkerIds;
    final ar = arabic ?? this.arabic;
    final sortedAll = [...all]..sort((a, b) => NameCollation.compareWorkers(
      nameA: a.displayName(arabic: ar), codeA: a.code, idA: a.id,
      nameB: b.displayName(arabic: ar), codeB: b.code, idB: b.id,
    ));
    final visible = query.trim().isEmpty
        ? sortedAll
        : sortedAll.where((w) => WorkerSearchFilter.matches(
              query: query, code: w.code, nameAr: w.nameAr, nameEn: w.nameEn, id: w.id,
            )).toList(growable: false);
    final selectedSorted = [for (final w in sortedAll) if (selected.contains(w.id)) w];
    return copyWith(
      allWorkers: List.unmodifiable(sortedAll),
      visibleWorkers: List.unmodifiable(visible),
      selectedWorkerIds: Set.unmodifiable(selected),
      selectedWorkersSorted: List.unmodifiable(selectedSorted),
      searchQuery: query, arabic: ar, clearFailure: true,
    );
  }
}
