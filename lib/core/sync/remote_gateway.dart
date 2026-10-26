import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/status/status_models.dart';

/// Snapshot of server-side reference data downloaded during sync (PRD §23.6).
final class RemoteRosterSnapshot {
  const RemoteRosterSnapshot({
    required this.rosterEpoch,
    this.accountActive = true,
    this.employees = const <RemoteEmployeeRow>[],
  });

  final int rosterEpoch;
  final bool accountActive;
  final List<RemoteEmployeeRow> employees;
}

final class RemoteEmployeeRow {
  const RemoteEmployeeRow({
    required this.employeeUid,
    required this.employeeCode,
    required this.fullNameAr,
    this.fullNameEn,
    this.category = 'Worker',
    this.supplier,
    this.currentTeamId,
    this.housingId,
    this.isActive = true,
    this.rowVersion = 1,
  });

  final String employeeUid;
  final String employeeCode;
  final String fullNameAr;
  final String? fullNameEn;
  final String category;
  final String? supplier;
  final String? currentTeamId;
  final String? housingId;
  final bool isActive;
  final int rowVersion;
}

/// Result of an idempotent batch upload to the trusted server RPC (PRD §23.6).
final class RemoteUploadAck {
  const RemoteUploadAck({
    required this.acceptedEventIds,
    required this.acceptedAuditIds,
  });

  final Set<String> acceptedEventIds;
  final Set<String> acceptedAuditIds;
}

/// Abstract gateway isolating all network/cloud communication from the app & UI (PRD §17.4, Principle 8).
abstract interface class RemoteSyncGateway {
  Future<bool> isReachable();

  Future<RemoteUploadAck> uploadBatch({
    required String actorUserId,
    required AuthRole actorRole,
    required Set<String> allowedTeamIds,
    required Set<String> allowedHousingIds,
    required List<LocalEvent> events,
    required List<AuditEntry> audits,
  });

  Future<RemoteRosterSnapshot> fetchSnapshot({required String actorUserId});
}

/// Default offline-first gateway when no cloud backend is connected yet.
final class OfflineRemoteSyncGateway implements RemoteSyncGateway {
  const OfflineRemoteSyncGateway();

  @override
  Future<bool> isReachable() async => false;

  @override
  Future<RemoteUploadAck> uploadBatch({
    required String actorUserId,
    required AuthRole actorRole,
    required Set<String> allowedTeamIds,
    required Set<String> allowedHousingIds,
    required List<LocalEvent> events,
    required List<AuditEntry> audits,
  }) async => const RemoteUploadAck(
    acceptedEventIds: <String>{},
    acceptedAuditIds: <String>{},
  );

  @override
  Future<RemoteRosterSnapshot> fetchSnapshot({
    required String actorUserId,
  }) async => const RemoteRosterSnapshot(rosterEpoch: 1);
}
