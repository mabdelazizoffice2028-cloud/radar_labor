import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';

/// Live snapshot of a user's assigned team and housing scopes (PRD §5.4).
final class ScopeSnapshot {
  const ScopeSnapshot({
    this.teamIds = const <String>{},
    this.housingIds = const <String>{},
  });

  final Set<String> teamIds;
  final Set<String> housingIds;

  bool allowsTeam(String teamId) => teamIds.contains(teamId);

  bool allowsHousing(String housingId) => housingIds.contains(housingId);
}

/// Identifies the authenticated actor performing an operation (PRD §5.4).
final class ActorContext {
  const ActorContext({required this.userId, required this.role});

  final String userId;
  final AuthRole role;

  RoleCapabilities get capabilities => role.capabilities;
}
