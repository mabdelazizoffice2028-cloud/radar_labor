import 'package:radar_labor/core/l10n/admin_audit_strings.dart';
import 'package:radar_labor/core/l10n/admin_user_strings.dart';

export 'package:radar_labor/core/l10n/admin_audit_strings.dart';
export 'package:radar_labor/core/l10n/admin_user_strings.dart';

/// Localized strings for Part B admin roster control, account reset, and audit log.
final class AdminStrings {
  const AdminStrings._();

  static String userAccountsTitle(bool ar) => AdminUserStrings.userAccountsTitle(ar);
  static String addUser(bool ar) => AdminUserStrings.addUser(ar);
  static String roleLabel(bool ar) => AdminUserStrings.roleLabel(ar);
  static String employeeLabel(bool ar) => AdminUserStrings.employeeLabel(ar);
  static String displayNameLabel(bool ar) => AdminUserStrings.displayNameLabel(ar);
  static String assignedTeams(bool ar) => AdminUserStrings.assignedTeams(ar);
  static String assignTeamRequired(bool ar) => AdminUserStrings.assignTeamRequired(ar);
  static String assignedHousing(bool ar) => AdminUserStrings.assignedHousing(ar);
  static String assignHousingRequired(bool ar) => AdminUserStrings.assignHousingRequired(ar);
  static String accountConflictError(bool ar) => AdminUserStrings.accountConflictError(ar);
  static String accountCreateError(bool ar) => AdminUserStrings.accountCreateError(ar);
  static String resetPasswordAction(bool ar) => AdminUserStrings.resetPasswordAction(ar);
  static String resetPasswordDone(bool ar, String pin) => AdminUserStrings.resetPasswordDone(ar, pin);
  static String deactivateAccountAction(bool ar) => AdminUserStrings.deactivateAccountAction(ar);
  static String accountDeactivatedBadge(bool ar) => AdminUserStrings.accountDeactivatedBadge(ar);
  static String importNamesAction(bool ar) => AdminUserStrings.importNamesAction(ar);
  static String importReviewTitle(bool ar) => AdminUserStrings.importReviewTitle(ar);
  static String importReviewBody(bool ar, int w, [int? s]) => AdminUserStrings.importReviewBody(ar, w, s);
  static String importConfirm(bool ar) => AdminUserStrings.importConfirm(ar);
  static String importDone(bool ar, int a, int u, [int? c]) => AdminUserStrings.importDone(ar, a, u, c);
  static String importFailed(bool ar) => AdminUserStrings.importFailed(ar);
  static String noNamesHint(bool ar) => AdminUserStrings.noNamesHint(ar);
  static String editUser(bool ar) => AdminUserStrings.editUser(ar);
  static String deleteUser(bool ar) => AdminUserStrings.deleteUser(ar);
  static String deleteUserConfirm(bool ar, String n) => AdminUserStrings.deleteUserConfirm(ar, n);
  static String lastManagerError(bool ar) => AdminUserStrings.lastManagerError(ar);
  static String accountUpdateError(bool ar) => AdminUserStrings.accountUpdateError(ar);
  static String accountsLoadError(bool ar) => AdminUserStrings.accountsLoadError(ar);
  static String nameRequired(bool ar) => AdminUserStrings.nameRequired(ar);
  static String selectSiteSupervisors(bool ar) => AdminUserStrings.selectSiteSupervisors(ar);
  static String selectCampusSupervisors(bool ar) => AdminUserStrings.selectCampusSupervisors(ar);
  static String batchActivated(bool ar, int count) => AdminUserStrings.batchActivated(ar, count);
  static String searchSupervisorHint(bool ar) => AdminUserStrings.searchSupervisorHint(ar);
  static String confirmSelection(bool ar) => AdminUserStrings.confirmSelection(ar);
  static String noWorkersFound(bool ar) => AdminUserStrings.noWorkersFound(ar);

  static String wipeRosterTitle(bool ar) => AdminAuditStrings.wipeRosterTitle(ar);
  static String wipeRosterWarning(bool ar) => AdminAuditStrings.wipeRosterWarning(ar);
  static String wipeRosterConfirmWord(bool ar) => AdminAuditStrings.wipeRosterConfirmWord(ar);
  static String wipeRosterExportButton(bool ar) => AdminAuditStrings.wipeRosterExportButton(ar);
  static String wipeRosterConfirmButton(bool ar) => AdminAuditStrings.wipeRosterConfirmButton(ar);
  static String archiveWorkerAction(bool ar) => AdminAuditStrings.archiveWorkerAction(ar);
  static String auditLogTab(bool ar) => AdminAuditStrings.auditLogTab(ar);
  static String auditLogEmpty(bool ar) => AdminAuditStrings.auditLogEmpty(ar);
  static String auditActionLabel(bool ar, String a) => AdminAuditStrings.auditActionLabel(ar, a);
  static String scopeHousingCount(bool ar, int c) => AdminAuditStrings.scopeHousingCount(ar, c);
  static String scopeTeamsCount(bool ar, int c) => AdminAuditStrings.scopeTeamsCount(ar, c);
  static String scopeFullApp(bool ar) => AdminAuditStrings.scopeFullApp(ar);
}
