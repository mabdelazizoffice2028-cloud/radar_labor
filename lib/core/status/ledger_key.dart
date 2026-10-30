import 'package:radar_labor/core/status/status_models.dart';

final class LedgerKey {
  const LedgerKey({
    required this.type,
    this.employeeUid,
    this.teamId,
    this.housingId,
  });

  final EventType type;
  final String? employeeUid;
  final String? teamId;
  final String? housingId;

  factory LedgerKey.fromEvent(LocalEvent event) => LedgerKey(
    type: event.type,
    employeeUid: event.employeeUid,
    teamId: event.teamId,
    housingId: event.housingId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LedgerKey &&
          type == other.type &&
          employeeUid == other.employeeUid &&
          teamId == other.teamId &&
          housingId == other.housingId;

  @override
  int get hashCode => Object.hash(type, employeeUid, teamId, housingId);
}
