import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

/// Supervisor's resolution choice for a same-day local attendance conflict (PRD §9.2).
enum ConflictResolutionChoice {
  transferDuringDay,
  removeFromOtherTeam,
  skipWorker,
}

/// Represents a same-day, same-device attendance conflict for a worker (PRD §9.1).
final class AttendanceConflict {
  const AttendanceConflict({
    required this.worker,
    required this.otherTeamId,
    required this.otherTeamNameAr,
    this.otherTeamNameEn,
    required this.recordedAtUtc,
    this.recordedByUserId,
  });

  final WorkerOption worker;
  final String otherTeamId;
  final String otherTeamNameAr;
  final String? otherTeamNameEn;
  final DateTime recordedAtUtc;
  final String? recordedByUserId;

  String otherTeamDisplayName({required bool arabic}) =>
      arabic ? otherTeamNameAr : (otherTeamNameEn ?? otherTeamNameAr);
}

/// Pure detector for same-day, same-device cross-team attendance conflicts (PRD §9.1).
abstract final class ConflictDetector {
  static List<AttendanceConflict> detect({
    required AttendanceLedger ledger,
    required String currentTeamId,
    required Set<String> selectedWorkerIds,
    required Map<String, WorkerOption> workersById,
    required Map<String, EntityOption> teamsById,
    required bool arabic,
  }) {
    final conflicts = <AttendanceConflict>[];
    for (final workerId in selectedWorkerIds) {
      final worker = workersById[workerId];
      if (worker == null) continue;
      final otherEvents = ledger.otherTeamPresencesForWorker(
        employeeUid: workerId,
        excludeTeamId: currentTeamId,
      );
      if (otherEvents.isEmpty) continue;
      // Use the latest active presence in another team
      final latestOther = otherEvents.last;
      final otherTeamId = latestOther.teamId!;
      final otherTeam = teamsById[otherTeamId];
      conflicts.add(
        AttendanceConflict(
          worker: worker,
          otherTeamId: otherTeamId,
          otherTeamNameAr: otherTeam?.nameAr ?? otherTeamId,
          otherTeamNameEn: otherTeam?.nameEn,
          recordedAtUtc:
              latestOther.deviceTimeUtc ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          recordedByUserId: latestOther.userId,
        ),
      );
    }

    conflicts.sort(
      (a, b) => NameCollation.compareWorkers(
        nameA: a.worker.displayName(arabic: arabic),
        codeA: a.worker.code,
        idA: a.worker.id,
        nameB: b.worker.displayName(arabic: arabic),
        codeB: b.worker.code,
        idB: b.worker.id,
      ),
    );
    return List.unmodifiable(conflicts);
  }
}
