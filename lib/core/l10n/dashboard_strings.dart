import 'package:radar_labor/core/l10n/bidi.dart';

/// Centralized localization for the Operations and Executive Dashboard.
final class DashboardStrings {
  const DashboardStrings._();

  static String businessDate(bool ar) => ar ? 'يوم العمل' : 'Business date';

  static String chooseBusinessDate(bool ar) =>
      ar ? 'اختر يوم العمل' : 'Choose business date';

  static String couldNotLoadDashboard(bool ar) =>
      ar ? 'تعذر تحميل لوحة الحالات' : 'Could not load dashboard';

  static String couldNotLoadWarnings(bool ar) =>
      ar ? 'تعذر تحميل تنبيهات التسجيل' : 'Could not load submission warnings';

  static String campusesNotChecked(bool ar) =>
      ar ? 'مساكن لم تسجل بعد' : 'Campuses not checked';

  static String teamsNotSubmitted(bool ar) =>
      ar ? 'فرق لم تسجل بعد' : 'Teams not submitted';

  static String onSiteStatus(bool ar) => ar ? 'في الموقع' : 'On site';

  static String housingOnlyStatus(bool ar) =>
      ar ? 'في السكن فقط' : 'Campus only';

  static String unknownStatus(bool ar) => ar ? 'غير معلوم' : 'Unknown';

  static String justifiedStatus(bool ar) => ar ? 'مبرر' : 'Justified';

  static String notRecordedStatus(bool ar) =>
      ar ? 'لم يسجل بعد' : 'Not recorded';

  static String conflictsToReview(bool ar) =>
      ar ? 'تعارضات تحتاج مراجعة' : 'Conflicts to review';

  static String resolve(bool ar) => ar ? 'تسوية' : 'Resolve';

  static String conflictHousingAndSite(bool ar) =>
      ar ? 'غياب سكن مع حضور موقع' : 'Campus absence and site presence';

  static String conflictMultipleTeams(bool ar) =>
      ar ? 'مسجل في أكثر من فريق' : 'Multiple site teams';

  static String unknownWorkers(bool ar) =>
      ar ? 'عمال غير معلومين' : 'Unknown workers';

  static String slaExceeded(bool ar) =>
      ar ? 'تجاوز مهلة المتابعة' : 'SLA exceeded';

  static String campusAbsenceNoJustification(bool ar) =>
      ar ? 'غياب سكن دون تبرير' : 'Campus absence without justification';

  static String addJustification(bool ar) =>
      ar ? 'إضافة تبرير' : 'Add justification';

  static String ledgerNotices(bool ar, int count) => ar
      ? 'ملاحظات على السجل (${Bidi.isolateLtr(count.toString())})'
      : 'Ledger notices ($count)';

  static String noticeInactiveWorker(bool ar) =>
      ar ? 'حدث لعامل معطل' : 'Event for inactive worker';

  static String noticeOutsideEmployment(bool ar) =>
      ar ? 'حدث خارج فترة العمل' : 'Event outside employment';

  static String noticeLateEntry(bool ar) =>
      ar ? 'تسجيل بتاريخ سابق' : 'Late entry';

  static String noticeRejectedEvent(bool ar) =>
      ar ? 'حدث مرفوض' : 'Rejected event';

  static String resolveConflictTitle(bool ar) =>
      ar ? 'تسوية التعارض' : 'Resolve conflict';

  static String optionalNote(bool ar) =>
      ar ? 'ملاحظة اختيارية' : 'Optional note';

  static String saveResolution(bool ar) =>
      ar ? 'حفظ التسوية' : 'Save resolution';

  static String justifyAbsenceTitle(bool ar) =>
      ar ? 'تبرير الغياب' : 'Justify absence';

  static String reasonSick(bool ar) => ar ? 'مرض' : 'Sick leave';

  static String reasonPersonalPermission(bool ar) =>
      ar ? 'إذن شخصي' : 'Personal permission';

  static String reasonOfficialErrand(bool ar) =>
      ar ? 'مأمورية' : 'Official errand';

  static String reasonOther(bool ar) => ar ? 'سبب آخر' : 'Other';

  static String quickReasonOptional(bool ar) =>
      ar ? 'سبب سريع (اختياري)' : 'Quick reason (optional)';

  static String noteOptional(bool ar) =>
      ar ? 'ملاحظة (اختيارية)' : 'Note (optional)';

  static String saveJustification(bool ar) =>
      ar ? 'حفظ التبرير' : 'Save justification';

  static String resolutionConfirmPresentLeftEarly(bool ar) =>
      ar ? 'اعتماد الحضور، خرج مبكرًا' : 'Confirm present, left early';

  static String resolutionMovedDuringDay(bool ar) =>
      ar ? 'انتقل خلال اليوم' : 'Moved during the day';

  static String resolutionHousingError(bool ar) =>
      ar ? 'خطأ من السكن' : 'Campus error';

  static String resolutionSiteError(bool ar) =>
      ar ? 'خطأ من الموقع' : 'Site error';

  static String resolutionOfficialErrand(bool ar) =>
      ar ? 'مأمورية أو إذن' : 'Official errand or permission';

  static String listSeparator(bool ar) => ar ? '، ' : ', ';
}
