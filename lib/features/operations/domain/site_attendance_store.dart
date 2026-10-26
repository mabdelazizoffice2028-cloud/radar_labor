import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

/// Row origin in the daily site attendance list (PRD §8.1).
enum WorkerRowOrigin { member, guest, locked }

/// Priority source that populated the initial daily selection (PRD §8.1, §8.2).
enum AttendanceInitialSource { draft, savedDay, suggestion, empty }

/// Single worker row in the smart daily check-in list (PRD §8.1).
final class AttendanceRow {
  const AttendanceRow({
    required this.worker,
    required this.isPresent,
    required this.origin,
    this.originTeamNameAr,
    this.originTeamNameEn,
  });

  final WorkerOption worker;
  final bool isPresent;
  final WorkerRowOrigin origin;
  final String? originTeamNameAr;
  final String? originTeamNameEn;

  bool get isLocked => origin == WorkerRowOrigin.locked;
  bool get isGuest => origin == WorkerRowOrigin.guest;

  String? originTeamDisplayName({required bool arabic}) {
    if (originTeamNameAr == null && originTeamNameEn == null) return null;
    return arabic
        ? (originTeamNameAr ?? originTeamNameEn)
        : (originTeamNameEn ?? originTeamNameAr);
  }

  AttendanceRow copyWith({bool? isPresent}) => AttendanceRow(
    worker: worker,
    isPresent: isPresent ?? this.isPresent,
    origin: origin,
    originTeamNameAr: originTeamNameAr,
    originTeamNameEn: originTeamNameEn,
  );
}

/// Search result item when adding a guest worker from another team (PRD §8.6).
final class CrossTeamWorkerOption {
  const CrossTeamWorkerOption({
    required this.worker,
    this.teamId,
    this.teamNameAr,
    this.teamNameEn,
  });

  final WorkerOption worker;
  final String? teamId;
  final String? teamNameAr;
  final String? teamNameEn;

  String? teamDisplayName({required bool arabic}) {
    if (teamId == null) return null;
    return arabic
        ? (teamNameAr ?? teamId)
        : (teamNameEn ?? teamNameAr ?? teamId);
  }
}

/// Initial loaded data for a team and business date (PRD §8.2, §8.3).
final class LoadedSiteAttendanceDay {
  const LoadedSiteAttendanceDay({
    required this.team,
    required this.date,
    required this.isPastDate,
    required this.rows,
    required this.baseline,
    required this.initialSource,
    this.initialSourceDate,
    this.skippedDraftCount = 0,
  });

  final EntityOption team;
  final String date;
  final bool isPastDate;
  final List<AttendanceRow> rows;
  final AttendanceBaseline baseline;
  final AttendanceInitialSource initialSource;
  final String? initialSourceDate;
  final int skippedDraftCount;
}

/// Pre-save package containing diff summary and detected same-day conflicts (PRD §8.1, §9, §10).
final class PreparedSiteSave {
  const PreparedSiteSave({
    required this.team,
    required this.date,
    required this.selectedWorkerIds,
    required this.diff,
    required this.conflicts,
    required this.workersById,
  });

  final EntityOption team;
  final String date;
  final Set<String> selectedWorkerIds;
  final AttendanceDiffResult diff;
  final List<AttendanceConflict> conflicts;
  final Map<String, WorkerOption> workersById;
}

/// Domain persistence contract for smart daily site attendance (PRD §8, §9, §10).
abstract interface class SiteAttendanceStore {
  String currentBusinessDate();

  Stream<List<EntityOption>> watchScopedTeams(Set<String> allowedTeamIds);

  Future<LoadedSiteAttendanceDay> loadDay({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required EntityOption team,
    required String date,
    required bool arabic,
  });

  Future<List<CrossTeamWorkerOption>> searchCrossTeamWorkers({
    required String query,
    required Set<String> excludeWorkerIds,
    required bool arabic,
  });

  Future<PreparedSiteSave> prepareSave({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required EntityOption team,
    required String date,
    required List<AttendanceRow> rows,
    required AttendanceBaseline baseline,
    required bool arabic,
  });

  Future<({LedgerUndoPlan undoPlan, AttendanceSummary summary})> save({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required PreparedSiteSave prepared,
    required Map<String, ConflictResolutionChoice> resolutions,
    required bool arabic,
  });

  Future<void> undo({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
    required LedgerUndoPlan plan,
  });
}
