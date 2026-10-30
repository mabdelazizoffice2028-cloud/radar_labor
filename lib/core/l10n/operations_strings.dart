import 'package:radar_labor/core/l10n/operations_actions_strings.dart';
import 'package:radar_labor/core/l10n/operations_checkin_strings.dart';
import 'package:radar_labor/core/l10n/operations_error_strings.dart';
import 'package:radar_labor/core/l10n/operations_wizard_strings.dart';

export 'package:radar_labor/core/l10n/operations_actions_strings.dart';
export 'package:radar_labor/core/l10n/operations_checkin_strings.dart';
export 'package:radar_labor/core/l10n/operations_error_strings.dart';
export 'package:radar_labor/core/l10n/operations_wizard_strings.dart';

/// Central façade preserving full backward compatibility for OperationsStrings.
abstract final class OperationsStrings {
  static String setupTeamWizardTitle(bool ar) => OperationsWizardStrings.setupTeamWizardTitle(ar);
  static String createNewTeam(bool ar) => OperationsWizardStrings.createNewTeam(ar);
  static String wizardStepOf(bool ar, int c, int t) => OperationsWizardStrings.wizardStepOf(ar, c, t);
  static String wizardNext(bool ar) => OperationsWizardStrings.wizardNext(ar); static String wizardBack(bool ar) => OperationsWizardStrings.wizardBack(ar);
  static String confirmAndSave(bool ar) => OperationsWizardStrings.confirmAndSave(ar); static String confirmWorkersTitle(bool ar) => OperationsWizardStrings.confirmWorkersTitle(ar);
  static String confirmCreateEmptyTeam(bool ar) => OperationsWizardStrings.confirmCreateEmptyTeam(ar); static String teamCreated(bool ar) => OperationsWizardStrings.teamCreated(ar);
  static String editTeam(bool ar) => OperationsWizardStrings.editTeam(ar); static String teamMembersSaved(bool ar) => OperationsWizardStrings.teamMembersSaved(ar);
  static String noTeamsYetSupervisor(bool ar) => OperationsWizardStrings.noTeamsYetSupervisor(ar); static String teamsLoadFailed(bool ar) => OperationsWizardStrings.teamsLoadFailed(ar);
  static String workersSelected(bool ar, int n) => OperationsWizardStrings.workersSelected(ar, n); static String selectAll(bool ar) => OperationsWizardStrings.selectAll(ar);
  static String clearAll(bool ar) => OperationsWizardStrings.clearAll(ar); static String inactiveBadge(bool ar) => OperationsWizardStrings.inactiveBadge(ar);
  static String workerAssignedElsewhere(bool ar, String t) => OperationsWizardStrings.workerAssignedElsewhere(ar, t);
  static String teamNameArabicLabel(bool ar) => OperationsWizardStrings.teamNameArabicLabel(ar); static String teamNameEnglishLabel(bool ar) => OperationsWizardStrings.teamNameEnglishLabel(ar);
  static String searchWorkersHint(bool ar) => OperationsWizardStrings.searchWorkersHint(ar);
  static String workerSelectedState(bool ar) => OperationsWizardStrings.workerSelectedState(ar); static String workerUnselectedState(bool ar) => OperationsWizardStrings.workerUnselectedState(ar);

