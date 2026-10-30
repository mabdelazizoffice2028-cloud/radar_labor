import 'package:radar_labor/core/status/ledger_key.dart';
import 'package:radar_labor/core/status/status_models.dart';

export 'package:radar_labor/core/status/ledger_key.dart';

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
  Iterable<MapEntry<LedgerKey, LocalEvent>> get entries => _latestByKey.entries;

  LocalEvent? latestEventFor(LedgerKey key) => _latestByKey[key];

  LocalEvent? activeEventFor(LedgerKey key) {
    final latest = _latestByKey[key];
    return latest != null && latest.action == EventAction.set ? latest : null;
  }

  bool isSiteSubmitted(String teamId) =>
      activeEventFor(LedgerKey(type: EventType.siteSubmitted, teamId: teamId)) != null;

  LocalEvent? siteSubmissionEvent(String teamId) =>
      activeEventFor(LedgerKey(type: EventType.siteSubmitted, teamId: teamId));

  bool isHousingChecked(String housingId) =>
      activeEventFor(LedgerKey(type: EventType.housingCheck, housingId: housingId)) != null;

  LocalEvent? housingCheckEvent(String housingId) =>
      activeEventFor(LedgerKey(type: EventType.housingCheck, housingId: housingId));

  Set<String> presentWorkerIdsForTeam(String teamId) => Set.unmodifiable({
    for (final e in _latestByKey.entries)
      if (e.key.type == EventType.sitePresent && e.key.teamId == teamId && e.key.employeeUid != null && e.value.action == EventAction.set)
        e.key.employeeUid!,
  });

  Set<String> absentWorkerIdsForHousing(String housingId) => Set.unmodifiable({
    for (final e in _latestByKey.entries)
      if (e.key.type == EventType.housingAbsent && e.key.housingId == housingId && e.key.employeeUid != null && e.value.action == EventAction.set)
        e.key.employeeUid!,
  });

  bool hasActiveSitePresence(String uid) => _latestByKey.entries.any(
    (e) => e.key.type == EventType.sitePresent && e.key.employeeUid == uid && e.value.action == EventAction.set,
  );

  bool hasActiveJustification(String uid) => _latestByKey.entries.any(
    (e) => e.key.type == EventType.justification && e.key.employeeUid == uid && e.value.action == EventAction.set,
  );

  bool hasActiveHousingAbsent(String uid) => _latestByKey.entries.any(
    (e) => e.key.type == EventType.housingAbsent && e.key.employeeUid == uid && e.value.action == EventAction.set,
  );

  Set<String> activeTeamsForWorker(String uid) => {
    for (final e in _latestByKey.entries)
      if (e.key.type == EventType.sitePresent && e.key.employeeUid == uid && e.key.teamId != null && e.value.action == EventAction.set)
        e.key.teamId!,
  };
}
