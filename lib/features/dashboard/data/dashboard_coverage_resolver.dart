import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/status/status_models.dart';

final class DashboardCoverageResolver {
  const DashboardCoverageResolver();

  List<String> housingSupervisors({
    required String housingId,
    required List<UserScope> scopes,
    required Map<String, String> activeNameById,
  }) {
    final names = <String>{};
    for (final s in scopes) {
      if (s.scopeType == 'housing' && s.scopeId == housingId) {
        final name = activeNameById[s.userId];
        if (name != null && name.isNotEmpty) names.add(name);
      }
    }
    return List.unmodifiable(names.toList()..sort());
  }

  List<String> teamSupervisors({
    required Team team,
    required List<UserScope> scopes,
    required Map<String, String> activeNameById,
  }) {
    final names = <String>{};
    if (team.supervisorUserId != null) {
      final direct = activeNameById[team.supervisorUserId!];
      if (direct != null && direct.isNotEmpty) names.add(direct);
    }
    for (final s in scopes) {
      if (s.scopeType == 'team' && s.scopeId == team.teamId) {
        final name = activeNameById[s.userId];
        if (name != null && name.isNotEmpty) names.add(name);
      }
    }
    return List.unmodifiable(names.toList()..sort());
  }

  Set<String> latestKeys(
    Iterable<LocalEvent> source,
    String? Function(LocalEvent) selectKey,
  ) {
    final latest = <String, LocalEvent>{};
    for (final event in source) {
      if (event.delivery == EventDelivery.rejected) continue;
      final key = selectKey(event);
      if (key == null) continue;
      final prior = latest[key];
      if (prior == null || event.deviceSeq > prior.deviceSeq) {
        latest[key] = event;
      }
    }
    return {
      for (final entry in latest.entries)
        if (entry.value.action == EventAction.set) entry.key,
    };
  }
}