  static String recordingForDate(bool ar, String d) => OperationsCheckinStrings.recordingForDate(ar, d);
  static String pastDateWarning(bool ar) => OperationsCheckinStrings.pastDateWarning(ar); static String changeDate(bool ar) => OperationsCheckinStrings.changeDate(ar);
  static String draftRestored(bool ar) => OperationsCheckinStrings.draftRestored(ar); static String draftRestoredPartial(bool ar, int n) => OperationsCheckinStrings.draftRestoredPartial(ar, n);
  static String suggestionFromDate(bool ar, String d) => OperationsCheckinStrings.suggestionFromDate(ar, d); static String savedDayLoaded(bool ar) => OperationsCheckinStrings.savedDayLoaded(ar);
  static String addFromAnotherTeam(bool ar) => OperationsCheckinStrings.addFromAnotherTeam(ar); static String fromTeamBadge(bool ar, String t) => OperationsCheckinStrings.fromTeamBadge(ar, t);
  static String crossTeamSearchHint(bool ar) => OperationsCheckinStrings.crossTeamSearchHint(ar); static String noSearchResults(bool ar) => OperationsCheckinStrings.noSearchResults(ar);
  static String removeGuest(bool ar) => OperationsCheckinStrings.removeGuest(ar); static String presentLabel(bool ar) => OperationsCheckinStrings.presentLabel(ar);
  static String notPresentLabel(bool ar) => OperationsCheckinStrings.notPresentLabel(ar); static String noTeam(bool ar) => OperationsCheckinStrings.noTeam(ar);
  static String zeroWorkersConfirmation(bool ar) => OperationsCheckinStrings.zeroWorkersConfirmation(ar);
  static String preSaveDiffTotal(bool ar, int t, int a, int r) => OperationsCheckinStrings.preSaveDiffTotal(ar, t, a, r);
  static String diffBaselineLastSave(bool ar) => OperationsCheckinStrings.diffBaselineLastSave(ar); static String diffBaselineDate(bool ar, String d) => OperationsCheckinStrings.diffBaselineDate(ar, d);
  static String diffNoBaseline(bool ar) => OperationsCheckinStrings.diffNoBaseline(ar); static String diffAddedTitle(bool ar) => OperationsCheckinStrings.diffAddedTitle(ar);
  static String diffRemovedTitle(bool ar) => OperationsCheckinStrings.diffRemovedTitle(ar); static String diffNoChanges(bool ar) => OperationsCheckinStrings.diffNoChanges(ar);
  static String localConflictTitle(bool ar) => OperationsCheckinStrings.localConflictTitle(ar); static String localConflictRecordedAt(bool ar, String time) => OperationsCheckinStrings.localConflictRecordedAt(ar, time);
  static String localConflictBody(bool ar, String w, String t) => OperationsCheckinStrings.localConflictBody(ar, w, t);
  static String resolveAsTransfer(bool ar) => OperationsCheckinStrings.resolveAsTransfer(ar); static String resolveAsCorrection(bool ar) => OperationsCheckinStrings.resolveAsCorrection(ar);
  static String resolveSkipWorker(bool ar) => OperationsCheckinStrings.resolveSkipWorker(ar);

