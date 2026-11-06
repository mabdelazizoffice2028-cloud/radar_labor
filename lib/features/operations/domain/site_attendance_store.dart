import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_models.dart';

export 'package:radar_labor/features/operations/domain/site_attendance_models.dart';

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
