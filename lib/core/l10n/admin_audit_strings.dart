abstract final class AdminAuditStrings {
  static String wipeRosterTitle(bool ar) => ar ? 'مسح القوى العاملة' : 'Wipe workforce roster';
  static String wipeRosterWarning(bool ar) => ar
      ? 'سيتم تعطيل جميع العمال وإلغاء إسناد الفرق وإنهاء جلسات المشرفين مع الاحتفاظ بالسجل التاريخي. يجب تصدير نسخة احتياطية وكتابة كلمة التأكيد.'
      : 'All workers will be archived, team assignments cleared, and supervisor sessions revoked while preserving history. Export a backup and type confirmation.';
  static String wipeRosterConfirmWord(bool ar) => ar ? 'مسح' : 'WIPE';
  static String wipeRosterExportButton(bool ar) => ar ? 'تصدير نسخة احتياطية أولاً' : 'Export backup first';
  static String wipeRosterConfirmButton(bool ar) => ar ? 'تأكيد مسح القوى' : 'Confirm roster wipe';
  static String archiveWorkerAction(bool ar) => ar ? 'أرشفة العامل (تعطيل)' : 'Archive worker (deactivate)';
  static String auditLogTab(bool ar) => ar ? 'سجل التغييرات' : 'Audit Log';
  static String auditLogEmpty(bool ar) => ar ? 'لا توجد تغييرات مسجلة بعد' : 'No audit changes recorded yet';
  static String auditActionLabel(bool ar, String action) => switch (action) {
    'worker_created' => ar ? 'إضافة عامل' : 'Worker added',
    'worker_updated' => ar ? 'تعديل عامل' : 'Worker updated',
    'worker_archived' => ar ? 'تعطيل عامل' : 'Worker archived',
    'worker_reactivated' => ar ? 'إعادة تفعيل عامل' : 'Worker reactivated',
    'team_created' => ar ? 'إنشاء فريق' : 'Team created',
    'team_updated' => ar ? 'تعديل فريق' : 'Team updated',
    'team_deactivated' => ar ? 'تعطيل فريق' : 'Team deactivated',
    'housing_created' => ar ? 'إنشاء كامبوس' : 'CAMPOS created',
    'housing_updated' => ar ? 'تعديل كامبوس' : 'CAMPOS updated',
    'housing_deactivated' => ar ? 'تعطيل كامبوس' : 'CAMPOS deactivated',
    'account_created' => ar ? 'إنشاء حساب' : 'Account created',
    'account_deactivated' => ar ? 'تعطيل حساب' : 'Account deactivated',
    'password_reset' => ar ? 'إعادة تعيين رقم سر' : 'Password reset',
    'scopes_updated' => ar ? 'تحديث النطاق' : 'Scopes updated',
    'roster_imported' => ar ? 'استيراد القوى' : 'Roster imported',
    'roster_wiped' => ar ? 'مسح القوى' : 'Roster wiped',
    'conflict_resolved' => ar ? 'حل تعارض' : 'Conflict resolved',
    _ => action,
  };
  static String scopeHousingCount(bool ar, int count) => '$count ${ar ? 'كامبوس' : 'CAMPOS'}';
  static String scopeTeamsCount(bool ar, int count) => '$count ${ar ? 'فرق' : 'teams'}';
  static String scopeFullApp(bool ar) => ar ? 'كامل التطبيق' : 'Full app';
}
