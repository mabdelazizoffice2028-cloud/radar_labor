import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/status/status_models.dart';

export 'package:radar_labor/core/sync/offline_remote_sync_gateway.dart';

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
    this.employmentType = 'company',
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
  final String employmentType;
  final bool isActive;
  final int rowVersion;
}

final class RemoteUploadAck {
  const RemoteUploadAck({
    required this.acceptedEventIds,
    required this.acceptedAuditIds,
    this.rejectedEvents = const {},
  });

  final Set<String> acceptedEventIds;
  final Set<String> acceptedAuditIds;
  final Map<String, String> rejectedEvents;
}

final class RemoteSyncPullResult {
  const RemoteSyncPullResult({
    required this.events,
    required this.lastServerSeq,
  });

  final List<LocalEvent> events;
  final int lastServerSeq;
}

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

  Future<RemoteSyncPullResult> pullEvents({
    required int sinceServerSeq,
    int limit = 200,
  });

  Future<RemoteRosterSnapshot> fetchSnapshot({required String actorUserId});
}
