import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/state/site_draft_persistence.dart';

mixin SiteAttendanceRosterOps on Notifier<SiteAttendanceState>, SiteDraftPersistence {
  bool get isArabic;

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);

  void toggleWorker(String workerId) => _updateRows([
    for (final row in state.rows)
      if (row.worker.id == workerId && !row.isLocked) row.copyWith(isPresent: !row.isPresent) else row,
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

  void selectDefaultCrew() {
    _updateRows([
      for (final row in state.rows)
        if (!row.isLocked && row.origin == WorkerRowOrigin.member)
          row.copyWith(isPresent: true)
        else
          row,
    ]);
  }

  void addGuestWorker(CrossTeamWorkerOption guest) {
    if (state.existingWorkerIds.contains(guest.worker.id)) return;
    final ar = isArabic;
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
    scheduleDraftWrite();
  }
}
