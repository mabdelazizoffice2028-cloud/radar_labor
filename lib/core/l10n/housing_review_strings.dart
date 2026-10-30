/// Localized strings for the 3-state housing review workflow (Phase 4).
final class HousingReviewStrings {
  const HousingReviewStrings._();

  static String reviewStateUnreviewed(bool ar) =>
      ar ? 'لم يراجع' : 'Unreviewed';

  static String reviewStateReviewed(bool ar) =>
      ar ? 'تمت المراجعة (موجود)' : 'Reviewed (Present)';

  static String reviewStateAbsent(bool ar) => ar ? 'غائب' : 'Absent';

  static String markRemainingAsReviewed(bool ar) =>
      ar ? 'تحديد الباقي كتمت المراجعة' : 'Mark remaining as reviewed';

  static String unreviewedCountLabel(bool ar, int count) =>
      ar ? 'لم يراجع: $count' : 'Unreviewed: $count';

  static String reviewedCountLabel(bool ar, int count) =>
      ar ? 'تمت المراجعة: $count' : 'Reviewed: $count';

  static String absentCountLabel(bool ar, int count) =>
      ar ? 'غائب: $count' : 'Absent: $count';

  static String totalWorkersLabel(bool ar, int count) =>
      ar ? 'إجمالي العمال: $count' : 'Total: $count';

  static String unreviewedWorkersWarning(bool ar, int count) => ar
      ? 'يوجد $count عامل لم تتم مراجعتهم. هل تريد تحديدهم كتمت المراجعة والمتابعة؟'
      : 'There are $count unreviewed workers. Mark them as reviewed and continue?';

  static String housingDraftSaved(bool ar) =>
      ar ? 'تم حفظ مسودة الكامبوس محلياً' : 'CAMPOS draft saved locally';

  static String filterAll(bool ar) => ar ? 'الكل' : 'All';

  static String filterUnreviewed(bool ar) => ar ? 'غير مراجع' : 'Unreviewed';

  static String filterPresent(bool ar) => ar ? 'موجود' : 'Present';

  static String filterAbsent(bool ar) => ar ? 'غائب' : 'Absent';
}
