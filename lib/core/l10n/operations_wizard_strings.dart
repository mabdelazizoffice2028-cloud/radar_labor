abstract final class OperationsWizardStrings {
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
  static String teamsLoadFailed(bool ar) => ar
      ? 'تعذر تحميل فرقك. أغلق الشاشة وافتحها من جديد.'
      : 'Could not load your teams. Close this screen and open it again.';
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
      ar ? 'اسم الفريق (بالإنجليزية)' : 'Team name (English)';
  static String teamNameEnglishLabel(bool ar) =>
      ar ? 'اسم الفريق (بالإنجليزية)' : 'Team name (English)';
  static String searchWorkersHint(bool ar) =>
      ar ? 'ابحث بالاسم أو الكود' : 'Search by name or code';
  static String workerSelectedState(bool ar) => ar ? 'محدد' : 'Selected';
  static String workerUnselectedState(bool ar) =>
      ar ? 'غير محدد' : 'Not selected';
}
