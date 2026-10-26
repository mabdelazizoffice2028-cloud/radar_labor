import 'package:radar_labor/core/l10n/bidi.dart';

/// Localized strings for team wizard, smart check-in, diffs, conflicts, and errors (PRD §13, §14).
abstract final class OperationsStrings {
  // §14.1 Team Wizard & Team Edit
  static String setupTeamWizardTitle(bool ar) =>
      ar ? 'معالج إعداد الفريق' : 'Team Setup Wizard';

  static String createNewTeam(bool ar) =>
      ar ? 'إنشاء فريق جديد' : 'Create New Team';

  static String wizardStepOf(bool ar, int c, int t) =>
      ar ? 'الخطوة $c من $t' : 'Step $c of $t';

  static String wizardNext(bool ar) => ar ? 'التالي' : 'Next';

  static String wizardBack(bool ar) => ar ? 'رجوع' : 'Back';

  static String confirmAndSave(bool ar) => ar ? 'تأكيد وحفظ' : 'Confirm & Save';

  static String confirmWorkersTitle(bool ar) =>
      ar ? 'راجع أعضاء الفريق' : 'Review the team members';

  static String confirmCreateEmptyTeam(bool ar) => ar
      ? 'لم تختر أي عامل. هل تريد إنشاء فريق فارغ؟'
      : 'No workers selected. Create an empty team?';

  static String teamCreated(bool ar) => ar ? 'تم إنشاء الفريق' : 'Team created';

  static String editTeam(bool ar) => ar ? 'تعديل الفريق' : 'Edit team';

  static String teamMembersSaved(bool ar) =>
      ar ? 'تم تحديث أعضاء الفريق' : 'Team members updated';

  static String noTeamsYetSupervisor(bool ar) => ar
      ? 'ليس لديك فريق بعد. أنشئ فريقًا لتبدأ التسجيل.'
      : 'You have no team yet. Create one to start recording.';

  static String workersSelected(bool ar, int n) {
    if (!ar) {
      if (n <= 0) return 'No workers selected';
      if (n == 1) return '1 worker selected';
      return '$n workers selected';
    }
    if (n <= 0) return 'لم يتم اختيار أي عامل';
    if (n == 1) return 'تم اختيار عامل واحد';
    if (n == 2) return 'تم اختيار عاملين';
    if (n >= 3 && n <= 10) return 'تم اختيار $n عمال';
    return 'تم اختيار $n عاملًا';
  }

  static String selectAll(bool ar) => ar ? 'تحديد الكل' : 'Select All';

  static String clearAll(bool ar) => ar ? 'إلغاء التحديد' : 'Clear All';

  static String workerAssignedElsewhere(bool ar, String t) =>
      ar ? 'ضمن فريق: $t' : 'In team: $t';

  static String inactiveBadge(bool ar) => ar ? 'معطّل' : 'Inactive';

  static String teamNameArabicLabel(bool ar) =>
      ar ? 'اسم الفريق بالعربية' : 'Team name (Arabic)';

  static String teamNameEnglishLabel(bool ar) =>
      ar ? 'اسم الفريق بالإنجليزية (اختياري)' : 'Team name (English, optional)';

  static String searchWorkersHint(bool ar) =>
      ar ? 'ابحث بالاسم أو الكود' : 'Search by name or code';

  static String workerSelectedState(bool ar) => ar ? 'محدد' : 'Selected';

  static String workerUnselectedState(bool ar) =>
      ar ? 'غير محدد' : 'Not selected';

  // §14.2 Daily Check-in
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

