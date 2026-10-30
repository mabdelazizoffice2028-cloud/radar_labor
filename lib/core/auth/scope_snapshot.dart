import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';

/// Active operational scopes assigned to an actor (PRD §5.4).
final class ScopeSnapshot {
  const ScopeSnapshot({
    this.teamIds = const {},
    this.housingIds = const {},
  });

  final Set<String> teamIds;
  final Set<String> housingIds;

  bool allowsTeam(String teamId) => teamIds.contains(teamId);

  bool allowsHousing(String housingId) => housingIds.contains(housingId);
}

/// Identifies the authenticated actor performing an operation (PRD §5.4).
final class ActorContext {
  const ActorContext({
    required this.userId,
    required this.role,
    this.name,
  });

  final String userId;
  final AuthRole role;
  final String? name;

  String get displayName => (name != null && name!.isNotEmpty) ? name! : userId;

  RoleCapabilities get capabilities => role.capabilities;
}
