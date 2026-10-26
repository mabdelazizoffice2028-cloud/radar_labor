/// Pure domain model for an append-only audit log entry (PRD §17.4, §23.5, D-26).
/// Contains only IDs, action codes, and timestamps — zero personal names or identity numbers (Q-5).
final class AuditEntry {
  const AuditEntry({
    required this.auditId,
    required this.userId,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.deviceId,
    required this.deviceTime,
    this.receivedAt,
    this.syncStatus = 'pending',
  });

  final String auditId;
  final String? userId;
  final String action;
  final String entityType;
  final String entityId;
  final String deviceId;
  final DateTime deviceTime;
  final DateTime? receivedAt;
  final String syncStatus;
}

/// View model with resolved display names for the admin-only Audit Log screen (PRD §23.5).
final class ResolvedAuditEntry {
  const ResolvedAuditEntry({
    required this.entry,
    required this.actorDisplayName,
    this.entityDisplayName,
  });

  final AuditEntry entry;
  final String actorDisplayName;
  final String? entityDisplayName;
}
