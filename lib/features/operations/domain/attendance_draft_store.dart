import 'package:radar_labor/core/constants/operations_constants.dart';

/// Persisted auto-draft payload for a team's daily attendance selection (PRD §8.5).
final class AttendanceDraftData {
  const AttendanceDraftData({
    required this.workerIds,
    required this.updatedAtUtc,
  });

  final List<String> workerIds;
  final DateTime updatedAtUtc;
}

/// Domain persistence contract for automatic attendance drafts (PRD §8.5).
abstract interface class AttendanceDraftStore {
  Future<AttendanceDraftData?> readDraft({
    required String teamId,
    required String date,
  });

  Future<void> writeDraft({
    required String teamId,
    required String date,
    required Iterable<String> workerIds,
  });

  Future<void> deleteDraft({required String teamId, required String date});

  Future<void> cleanupExpiredDrafts({
    required String todayBusinessDate,
    int retentionDays = OperationsConstants.draftRetentionDays,
  });
}
