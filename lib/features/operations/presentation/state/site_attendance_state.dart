import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

/// Stream of active teams allowed for the current session user.
final scopedSiteTeamsProvider = StreamProvider<List<EntityOption>>((ref) {
  final session = ref.watch(currentSessionProvider);
  if (session == null) return Stream.value(const <EntityOption>[]);
  final scopesAsync = ref.watch(userScopesProvider(session.id));
  final allowedIds = scopesAsync.value?.teamIds ?? session.teamIds.toSet();
  return ref.watch(siteAttendanceStoreProvider).watchScopedTeams(allowedIds);
});

/// Immutable UI state for smart daily site attendance (PRD §8, §9, §10).
final class SiteAttendanceState {
  const SiteAttendanceState({
    required this.selectedDate,
    required this.todayDate,
    this.selectedTeam,
    this.isPastDate = false,
    this.isLoading = false,
    this.isSaving = false,
    this.searchQuery = '',
    this.rows = const <AttendanceRow>[],
    this.baseline = const AttendanceBaseline(kind: BaselineKind.none),
    this.initialSource = AttendanceInitialSource.empty,
    this.initialSourceDate,
    this.skippedDraftCount = 0,
    this.lastUndoPlan,
    this.lastSummary,
    this.errorMessage,
    this.hasUnsavedChanges = false,
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

  /// True while edits are not yet persisted as a local draft (or a draft write failed).
  final bool hasUnsavedChanges;

  int get presentCount => rows.where((row) => row.isPresent).length;

  Set<String> get existingWorkerIds => {for (final row in rows) row.worker.id};

  Set<String> get selectedActiveWorkerIds => {
    for (final row in rows)
      if (!row.isLocked && row.isPresent) row.worker.id,
  };

  Set<String> get guestWorkerIds => {
    for (final row in rows)
      if (row.isGuest) row.worker.id,
  };

  List<AttendanceRow> get filteredRows {
    if (searchQuery.trim().isEmpty) return rows;
    final q = searchQuery.trim().toLowerCase();
    return rows
        .where((row) {
          final nameAr = row.worker.nameAr.toLowerCase();
          final nameEn = (row.worker.nameEn ?? '').toLowerCase();
          final code = row.worker.code.toLowerCase();
          return nameAr.contains(q) || nameEn.contains(q) || code.contains(q);
        })
        .toList(growable: false);
  }

  SiteAttendanceState withLoadedDay(LoadedSiteAttendanceDay d, String today) =>
      copyWith(
        selectedTeam: d.team,
        selectedDate: d.date,
        todayDate: today,
        isPastDate: d.isPastDate,
        isLoading: false,
        rows: d.rows,
        baseline: d.baseline,
        initialSource: d.initialSource,
        initialSourceDate: d.initialSourceDate,
        clearInitialSourceDate: d.initialSourceDate == null,
        skippedDraftCount: d.skippedDraftCount,
        clearError: true,
        hasUnsavedChanges: false,
      );

  SiteAttendanceState copyWith({
    EntityOption? selectedTeam,
    bool clearSelectedTeam = false,
    String? selectedDate,
    String? todayDate,
    bool? isPastDate,
    bool? isLoading,
    bool? isSaving,
    String? searchQuery,
    List<AttendanceRow>? rows,
    AttendanceBaseline? baseline,
    AttendanceInitialSource? initialSource,
    String? initialSourceDate,
    bool clearInitialSourceDate = false,
    int? skippedDraftCount,
    LedgerUndoPlan? lastUndoPlan,
    bool clearUndoPlan = false,
    AttendanceSummary? lastSummary,
    bool clearSummary = false,
    String? errorMessage,
    bool clearError = false,
    bool? hasUnsavedChanges,
  }) => SiteAttendanceState(
    selectedTeam: clearSelectedTeam
        ? null
        : (selectedTeam ?? this.selectedTeam),
    selectedDate: selectedDate ?? this.selectedDate,
    todayDate: todayDate ?? this.todayDate,
    isPastDate: isPastDate ?? this.isPastDate,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    searchQuery: searchQuery ?? this.searchQuery,
    rows: rows ?? this.rows,
    baseline: baseline ?? this.baseline,
    initialSource: initialSource ?? this.initialSource,
    initialSourceDate: clearInitialSourceDate
        ? null
        : (initialSourceDate ?? this.initialSourceDate),
    skippedDraftCount: skippedDraftCount ?? this.skippedDraftCount,
    lastUndoPlan: clearUndoPlan ? null : (lastUndoPlan ?? this.lastUndoPlan),
    lastSummary: clearSummary ? null : (lastSummary ?? this.lastSummary),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
  );
}
