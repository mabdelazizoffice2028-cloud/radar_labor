import 'package:radar_labor/core/l10n/bidi.dart';

abstract final class OperationsCheckinStrings {
  static String recordingForDate(bool ar, String d) =>
      ar ? 'تسجيل حضور ليوم: $d' : 'Recording for: $d';
  static String pastDateWarning(bool ar) =>
      ar ? 'هذا تاريخ سابق' : 'This is a past date';
  static String changeDate(bool ar) => ar ? 'تغيير التاريخ' : 'Change date';
  static String draftRestored(bool ar) =>
      ar ? 'تم استعادة المسودة' : 'Draft restored';
  static String draftRestoredPartial(bool ar, int n) =>
      ar ? 'تم استعادة المسودة (تم تخطي $n)' : 'Draft restored ($n skipped)';
  static String suggestionFromDate(bool ar, String d) =>
      ar ? 'تم التحديد مسبقًا من يوم $d' : 'Pre-filled from $d';
  static String savedDayLoaded(bool ar) => ar
      ? 'يعرض التسجيل المحفوظ لهذا اليوم'
      : 'Showing the saved record for this day';
  static String addFromAnotherTeam(bool ar) =>
      ar ? 'إضافة عامل من فريق آخر' : 'Add from another team';
  static String fromTeamBadge(bool ar, String t) =>
      ar ? 'من فريق: $t' : 'From: $t';
  static String crossTeamSearchHint(bool ar) => ar
      ? 'ابحث بالاسم أو الكود (حرفان على الأقل)'
      : 'Search by name or code (2+ characters)';
  static String noSearchResults(bool ar) =>
      ar ? 'لا يوجد عمال مطابقون' : 'No matching workers';
  static String removeGuest(bool ar) => ar ? 'إزالة' : 'Remove';
  static String presentLabel(bool ar) => ar ? 'حاضر' : 'Present';
  static String notPresentLabel(bool ar) => ar ? 'غير حاضر' : 'Not present';
  static String noTeam(bool ar) => ar ? 'بدون فريق' : 'No team';
  static String zeroWorkersConfirmation(bool ar) => ar
      ? 'تنبيه: لم يتم تحديد أي عامل حاضر (0 حاضرين).'
      : 'Warning: 0 workers are marked present.';
  static String preSaveDiffTotal(bool ar, int t, int a, int r) {
    if (!ar) return 'Total: $t (Added: +$a, Removed: -$r)';
    return 'الإجمالي: $t (زيادة: ${Bidi.isolateLtr('+$a')}، نقص: ${Bidi.isolateLtr('-$r')})';
  }
  static String diffBaselineLastSave(bool ar) =>
      ar ? 'مقارنة بآخر تسجيل محفوظ' : 'Compared with the last saved record';
  static String diffBaselineDate(bool ar, String d) =>
      ar ? 'مقارنة بيوم $d' : 'Compared with $d';
  static String diffNoBaseline(bool ar) =>
      ar ? 'لا يوجد تسجيل سابق للمقارنة' : 'No previous record to compare';
  static String diffAddedTitle(bool ar) => ar ? 'المضافون' : 'Added';
  static String diffRemovedTitle(bool ar) => ar ? 'المحذوفون' : 'Removed';
  static String diffNoChanges(bool ar) => ar ? 'لا توجد تغييرات' : 'No changes';
  static String localConflictTitle(bool ar) =>
      ar ? 'تعارض في التسجيل' : 'Attendance Conflict';
  static String localConflictBody(bool ar, String w, String t) => ar
      ? 'العامل $w مسجل بالفعل مع فريق $t.'
      : 'Worker $w is already recorded with team $t.';
  static String localConflictRecordedAt(bool ar, String time) =>
      ar ? 'سُجّل الساعة $time' : 'Recorded at $time';
  static String resolveAsTransfer(bool ar) =>
      ar ? 'تسجيل كنقل خلال اليوم' : 'Record as transfer';
  static String resolveAsCorrection(bool ar) =>
      ar ? 'إلغاء حضوره من الفريق الآخر' : 'Remove from other team';
  static String resolveSkipWorker(bool ar) =>
      ar ? 'عدم إضافة هذا العامل' : "Don't add this worker";
}