  // §14.3 Pre-Save Diff & Local Conflict
  static String preSaveDiffTotal(bool ar, int t, int a, int r) {
    if (!ar) return 'Total: $t (Added: +$a, Removed: -$r)';
    final added = Bidi.isolateLtr('+$a');
    final removed = Bidi.isolateLtr('-$r');
    return 'الإجمالي: $t (زيادة: $added، نقص: $removed)';
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

  // Housing & Site screen common strings
  static String selectTeam(bool ar) => ar ? 'اختر الفريق' : 'Select team';

  static String selectHousing(bool ar) => ar ? 'اختر السكن' : 'Select housing';

  static String addTeamToStart(bool ar) =>
      ar ? 'أضف فريقًا ثم ابدأ التسجيل' : 'Add a team to start';

  static String addHousingToStart(bool ar) =>
      ar ? 'أضف سكنًا ثم ابدأ الفحص' : 'Add housing to start a check';

  static String noWorkersInTeam(bool ar) => ar
      ? 'لا يوجد عمال مسندون لهذا الفريق'
      : 'No workers assigned to this team';

  static String noWorkersInHousing(bool ar) => ar
      ? 'لا يوجد عمال مسندون لهذا السكن'
      : 'No workers assigned to this housing';

  static String codeLabel(bool ar) => ar ? 'الكود' : 'Code';

  static String presentCountLabel(bool ar, int count) =>
      ar ? 'الحاضرون: $count' : 'Present: $count';

  static String markedAbsentCount(bool ar, int count) =>
      ar ? 'الغياب المحدد: $count' : 'Marked absent: $count';

  static String savingLabel(bool ar) => ar ? 'جارٍ الحفظ…' : 'Saving…';

  static String confirmTeamSubmission(bool ar) =>
      ar ? 'تأكيد وإرسال تسجيل الفريق' : 'Confirm team submission';

  static String noAbsencesSaveCheck(bool ar) =>
      ar ? 'لا يوجد غائبون — حفظ الفحص' : 'No absences — save check';

  static String confirmAbsencesAndSave(bool ar) =>
      ar ? 'تأكيد الغياب والحفظ' : 'Confirm absences and save';

  static String confirmSiteAttendanceTitle(bool ar) =>
      ar ? 'تأكيد تسجيل الموقع' : 'Confirm site attendance';

  static String confirmHousingCheckTitle(bool ar) =>
      ar ? 'تأكيد فحص السكن' : 'Confirm housing check';

  static String reviewAction(bool ar) => ar ? 'مراجعة' : 'Review';

  static String confirmAction(bool ar) => ar ? 'تأكيد' : 'Confirm';

  static String teamSavedLocally(bool ar) =>
      ar ? 'تم حفظ تسجيل الفريق محليًا' : 'Team submission saved locally';

  static String housingSavedLocally(bool ar) =>
      ar ? 'تم حفظ الفحص محليًا' : 'Check saved locally';

  static String undoAction(bool ar) => ar ? 'تراجع' : 'Undo';

  static String whatsappSummaryTitle(bool ar) =>
      ar ? 'ملخص واتساب' : 'WhatsApp summary';

  static String copyTextAction(bool ar) => ar ? 'نسخ النص' : 'Copy text';

  static String closeAction(bool ar) => ar ? 'إغلاق' : 'Close';

  static String housingCheckTab(bool ar) => ar ? 'فحص السكن' : 'Housing check';

  static String siteAttendanceTab(bool ar) =>
      ar ? 'تسجيل الموقع' : 'Site attendance';

  // §13 Error Catalog
  static String errPermissionDenied(bool ar) => ar
      ? 'ليست لديك صلاحية لهذا الإجراء.'
      : "You don't have permission for this action.";

  static String errDateOutOfWindow(bool ar) => ar
      ? 'هذا التاريخ خارج المدة المسموح بها للتسجيل.'
      : 'This date is outside the allowed recording window.';

  static String errFutureDate(bool ar) =>
      ar ? 'لا يمكن التسجيل لتاريخ مستقبلي.' : 'Future dates are not allowed.';

  static String errWorkersUnavailable(bool ar) => ar
      ? 'بعض العمال لم يعودوا متاحين وأُزيلوا من تحديدك. راجع القائمة واحفظ من جديد.'
      : 'Some workers are no longer available and were removed from your selection. Review and save again.';

  static String errScopeChanged(bool ar) => ar
      ? 'هذا الفريق لم يعد مسندًا إليك. راجع الإدارة.'
      : 'This team is no longer assigned to you. Contact management.';

  static String errUnresolvedConflicts(bool ar) =>
      ar ? 'عالج كل التعارضات للمتابعة.' : 'Resolve all conflicts to continue.';

  static String errTeamNameInvalid(bool ar) =>
      ar ? 'أدخل اسم فريق صحيحًا.' : 'Enter a valid team name.';

  static String errTeamNameExists(bool ar) => ar
      ? 'يوجد فريق بهذا الاسم بالفعل.'
      : 'A team with this name already exists.';

  static String errSaveFailed(bool ar) => ar
      ? 'تعذر الحفظ. تحديدك محفوظ، حاول مرة أخرى.'
      : 'Could not save. Your selection is kept, please try again.';

  static String errDatabaseBusy(bool ar) => ar
      ? 'قاعدة البيانات مشغولة. انتظر لحظة وحاول مجددًا.'
      : 'The database is busy. Wait a moment and try again.';

  static String errSessionRevoked(bool ar) => ar
      ? 'أنهت الإدارة جلستك. سجّل الدخول من جديد.'
      : 'Your session was ended by management. Sign in again.';

  static String errActivationRequired(bool ar) => ar
      ? 'اتصل بالإنترنت مرة واحدة لتفعيل هذا الجهاز.'
      : 'Connect to the internet once to activate this device.';

  static String errRosterWipeNotConfirmed(bool ar) => ar
      ? 'أكّد المسح وصدّر نسخة احتياطية أولًا.'
      : 'Confirm the wipe and export a backup first.';
}