  static String selectTeam(bool ar) => OperationsActionsStrings.selectTeam(ar); static String selectHousing(bool ar) => OperationsActionsStrings.selectHousing(ar);
  static String addTeamToStart(bool ar) => OperationsActionsStrings.addTeamToStart(ar); static String addHousingToStart(bool ar) => OperationsActionsStrings.addHousingToStart(ar);
  static String noWorkersInTeam(bool ar) => OperationsActionsStrings.noWorkersInTeam(ar); static String noWorkersInHousing(bool ar) => OperationsActionsStrings.noWorkersInHousing(ar);
  static String codeLabel(bool ar) => OperationsActionsStrings.codeLabel(ar); static String presentCountLabel(bool ar, int count) => OperationsActionsStrings.presentCountLabel(ar, count);
  static String markedAbsentCount(bool ar, int count) => OperationsActionsStrings.markedAbsentCount(ar, count); static String savingLabel(bool ar) => OperationsActionsStrings.savingLabel(ar);
  static String confirmTeamSubmission(bool ar) => OperationsActionsStrings.confirmTeamSubmission(ar); static String noAbsencesSaveCheck(bool ar) => OperationsActionsStrings.noAbsencesSaveCheck(ar);
  static String confirmAbsencesAndSave(bool ar) => OperationsActionsStrings.confirmAbsencesAndSave(ar); static String confirmSiteAttendanceTitle(bool ar) => OperationsActionsStrings.confirmSiteAttendanceTitle(ar);
  static String confirmHousingCheckTitle(bool ar) => OperationsActionsStrings.confirmHousingCheckTitle(ar); static String reviewAction(bool ar) => OperationsActionsStrings.reviewAction(ar);
  static String confirmAction(bool ar) => OperationsActionsStrings.confirmAction(ar); static String undoAction(bool ar) => OperationsActionsStrings.undoAction(ar);
  static String teamSavedLocally(bool ar) => OperationsActionsStrings.teamSavedLocally(ar); static String housingSavedLocally(bool ar) => OperationsActionsStrings.housingSavedLocally(ar);
  static String whatsappSummaryTitle(bool ar) => OperationsActionsStrings.whatsappSummaryTitle(ar); static String copyTextAction(bool ar) => OperationsActionsStrings.copyTextAction(ar);
  static String closeAction(bool ar) => OperationsActionsStrings.closeAction(ar); static String housingCheckTab(bool ar) => OperationsActionsStrings.housingCheckTab(ar);
  static String siteAttendanceTab(bool ar) => OperationsActionsStrings.siteAttendanceTab(ar); static String startCampusCheckAction(bool ar) => OperationsActionsStrings.startCampusCheckAction(ar);
  static String noAbsencesTodayAction(bool ar) => OperationsActionsStrings.noAbsencesTodayAction(ar); static String dayLockedOut(bool ar) => OperationsActionsStrings.dayLockedOut(ar);
  static String noAbsencesConfirmed(bool ar) => OperationsActionsStrings.noAbsencesConfirmed(ar); static String startSiteAttendanceAction(bool ar) => OperationsActionsStrings.startSiteAttendanceAction(ar);
  static String nextConfirmAction(bool ar) => OperationsActionsStrings.nextConfirmAction(ar); static String saveLocallyOnlyAction(bool ar) => OperationsActionsStrings.saveLocallyOnlyAction(ar);
  static String saveAndSyncNowAction(bool ar) => OperationsActionsStrings.saveAndSyncNowAction(ar); static String syncSuccessMessage(bool ar) => OperationsActionsStrings.syncSuccessMessage(ar);
  static String syncOfflineFallbackMessage(bool ar) => OperationsActionsStrings.syncOfflineFallbackMessage(ar); static String syncPendingMessage(bool ar) => OperationsActionsStrings.syncPendingMessage(ar);
  static String unsavedChangesTitle(bool ar) => OperationsActionsStrings.unsavedChangesTitle(ar); static String unsavedChangesBody(bool ar) => OperationsActionsStrings.unsavedChangesBody(ar);
  static String stayAction(bool ar) => OperationsActionsStrings.stayAction(ar); static String leaveAction(bool ar) => OperationsActionsStrings.leaveAction(ar);
  static String selectAbsentWorkersHint(bool ar) => OperationsActionsStrings.selectAbsentWorkersHint(ar); static String selectPresentWorkersHint(bool ar) => OperationsActionsStrings.selectPresentWorkersHint(ar);
  static String fridayOvertimeMode(bool ar) => OperationsActionsStrings.fridayOvertimeMode(ar); static String fridayRestAbsenceClosed(bool ar) => OperationsActionsStrings.fridayRestAbsenceClosed(ar);
  static String fridayOvertimeCountLabel(bool ar, int count) => OperationsActionsStrings.fridayOvertimeCountLabel(ar, count); static String selectDefaultCrew(bool ar) => OperationsActionsStrings.selectDefaultCrew(ar);
  static String fridayBannerTitle(bool ar) => OperationsActionsStrings.fridayBannerTitle(ar); static String fridaySaveConfirm(bool ar, int count) => OperationsActionsStrings.fridaySaveConfirm(ar, count);
  static String fridayOvertimeLabel(bool ar) => OperationsActionsStrings.fridayOvertimeLabel(ar); static String fridayRestLabel(bool ar) => OperationsActionsStrings.fridayRestLabel(ar);
  static String confirmFridayOvertime(bool ar) => OperationsActionsStrings.confirmFridayOvertime(ar);

  static String errPermissionDenied(bool ar) => OperationsErrorStrings.errPermissionDenied(ar); static String errDateOutOfWindow(bool ar) => OperationsErrorStrings.errDateOutOfWindow(ar);
  static String errFutureDate(bool ar) => OperationsErrorStrings.errFutureDate(ar); static String errWorkersUnavailable(bool ar) => OperationsErrorStrings.errWorkersUnavailable(ar);
  static String errScopeChanged(bool ar) => OperationsErrorStrings.errScopeChanged(ar); static String errUnresolvedConflicts(bool ar) => OperationsErrorStrings.errUnresolvedConflicts(ar);
  static String errTeamNameInvalid(bool ar) => OperationsErrorStrings.errTeamNameInvalid(ar); static String errTeamNameExists(bool ar) => OperationsErrorStrings.errTeamNameExists(ar);
  static String errSaveFailed(bool ar) => OperationsErrorStrings.errSaveFailed(ar); static String errDatabaseBusy(bool ar) => OperationsErrorStrings.errDatabaseBusy(ar);
  static String errSessionRevoked(bool ar) => OperationsErrorStrings.errSessionRevoked(ar); static String errActivationRequired(bool ar) => OperationsErrorStrings.errActivationRequired(ar);
  static String errSyncFailed(bool ar) => OperationsErrorStrings.errSyncFailed(ar); static String errRosterWipeNotConfirmed(bool ar) => OperationsErrorStrings.errRosterWipeNotConfirmed(ar); static String errFridayAbsenceNotAllowed(bool ar) => OperationsErrorStrings.errFridayAbsenceNotAllowed(ar);
}
