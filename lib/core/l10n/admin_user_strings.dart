abstract final class AdminUserStrings {
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
      ar ? 'الكامبوس المسند' : 'Assigned CAMPOS';
  static String assignHousingRequired(bool ar) => ar
      ? 'اختر كامبوس واحداً على الأقل لمشرف الكامبوس'
      : 'Assign at least one CAMPOS for the CAMPOS supervisor';
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
}
