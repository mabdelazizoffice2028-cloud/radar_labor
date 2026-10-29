/// Result of an explicit "save and sync" attempt, kept separate from the local
/// save itself: data is always safe on the device before sync is attempted.
enum OperationSyncOutcome {
  /// Server accepted everything; nothing is left in the outbox.
  synced,

  /// Server reachable but some items are still queued locally.
  pending,

  /// Device is known to be offline; items stay queued locally.
  offline,

  /// The server was reached (or sync was attempted) and it failed.
  failed,

  /// Management ended the session during sync.
  sessionRevoked;

  /// Only a confirmed, fully drained sync may be reported as success.
  bool get isConfirmedSuccess => this == OperationSyncOutcome.synced;

  /// Classifies a finished sync cycle from its primitive result fields.
  static OperationSyncOutcome classify({
    required bool offline,
    required bool sessionRevoked,
    required int pendingRemaining,
  }) {
    if (offline) return OperationSyncOutcome.offline;
    if (sessionRevoked) return OperationSyncOutcome.sessionRevoked;
    return pendingRemaining > 0
        ? OperationSyncOutcome.pending
        : OperationSyncOutcome.synced;
  }
}
