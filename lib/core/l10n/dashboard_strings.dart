import 'package:radar_labor/core/l10n/bidi.dart';
import 'package:radar_labor/core/l10n/dashboard_dialog_strings.dart';

export 'package:radar_labor/core/l10n/dashboard_dialog_strings.dart';

/// Centralized localization for the Operations and Executive Dashboard.
final class DashboardStrings {
  const DashboardStrings._();

  static String businessDate(bool ar) => ar ? 'يوم العمل' : 'Business date';
  static String chooseBusinessDate(bool ar) => ar ? 'اختر يوم العمل' : 'Choose business date';
  static String couldNotLoadDashboard(bool ar) => ar ? 'تعذر تحميل لوحة الحالات' : 'Could not load dashboard';
  static String couldNotLoadWarnings(bool ar) => ar ? 'تعذر تحميل تنبيهات التسجيل' : 'Could not load submission warnings';
  static String campusesNotChecked(bool ar) => ar ? 'كامبوس لم يُفحص بعد' : 'CAMPOS not checked';
  static String teamsNotSubmitted(bool ar) => ar ? 'فرق لم تسجل بعد' : 'Teams not submitted';
  static String onSiteStatus(bool ar) => ar ? 'في الموقع' : 'On site';
  static String housingOnlyStatus(bool ar) => ar ? 'في الكامبوس فقط' : 'CAMPOS only';
  static String unknownStatus(bool ar) => ar ? 'غير معلوم' : 'Unknown';
  static String justifiedStatus(bool ar) => ar ? 'مبرر' : 'Justified';
  static String notRecordedStatus(bool ar) => ar ? 'لم يسجل بعد' : 'Not recorded';
  static String conflictsToReview(bool ar) => ar ? 'تعارضات تحتاج مراجعة' : 'Conflicts to review';
  static String resolve(bool ar) => ar ? 'تسوية' : 'Resolve';
  static String conflictHousingAndSite(bool ar) => ar ? 'غياب كامبوس مع حضور موقع' : 'CAMPOS absence and site presence';
  static String conflictMultipleTeams(bool ar) => ar ? 'مسجل في أكثر من فريق' : 'Multiple site teams';
  static String unknownWorkers(bool ar) => ar ? 'عمال غير معلومين' : 'Unknown workers';
  static String slaExceeded(bool ar) => ar ? 'تجاوز مهلة المتابعة' : 'SLA exceeded';
  static String campusAbsenceNoJustification(bool ar) => ar ? 'غياب كامبوس دون تبرير' : 'CAMPOS absence without justification';
  static String addJustification(bool ar) => ar ? 'إضافة تبرير' : 'Add justification';
  static String ledgerNotices(bool ar, int count) =>
      ar ? 'ملاحظات على السجل (${Bidi.isolateLtr(count.toString())})' : 'Ledger notices ($count)';
  static String noticeInactiveWorker(bool ar) => ar ? 'حدث لعامل معطل' : 'Event for inactive worker';
  static String noticeOutsideEmployment(bool ar) => ar ? 'حدث خارج فترة العمل' : 'Event outside employment';
  static String noticeLateEntry(bool ar) => ar ? 'تسجيل بتاريخ سابق' : 'Late entry';
  static String noticeRejectedEvent(bool ar) => ar ? 'حدث مرفوض' : 'Rejected event';

  static String fridayBannerTitle(bool ar) =>
      ar ? 'يوم الجمعة — وضع العمل الإضافي (لا يُحتسب غياب اليوم)' : 'Friday — Overtime Mode (No Absences Counted Today)';
  static String fridayOvertimeCard(bool ar) => ar ? 'إضافي الجمعة' : 'Friday Overtime';
  static String fridayRestCard(bool ar) => ar ? 'في راحة الجمعة' : 'On Friday Rest';
  static String presentOnSiteCard(bool ar) => ar ? 'موجود بالموقع' : 'Present on Site';
  static String absentCard(bool ar) => ar ? 'غائب' : 'Absent';
  static String justifiedCard(bool ar) => ar ? 'مبرر / بعذر' : 'Justified';
  static String notRecordedCard(bool ar) => ar ? 'لم يُرصد بعد' : 'Not Recorded';

  static String resolveConflictTitle(bool ar) => DashboardDialogStrings.resolveConflictTitle(ar);
  static String optionalNote(bool ar) => DashboardDialogStrings.optionalNote(ar);
  static String saveResolution(bool ar) => DashboardDialogStrings.saveResolution(ar);
  static String justifyAbsenceTitle(bool ar) => DashboardDialogStrings.justifyAbsenceTitle(ar);
  static String reasonSick(bool ar) => DashboardDialogStrings.reasonSick(ar);
  static String reasonPersonalPermission(bool ar) => DashboardDialogStrings.reasonPersonalPermission(ar);
  static String reasonOfficialErrand(bool ar) => DashboardDialogStrings.reasonOfficialErrand(ar);
  static String reasonOther(bool ar) => DashboardDialogStrings.reasonOther(ar);
  static String quickReasonOptional(bool ar) => DashboardDialogStrings.quickReasonOptional(ar);
  static String noteOptional(bool ar) => DashboardDialogStrings.noteOptional(ar);
  static String saveJustification(bool ar) => DashboardDialogStrings.saveJustification(ar);
  static String resolutionConfirmPresentLeftEarly(bool ar) => DashboardDialogStrings.resolutionConfirmPresentLeftEarly(ar);
  static String resolutionMovedDuringDay(bool ar) => DashboardDialogStrings.resolutionMovedDuringDay(ar);
  static String resolutionHousingError(bool ar) => DashboardDialogStrings.resolutionHousingError(ar);
  static String resolutionSiteError(bool ar) => DashboardDialogStrings.resolutionSiteError(ar);
  static String resolutionOfficialErrand(bool ar) => DashboardDialogStrings.resolutionOfficialErrand(ar);
  static String listSeparator(bool ar) => DashboardDialogStrings.listSeparator(ar);
}
