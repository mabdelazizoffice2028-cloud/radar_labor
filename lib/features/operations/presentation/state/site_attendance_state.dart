import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/domain/worker_search_filter.dart';

export 'package:radar_labor/features/operations/presentation/state/scoped_site_teams_provider.dart';

final class SiteAttendanceState {
  const SiteAttendanceState({
    required this.selectedDate, required this.todayDate, this.selectedTeam,
    this.isPastDate = false, this.isLoading = false, this.isSaving = false,
    this.searchQuery = '', this.rows = const <AttendanceRow>[],
    this.baseline = const AttendanceBaseline(kind: BaselineKind.none),
    this.initialSource = AttendanceInitialSource.empty, this.initialSourceDate,
    this.skippedDraftCount = 0, this.lastUndoPlan, this.lastSummary,
    this.errorMessage, this.hasUnsavedChanges = false,
  });

  final EntityOption? selectedTeam;
  final String selectedDate;
  final String todayDate;
  final bool isPastDate;
  final bool isLoading;
  final bool isSaving;
  final String searchQuery;
  final List<AttendanceRow> rows;
  final AttendanceBaseline baseline;
  final AttendanceInitialSource initialSource;
  final String? initialSourceDate;
  final int skippedDraftCount;
  final LedgerUndoPlan? lastUndoPlan;
  final AttendanceSummary? lastSummary;
  final String? errorMessage;
  final bool hasUnsavedChanges;

  int get presentCount => rows.where((r) => r.isPresent).length;
  int get totalCount => rows.length;
  Set<String> get presentWorkerIds => {for (final r in rows) if (r.isPresent) r.worker.id};
  Set<String> get existingWorkerIds => {for (final r in rows) r.worker.id};
  Set<String> get selectedActiveWorkerIds => {for (final r in rows) if (!r.isLocked && r.isPresent) r.worker.id};
  Set<String> get guestWorkerIds => {for (final r in rows) if (r.isGuest) r.worker.id};

  List<AttendanceRow> get filteredRows => searchQuery.trim().isEmpty ? rows : rows.where(
    (r) => WorkerSearchFilter.matches(query: searchQuery, code: r.worker.code, nameAr: r.worker.nameAr, nameEn: r.worker.nameEn),
  ).toList(growable: false);

  SiteAttendanceState withLoadedDay(LoadedSiteAttendanceDay d, String today) => copyWith(
    selectedTeam: d.team, selectedDate: d.date, todayDate: today, isPastDate: d.isPastDate,
    isLoading: false, rows: d.rows, baseline: d.baseline, initialSource: d.initialSource,
    initialSourceDate: d.initialSourceDate, clearInitialSourceDate: d.initialSourceDate == null,
    skippedDraftCount: d.skippedDraftCount, clearError: true, hasUnsavedChanges: false,
  );

  SiteAttendanceState copyWith({
    EntityOption? selectedTeam, bool clearSelectedTeam = false, String? selectedDate,
    String? todayDate, bool? isPastDate, bool? isLoading, bool? isSaving,
    String? searchQuery, List<AttendanceRow>? rows, AttendanceBaseline? baseline,
    AttendanceInitialSource? initialSource, String? initialSourceDate,
    bool clearInitialSourceDate = false, int? skippedDraftCount,
    LedgerUndoPlan? lastUndoPlan, bool clearUndoPlan = false,
    AttendanceSummary? lastSummary, bool clearSummary = false,
    String? errorMessage, bool clearError = false, bool? hasUnsavedChanges,
  }) => SiteAttendanceState(
    selectedTeam: clearSelectedTeam ? null : (selectedTeam ?? this.selectedTeam),
    selectedDate: selectedDate ?? this.selectedDate, todayDate: todayDate ?? this.todayDate,
    isPastDate: isPastDate ?? this.isPastDate, isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving, searchQuery: searchQuery ?? this.searchQuery,
    rows: rows ?? this.rows, baseline: baseline ?? this.baseline,
    initialSource: initialSource ?? this.initialSource,
    initialSourceDate: clearInitialSourceDate ? null : (initialSourceDate ?? this.initialSourceDate),
    skippedDraftCount: skippedDraftCount ?? this.skippedDraftCount,
    lastUndoPlan: clearUndoPlan ? null : (lastUndoPlan ?? this.lastUndoPlan),
    lastSummary: clearSummary ? null : (lastSummary ?? this.lastSummary),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
  );
}
