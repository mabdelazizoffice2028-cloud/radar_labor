/// Localized strings for Part B admin roster control, account reset, and audit log (PRD §14.5, §23.4, §23.5).
final class AdminStrings {
  const AdminStrings._();

  static String userAccountsTitle(bool ar) =>
      ar ? 'إدارة المستخدمين' : 'User accounts';

  static String addUser(bool ar) => ar ? 'إضافة مستخدم' : 'Add user';

  static String roleLabel(bool ar) => ar ? 'الدور' : 'Role';

  static String employeeLabel(bool ar) => ar ? 'الموظف' : 'Employee';

  static String displayNameLabel(bool ar) =>
      ar ? 'الاسم المعروض' : 'Display name';

  static String assignedTeams(bool ar) => ar
      ? 'الفرق المسندة (اختياري لمشرف الموقع)'
      : 'Assigned teams (optional for site supervisor)';

  static String assignedHousing(bool ar) =>
      ar ? 'المساكن المسندة' : 'Assigned campus';

  static String assignHousingRequired(bool ar) => ar
      ? 'اختر مسكنًا واحدًا على الأقل لمشرف السكن'
      : 'Assign at least one campus for the campus supervisor';

  static String accountConflictError(bool ar) => ar
      ? 'هذا المستخدم موجود بالفعل لهذا الدور'
      : 'This user already has that role';

  static String accountCreateError(bool ar) =>
      ar ? 'تعذر إنشاء الحساب' : 'Could not create account';

  static String resetPasswordAction(bool ar) =>
      ar ? 'إعادة تعيين رقم السر' : 'Reset password';

  static String resetPasswordDone(bool ar, String defaultPin) => ar
      ? 'تمت إعادة تعيين رقم السر إلى الرقم المبدئي ($defaultPin)'
      : 'Password reset to temporary default ($defaultPin)';

  static String deactivateAccountAction(bool ar) =>
      ar ? 'تعطيل الحساب' : 'Deactivate account';

  static String accountDeactivatedBadge(bool ar) => ar ? 'معطل' : 'Deactivated';

  static String importNamesAction(bool ar) =>
      ar ? 'استيراد Excel' : 'Import Excel';

  static String importReviewTitle(bool ar) =>
      ar ? 'معاينة الاستيراد' : 'Review import';

  static String importReviewBody(bool ar, int workers, int supervisors) => ar
      ? 'سيتم استيراد $workers اسماً، منهم $supervisors مشرفاً سيُنشأ لهم حساب تلقائياً. أرقام الهويات لا تُحفظ.'
      : '$workers names will be imported; $supervisors supervisors will get an account automatically. Identity numbers are never saved.';

  static String importConfirm(bool ar) => ar ? 'استيراد' : 'Import';

  static String importDone(bool ar, int added, int updated, int accounts) => ar
      ? 'تمت إضافة $added وتحديث $updated، وإنشاء $accounts حساب مشرف'
      : 'Added $added, updated $updated, created $accounts supervisor accounts';

  static String importFailed(bool ar) =>
      ar ? 'تعذر استيراد الملف' : 'Could not import the file';

  static String noNamesHint(bool ar) => ar
      ? 'لا توجد أسماء بعد. استورد ملف Excel لإنشاء حسابات المشرفين تلقائياً.'
      : 'No names yet. Import an Excel file to create supervisor accounts automatically.';

  static String editUser(bool ar) => ar ? 'تعديل' : 'Edit';

  static String deleteUser(bool ar) => ar ? 'حذف من قائمة الدخول' : 'Remove';

  static String deleteUserConfirm(bool ar, String name) => ar
      ? 'حذف "$name" من قائمة الدخول؟ يبقى السجل التاريخي محفوظاً.'
      : 'Remove "$name" from the sign-in list? History is kept.';

  static String lastManagerError(bool ar) => ar
      ? 'لا يمكن حذف آخر حساب مدير مشروع'
      : 'The last project manager account cannot be removed';

  static String accountUpdateError(bool ar) =>
      ar ? 'تعذر حفظ التعديل' : 'Could not save changes';

  static String accountsLoadError(bool ar) =>
      ar ? 'تعذر تحميل الحسابات' : 'Could not load accounts';

  static String nameRequired(bool ar) =>
      ar ? 'الاسم مطلوب' : 'Name is required';

  static String wipeRosterTitle(bool ar) =>
      ar ? 'مسح القوى العاملة' : 'Wipe workforce roster';

  static String wipeRosterWarning(bool ar) => ar
      ? 'سيتم تعطيل جميع العمال وإلغاء إسناد الفرق وإنهاء جلسات المشرفين مع الاحتفاظ بالسجل التاريخي. يجب تصدير نسخة احتياطية وكتابة كلمة التأكيد.'
      : 'All workers will be archived, team assignments cleared, and supervisor sessions revoked while preserving history. Export a backup and type confirmation.';

  static String wipeRosterConfirmWord(bool ar) => ar ? 'مسح' : 'WIPE';

  static String wipeRosterExportButton(bool ar) =>
      ar ? 'تصدير نسخة احتياطية أولاً' : 'Export backup first';

  static String wipeRosterConfirmButton(bool ar) =>
      ar ? 'تأكيد مسح القوى' : 'Confirm roster wipe';

  static String archiveWorkerAction(bool ar) =>
      ar ? 'أرشفة العامل (تعطيل)' : 'Archive worker (deactivate)';

  static String auditLogTab(bool ar) => ar ? 'سجل التغييرات' : 'Audit Log';

  static String auditLogEmpty(bool ar) =>
      ar ? 'لا توجد تغييرات مسجلة بعد' : 'No audit changes recorded yet';

  static String auditActionLabel(bool ar, String action) => switch (action) {
    'worker_created' => ar ? 'إضافة عامل' : 'Worker added',
    'worker_updated' => ar ? 'تعديل عامل' : 'Worker updated',
    'worker_archived' => ar ? 'تعطيل عامل' : 'Worker archived',
    'worker_reactivated' => ar ? 'إعادة تفعيل عامل' : 'Worker reactivated',
    'team_created' => ar ? 'إنشاء فريق' : 'Team created',
    'team_updated' => ar ? 'تعديل فريق' : 'Team updated',
    'team_deactivated' => ar ? 'تعطيل فريق' : 'Team deactivated',
    'housing_created' => ar ? 'إنشاء سكن' : 'Campus created',
    'housing_updated' => ar ? 'تعديل سكن' : 'Campus updated',
    'housing_deactivated' => ar ? 'تعطيل سكن' : 'Campus deactivated',
    'account_created' => ar ? 'إنشاء حساب' : 'Account created',
    'account_deactivated' => ar ? 'تعطيل حساب' : 'Account deactivated',
    'password_reset' => ar ? 'إعادة تعيين رقم سر' : 'Password reset',
    'scopes_updated' => ar ? 'تحديث النطاق' : 'Scopes updated',
    'roster_imported' => ar ? 'استيراد القوى' : 'Roster imported',
    'roster_wiped' => ar ? 'مسح القوى' : 'Roster wiped',
    'conflict_resolved' => ar ? 'حل تعارض' : 'Conflict resolved',
    _ => action,
  };

  static String scopeHousingCount(bool ar, int count) =>
      '$count ${ar ? 'مساكن' : 'campus'}';

  static String scopeTeamsCount(bool ar, int count) =>
      '$count ${ar ? 'فرق' : 'teams'}';

  static String scopeFullApp(bool ar) => ar ? 'كامل التطبيق' : 'Full app';
}
