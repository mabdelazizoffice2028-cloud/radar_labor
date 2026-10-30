abstract final class AdminUserStrings {
  static String userAccountsTitle(bool ar) => ar ? 'إدارة المستخدمين' : 'User accounts';
  static String addUser(bool ar) => ar ? 'إضافة مستخدم' : 'Add user';
  static String roleLabel(bool ar) => ar ? 'الدور' : 'Role';
  static String employeeLabel(bool ar) => ar ? 'الموظف' : 'Employee';
  static String displayNameLabel(bool ar) => ar ? 'الاسم المعروض' : 'Display name';
  static String assignedTeams(bool ar) => ar ? 'الفرق المسندة لمشرف الموقع' : 'Assigned teams for site supervisor';
  static String assignTeamRequired(bool ar) => ar ? 'يرجى اختيار فريق واحد على الأقل لمشرف الموقع' : 'Please assign at least one team for the site supervisor';
  static String assignedHousing(bool ar) => ar ? 'الكامبوس المسند' : 'Assigned CAMPOS';
  static String assignHousingRequired(bool ar) => ar ? 'اختر كامبوس واحداً على الأقل لمشرف الكامبوس' : 'Assign at least one CAMPOS for the CAMPOS supervisor';
  static String accountConflictError(bool ar) => ar ? 'هذا المستخدم موجود بالفعل لهذا الدور' : 'This user already has that role';
  static String accountCreateError(bool ar) => ar ? 'تعذر إنشاء الحساب' : 'Could not create account';
  static String resetPasswordAction(bool ar) => ar ? 'إعادة تعيين رقم السر' : 'Reset password';
  static String resetPasswordDone(bool ar, String defaultPin) => ar ? 'تمت إعادة تعيين رقم السر إلى الرقم المبدئي ($defaultPin)' : 'Password reset to temporary default ($defaultPin)';
  static String deactivateAccountAction(bool ar) => ar ? 'تعطيل الحساب' : 'Deactivate account';
  static String accountDeactivatedBadge(bool ar) => ar ? 'معطل' : 'Deactivated';
  static String importNamesAction(bool ar) => ar ? 'استيراد Excel' : 'Import Excel';
  static String importReviewTitle(bool ar) => ar ? 'معاينة الاستيراد' : 'Review import';
  static String importReviewBody(bool ar, int workers, [int? supervisors]) => ar
      ? 'سيتم استيراد وتحديث بيانات $workers عاملاً في قاعدة البيانات المحلية المشفرة. يمكنك تفعيل المشرفين لاحقاً من إدارة المستخدمين.'
      : '$workers workers will be imported/updated in the encrypted local database. You can activate supervisors from User Accounts.';
  static String importConfirm(bool ar) => ar ? 'استيراد' : 'Import';
  static String importDone(bool ar, int added, int updated, [int? accounts]) => ar
      ? 'تمت إضافة $added وتحديث $updated عاملاً بنجاح'
      : 'Added $added and updated $updated workers successfully';
  static String importFailed(bool ar) => ar ? 'تعذر استيراد الملف' : 'Could not import the file';
  static String noNamesHint(bool ar) => ar
      ? 'لا يوجد مشرفون مفعلون بعد. استخدم أزرار التفعيل السريع أعلاه أو أضف مستخدماً.'
      : 'No active supervisors yet. Use the quick activation buttons above or add a user.';
  static String editUser(bool ar) => ar ? 'تعديل' : 'Edit';
  static String deleteUser(bool ar) => ar ? 'حذف من قائمة الدخول' : 'Remove';
  static String deleteUserConfirm(bool ar, String name) => ar ? 'حذف "$name" من قائمة الدخول؟ يبقى السجل التاريخي محفوظاً.' : 'Remove "$name" from the sign-in list? History is kept.';
  static String lastManagerError(bool ar) => ar ? 'لا يمكن حذف آخر حساب مدير مشروع' : 'The last project manager account cannot be removed';
  static String accountUpdateError(bool ar) => ar ? 'تعذر حفظ التعديل' : 'Could not save changes';
  static String accountsLoadError(bool ar) => ar ? 'تعذر تحميل الحسابات' : 'Could not load accounts';
  static String nameRequired(bool ar) => ar ? 'الاسم مطلوب' : 'Name is required';
  static String selectSiteSupervisors(bool ar) => ar ? 'تحديد مشرفي الموقع' : 'Select Site Supervisors';
  static String selectCampusSupervisors(bool ar) => ar ? 'تحديد مشرف الكامبوس' : 'Select CAMPOS Supervisor';
  static String batchActivated(bool ar, int count) => ar ? 'تم تفعيل $count مشرفاً بنجاح' : '$count supervisors activated successfully';
  static String searchSupervisorHint(bool ar) => ar ? 'ابحث بالاسم أو رقم الإقامة...' : 'Search by name or ID...';
  static String confirmSelection(bool ar) => ar ? 'اعتماد' : 'Done';
  static String noWorkersFound(bool ar) => ar ? 'لا يوجد عمال مطابقون' : 'No matching workers';
}
