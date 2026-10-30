import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/worker_search_filter.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_worker_row.dart';

export 'package:radar_labor/features/operations/presentation/state/housing_worker_row.dart';

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
    this.hasUnsavedChanges = false,
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
  final bool hasUnsavedChanges;

  int get totalCount => rows.length;
  int get absentCount => rows.where((r) => r.isAbsent).length;
  int get reviewedCount => rows.where((r) => r.reviewState == HousingReviewState.reviewedPresent).length;
  int get unreviewedCount => rows.where((r) => r.reviewState == HousingReviewState.unreviewed).length;

  Set<String> get absentWorkerIds => {for (final r in rows) if (r.isAbsent) r.worker.id};
  Set<String> get reviewedWorkerIds => {for (final r in rows) if (r.reviewState == HousingReviewState.reviewedPresent) r.worker.id};

  List<HousingWorkerRow> get filteredRows {
    if (searchQuery.trim().isEmpty) return rows;
    return rows.where((r) => WorkerSearchFilter.matches(
      query: searchQuery, code: r.worker.code, nameAr: r.worker.nameAr, nameEn: r.worker.nameEn,
    )).toList(growable: false);
  }

  HousingCheckState copyWith({
    EntityOption? selectedHousing, bool clearHousing = false,
    String? selectedDate, String? todayDate, bool? isLoading, bool? isSaving,
    bool? isPastDate, String? searchQuery, List<HousingWorkerRow>? rows,
    bool? hasSavedRecordToday, bool? hasDraftSaved, HousingCheckUndo? lastUndo,
    bool clearUndo = false,
    String? errorMessage, bool clearError = false, bool? hasUnsavedChanges,
  }) => HousingCheckState(
    selectedHousing: clearHousing ? null : (selectedHousing ?? this.selectedHousing),
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
    hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
  );
}
