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
      ar ? 'المساكن المسندة' : 'Assigned housing';

  static String assignHousingRequired(bool ar) => ar
      ? 'اختر مسكنًا واحدًا على الأقل لمشرف السكن'
      : 'Assign at least one housing unit for housing supervisor';

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
    'housing_created' => ar ? 'إنشاء سكن' : 'Housing created',
    'housing_updated' => ar ? 'تعديل سكن' : 'Housing updated',
    'housing_deactivated' => ar ? 'تعطيل سكن' : 'Housing deactivated',
    'account_created' => ar ? 'إنشاء حساب' : 'Account created',
    'account_deactivated' => ar ? 'تعطيل حساب' : 'Account deactivated',
    'password_reset' => ar ? 'إعادة تعيين رقم سر' : 'Password reset',
    'scopes_updated' => ar ? 'تحديث النطاق' : 'Scopes updated',
    'roster_imported' => ar ? 'استيراد القوى' : 'Roster imported',
    'roster_wiped' => ar ? 'مسح القوى' : 'Roster wiped',
    'conflict_resolved' => ar ? 'حل تعارض' : 'Conflict resolved',
    _ => action,
  };
}
