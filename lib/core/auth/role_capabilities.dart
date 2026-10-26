import 'package:radar_labor/core/auth/auth_role.dart';

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

  static const RoleCapabilities admin = RoleCapabilities(
    canViewDashboard: true,
    canViewAllHistory: true,
    canViewOwnHistory: false,
    canManageReferenceData: true,
    canManageAccounts: true,
    canResolveConflicts: true,
    canJustifyAbsence: true,
    canRecordHousing: false,
    canRecordSite: false,
    canSetupTeam: false,
    canEditOwnTeamMembers: false,
    canAddCrossTeamWorker: false,
    canResolveOwnSaveConflicts: false,
    canEditPastDays: false,
    canWipeRoster: true,
    canViewAuditLog: true,
    sections: [
      AppSection.dashboard,
      AppSection.workers,
      AppSection.teams,
      AppSection.housing,
      AppSection.history,
      AppSection.settings,
    ],
  );

  static const RoleCapabilities housingSupervisor = RoleCapabilities(
    canViewDashboard: false,
    canViewAllHistory: false,
    canViewOwnHistory: true,
    canManageReferenceData: false,
    canManageAccounts: false,
    canResolveConflicts: false,
    canJustifyAbsence: false,
    canRecordHousing: true,
    canRecordSite: false,
    canSetupTeam: false,
    canEditOwnTeamMembers: false,
    canAddCrossTeamWorker: false,
    canResolveOwnSaveConflicts: false,
    canEditPastDays: true,
    canWipeRoster: false,
    canViewAuditLog: false,
    sections: [AppSection.checkIn, AppSection.history, AppSection.settings],
  );

  static const RoleCapabilities siteSupervisor = RoleCapabilities(
    canViewDashboard: false,
    canViewAllHistory: false,
    canViewOwnHistory: true,
    canManageReferenceData: false,
    canManageAccounts: false,
    canResolveConflicts: false,
    canJustifyAbsence: false,
    canRecordHousing: false,
    canRecordSite: true,
    canSetupTeam: true,
    canEditOwnTeamMembers: true,
    canAddCrossTeamWorker: true,
    canResolveOwnSaveConflicts: true,
    canEditPastDays: true,
    canWipeRoster: false,
    canViewAuditLog: false,
    sections: [AppSection.checkIn, AppSection.history, AppSection.settings],
  );

  static const RoleCapabilities viewer = RoleCapabilities(
    canViewDashboard: true,
    canViewAllHistory: false,
    canViewOwnHistory: false,
    canManageReferenceData: false,
    canManageAccounts: false,
    canResolveConflicts: false,
    canJustifyAbsence: false,
    canRecordHousing: false,
    canRecordSite: false,
    canSetupTeam: false,
    canEditOwnTeamMembers: false,
    canAddCrossTeamWorker: false,
    canResolveOwnSaveConflicts: false,
    canEditPastDays: false,
    canWipeRoster: false,
    canViewAuditLog: false,
    sections: [AppSection.dashboard, AppSection.settings],
  );
}

extension AuthRoleCapabilities on AuthRole {
  RoleCapabilities get capabilities => switch (this) {
    AuthRole.projectManager || AuthRole.hr => RoleCapabilities.admin,
    AuthRole.housingSupervisor => RoleCapabilities.housingSupervisor,
    AuthRole.siteSupervisor => RoleCapabilities.siteSupervisor,
    AuthRole.viewer => RoleCapabilities.viewer,
  };
}
