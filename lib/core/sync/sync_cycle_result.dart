/// Outcome of a sync cycle (PRD §23.6, D-25, D-27).
final class SyncCycleResult {
  const SyncCycleResult({
    required this.uploadedEventsCount,
    required this.uploadedAuditsCount,
    required this.pendingRemaining,
    required this.rosterEpoch,
    this.sessionRevoked = false,
    this.offline = false,
  });

  final int uploadedEventsCount;
  final int uploadedAuditsCount;
  final int pendingRemaining;
  final int rosterEpoch;
  final bool sessionRevoked;
  final bool offline;
}
