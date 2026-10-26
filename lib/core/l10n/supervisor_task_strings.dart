/// Localized strings for supervisor daily task summary and scoped worker lookup (Phase 5).
final class SupervisorTaskStrings {
  const SupervisorTaskStrings._();

  static String taskSummaryTitle(bool ar) =>
      ar ? 'ملخص مهمة اليوم' : "Today's Task Summary";

  static String todayApprovedDate(bool ar, String date) =>
      ar ? 'يوم العمل المعتمد: $date' : 'Approved business date: $date';

  static String taskStatusNotStarted(bool ar) =>
      ar ? 'لم يبدأ بعد' : 'Not Started';

  static String taskStatusDraftSaved(bool ar) =>
      ar ? 'مسودة محفوظة محلياً' : 'Draft Saved Locally';

  static String taskStatusSavedCompleted(bool ar) =>
      ar ? 'تم الحفظ محلياً — مكتمل' : 'Saved Locally / Completed';

  static String scopedWorkerSearchHint(bool ar) =>
      ar ? 'بحث في نطاقي الميداني…' : 'Search in assigned scope…';

  static String scopedWorkerLookupTitle(bool ar) =>
      ar ? 'الاستعلام عن عمال النطاق' : 'Scoped Worker Status Lookup';

  static String workerStatusReviewCompleted(bool ar) =>
      ar ? 'تم التسجيل اليوم' : 'Recorded today';

  static String workerStatusReviewDraft(bool ar) =>
      ar ? 'مسودة غير مكتملة' : 'Draft in progress';

  static String workerStatusReviewNotStarted(bool ar) =>
      ar ? 'لم يسجل اليوم' : 'Not recorded today';

  static String noScopedWorkersFound(bool ar) =>
      ar ? 'لا يوجد عمال مطابقون في النطاق' : 'No matching workers in scope';

  static String operationalStatusLabel(bool ar) =>
      ar ? 'الحالة التشغيلية' : 'Operational Status';

  static String dailyCheckinStatusLabel(bool ar) =>
      ar ? 'حالة تسجيل اليوم' : "Today's Check-in";

  static String openLookupAction(bool ar) =>
      ar ? 'استعلام سريع' : 'Quick Lookup';
}
