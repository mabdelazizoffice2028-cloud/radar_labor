import 'package:radar_labor/core/status/status_models.dart';

/// Composite key identifying an event stream slot within a single business date (PRD §6.1).
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

/// Pure single-device effective-state calculator over immutable [LocalEvent]s (PRD §6.1).
final class AttendanceLedger {
  AttendanceLedger(Iterable<LocalEvent> dayEvents) {
    for (final event in dayEvents) {
      if (event.delivery == EventDelivery.rejected) continue;
      final key = LedgerKey.fromEvent(event);
      final prior = _latestByKey[key];
      if (prior == null || event.deviceSeq > prior.deviceSeq) {
        _latestByKey[key] = event;
      }
    }
  }

  final Map<LedgerKey, LocalEvent> _latestByKey = <LedgerKey, LocalEvent>{};

  /// Returns the latest event (set or clear) for [key], or null if never touched.
  LocalEvent? latestEventFor(LedgerKey key) => _latestByKey[key];

  /// Returns the latest active (`EventAction.set`) event for [key], or null if cleared/absent.
  LocalEvent? activeEventFor(LedgerKey key) {
    final latest = _latestByKey[key];
    return latest != null && latest.action == EventAction.set ? latest : null;
  }

  /// Whether [teamId] has an active `siteSubmitted` event for the day.
  bool isSiteSubmitted(String teamId) =>
      activeEventFor(
        LedgerKey(type: EventType.siteSubmitted, teamId: teamId),
      ) !=
      null;

  /// Latest active `siteSubmitted` event for [teamId], if any.
  LocalEvent? siteSubmissionEvent(String teamId) =>
      activeEventFor(LedgerKey(type: EventType.siteSubmitted, teamId: teamId));

  /// Whether [housingId] has an active `housingCheck` event for the day.
  bool isHousingChecked(String housingId) =>
      activeEventFor(
        LedgerKey(type: EventType.housingCheck, housingId: housingId),
      ) !=
      null;

  /// Latest active `housingCheck` event for [housingId], if any.
  LocalEvent? housingCheckEvent(String housingId) => activeEventFor(
    LedgerKey(type: EventType.housingCheck, housingId: housingId),
  );

  /// Active present worker IDs for [teamId].
  Set<String> presentWorkerIdsForTeam(String teamId) {
    final result = <String>{};
    for (final entry in _latestByKey.entries) {
      if (entry.key.type == EventType.sitePresent &&
          entry.key.teamId == teamId &&
          entry.key.employeeUid != null &&
          entry.value.action == EventAction.set) {
        result.add(entry.key.employeeUid!);
      }
    }
    return Set.unmodifiable(result);
  }

  /// Active absent worker IDs for [housingId].
  Set<String> absentWorkerIdsForHousing(String housingId) {
    final result = <String>{};
    for (final entry in _latestByKey.entries) {
      if (entry.key.type == EventType.housingAbsent &&
          entry.key.housingId == housingId &&
          entry.key.employeeUid != null &&
          entry.value.action == EventAction.set) {
        result.add(entry.key.employeeUid!);
      }
    }
    return Set.unmodifiable(result);
  }

  /// Active `sitePresent` events for [employeeUid] in teams other than [excludeTeamId].
  List<LocalEvent> otherTeamPresencesForWorker({
    required String employeeUid,
    required String excludeTeamId,
  }) {
    final events = <LocalEvent>[];
    for (final entry in _latestByKey.entries) {
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

  /// Returns the latest event touching [teamId] (`siteSubmitted` or `sitePresent`) to identify the last actor.
  LocalEvent? lastTeamRecordingEvent(String teamId) {
    LocalEvent? latest;
    for (final entry in _latestByKey.entries) {
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

  /// Returns the latest event touching [housingId] (`housingCheck` or `housingAbsent`).
  LocalEvent? lastHousingRecordingEvent(String housingId) {
    LocalEvent? latest;
    for (final entry in _latestByKey.entries) {
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
