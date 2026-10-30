import 'package:radar_labor/core/auth/role_capabilities_admin.dart';
import 'package:radar_labor/core/auth/role_capabilities_supervisors.dart';

export 'package:radar_labor/core/auth/auth_role_capabilities.dart';

/// Top-level navigation sections available in the app.
enum AppSection {
  dashboard,
  workers,
  teams,
  housing,
  checkIn,
  history,
  settings,
}

/// Immutable capability matrix for a role (single source of truth, PRD §5).
final class RoleCapabilities {
  const RoleCapabilities({
    required this.canViewDashboard,
    required this.canViewAllHistory,
    required this.canViewOwnHistory,
    required this.canManageReferenceData,
    required this.canManageAccounts,
    required this.canResolveConflicts,
    required this.canJustifyAbsence,
    required this.canRecordHousing,
    required this.canRecordSite,
    required this.canSetupTeam,
    required this.canEditOwnTeamMembers,
    required this.canAddCrossTeamWorker,
    required this.canResolveOwnSaveConflicts,
    required this.canEditPastDays,
    required this.canWipeRoster,
    required this.canViewAuditLog,
    required this.sections,
  });

  final bool canViewDashboard;
  final bool canViewAllHistory;
  final bool canViewOwnHistory;
  final bool canManageReferenceData;
  final bool canManageAccounts;
  final bool canResolveConflicts;
  final bool canJustifyAbsence;
  final bool canRecordHousing;
  final bool canRecordSite;
  final bool canSetupTeam;
  final bool canEditOwnTeamMembers;
  final bool canAddCrossTeamWorker;
  final bool canResolveOwnSaveConflicts;
  final bool canEditPastDays;
  final bool canWipeRoster;
  final bool canViewAuditLog;
  final List<AppSection> sections;

  static const RoleCapabilities admin = adminRoleCapabilities;
  static const RoleCapabilities housingSupervisor =
      housingSupervisorRoleCapabilities;
  static const RoleCapabilities siteSupervisor = siteSupervisorRoleCapabilities;
  static const RoleCapabilities viewer = viewerRoleCapabilities;
}
