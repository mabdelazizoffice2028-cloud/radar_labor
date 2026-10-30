import 'package:radar_labor/core/status/attendance_ledger.dart';
import 'package:radar_labor/core/status/status_models.dart';

export 'package:radar_labor/core/status/attendance_ledger.dart';

extension AttendanceLedgerOpsExtension on AttendanceLedger {
  List<LocalEvent> otherTeamPresencesForWorker({
    required String employeeUid,
    required String excludeTeamId,
  }) {
    final events = <LocalEvent>[];
    for (final entry in entries) {
      if (entry.key.type == EventType.sitePresent &&
          entry.key.employeeUid == employeeUid &&
          entry.key.teamId != null &&
          entry.key.teamId != excludeTeamId &&
          entry.value.action == EventAction.set) {
        events.add(entry.value);
      }
    }
    events.sort((a, b) => a.deviceSeq.compareTo(b.deviceSeq));
    return List.unmodifiable(events);
  }

  LocalEvent? lastTeamRecordingEvent(String teamId) {
    LocalEvent? latest;
    for (final entry in entries) {
      if (entry.key.teamId == teamId &&
          (entry.key.type == EventType.siteSubmitted ||
              entry.key.type == EventType.sitePresent)) {
        if (latest == null || entry.value.deviceSeq > latest.deviceSeq) {
          latest = entry.value;
        }
      }
    }
    return latest;
  }

  LocalEvent? lastHousingRecordingEvent(String housingId) {
    LocalEvent? latest;
    for (final entry in entries) {
      if (entry.key.housingId == housingId &&
          (entry.key.type == EventType.housingCheck ||
              entry.key.type == EventType.housingAbsent)) {
        if (latest == null || entry.value.deviceSeq > latest.deviceSeq) {
          latest = entry.value;
        }
      }
    }
    return latest;
  }
}
