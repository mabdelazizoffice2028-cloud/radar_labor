/// Immutable housing check draft payload stored in [LocalSettingsRepository].
final class HousingDraftData {
  const HousingDraftData({
    required this.reviewedWorkerIds,
    required this.absentWorkerIds,
    required this.updatedAtUtc,
  });

  final List<String> reviewedWorkerIds;
  final List<String> absentWorkerIds;
  final DateTime updatedAtUtc;
}

/// Abstract contract for reading, writing, and clearing local housing check drafts.
abstract interface class HousingDraftStore {
  Future<HousingDraftData?> readDraft({
    required String housingId,
    required String date,
  });

  Future<void> writeDraft({
    required String housingId,
    required String date,
    required Iterable<String> reviewedWorkerIds,
    required Iterable<String> absentWorkerIds,
  });

  Future<void> deleteDraft({required String housingId, required String date});
}
