import 'package:radar_labor/features/operations/domain/operations_models.dart';

/// 3-State review model for housing checks (Phase 4).
enum HousingReviewState { unreviewed, reviewedPresent, absent }

/// Presentation row representing a worker in the housing check.
final class HousingWorkerRow {
  const HousingWorkerRow({
    required this.worker,
    this.reviewState = HousingReviewState.unreviewed,
  });

  final WorkerOption worker;
  final HousingReviewState reviewState;

  HousingWorkerRow copyWith({HousingReviewState? reviewState}) =>
      HousingWorkerRow(
        worker: worker,
        reviewState: reviewState ?? this.reviewState,
      );
}

/// Immutable state for the 3-state housing check workflow.
final class HousingCheckState {
  const HousingCheckState({
    required this.selectedDate,
    required this.todayDate,
    this.selectedHousing,
    this.isLoading = false,
    this.isSaving = false,
    this.isPastDate = false,
    this.searchQuery = '',
    this.rows = const <HousingWorkerRow>[],
    this.hasSavedRecordToday = false,
    this.hasDraftSaved = false,
    this.lastUndo,
    this.errorMessage,
  });

  final EntityOption? selectedHousing;
  final String selectedDate;
  final String todayDate;
  final bool isLoading;
  final bool isSaving;
  final bool isPastDate;
  final String searchQuery;
  final List<HousingWorkerRow> rows;
  final bool hasSavedRecordToday;
  final bool hasDraftSaved;
  final HousingCheckUndo? lastUndo;
  final String? errorMessage;

  int get totalCount => rows.length;
  int get unreviewedCount =>
      rows.where((r) => r.reviewState == HousingReviewState.unreviewed).length;
  int get reviewedCount => rows
      .where((r) => r.reviewState == HousingReviewState.reviewedPresent)
      .length;
  int get absentCount =>
      rows.where((r) => r.reviewState == HousingReviewState.absent).length;

  Set<String> get absentWorkerIds => {
    for (final r in rows)
      if (r.reviewState == HousingReviewState.absent) r.worker.id,
  };

  Set<String> get reviewedWorkerIds => {
    for (final r in rows)
      if (r.reviewState == HousingReviewState.reviewedPresent) r.worker.id,
  };

  List<HousingWorkerRow> get filteredRows {
    if (searchQuery.trim().isEmpty) return rows;
    final q = searchQuery.trim().toLowerCase();
    return rows
        .where((r) {
          final nameAr = r.worker.nameAr.toLowerCase();
          final nameEn = (r.worker.nameEn ?? '').toLowerCase();
          final code = r.worker.code.toLowerCase();
          return nameAr.contains(q) || nameEn.contains(q) || code.contains(q);
        })
        .toList(growable: false);
  }

  HousingCheckState copyWith({
    EntityOption? selectedHousing,
    bool clearSelectedHousing = false,
    String? selectedDate,
    String? todayDate,
    bool? isLoading,
    bool? isSaving,
    bool? isPastDate,
    String? searchQuery,
    List<HousingWorkerRow>? rows,
    bool? hasSavedRecordToday,
    bool? hasDraftSaved,
    HousingCheckUndo? lastUndo,
    bool clearUndo = false,
    String? errorMessage,
    bool clearError = false,
  }) => HousingCheckState(
    selectedHousing: clearSelectedHousing
        ? null
        : (selectedHousing ?? this.selectedHousing),
    selectedDate: selectedDate ?? this.selectedDate,
    todayDate: todayDate ?? this.todayDate,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    isPastDate: isPastDate ?? this.isPastDate,
    searchQuery: searchQuery ?? this.searchQuery,
    rows: rows ?? this.rows,
    hasSavedRecordToday: hasSavedRecordToday ?? this.hasSavedRecordToday,
    hasDraftSaved: hasDraftSaved ?? this.hasDraftSaved,
    lastUndo: clearUndo ? null : (lastUndo ?? this.lastUndo),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}
