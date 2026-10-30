abstract final class AppAuthStrings {
  static String homeTab(bool ar) => ar ? 'الرئيسية' : 'Home';
  static String workersTab(bool ar) => ar ? 'العمال' : 'Workers';
  static String teamsTab(bool ar) => ar ? 'الفرق' : 'Teams';
  static String housingTab(bool ar) => ar ? 'الكامبوس' : 'CAMPOS';
  static String checkInTab(bool ar) => ar ? 'التسجيل اليومي' : 'Daily check-in';
  static String manageUsers(bool ar) => ar ? 'إدارة المستخدمين' : 'Manage users';
  static String passwordMismatch(bool ar) => ar
      ? 'كلمتا المرور غير متطابقتين أو ليست بين 4 و 8 خانات'
      : 'Passwords do not match or are not 4 to 8 characters';
  static String couldNotStart(bool ar) =>
      ar ? 'تعذر بدء التطبيق' : 'Could not start application';
  static String retry(bool ar) => ar ? 'إعادة المحاولة' : 'Retry';
  static String login(bool ar) => ar ? 'تسجيل الدخول' : 'Sign in';
  static String selectAccount(bool ar) => ar ? 'اختر الحساب' : 'Select account';
  static String password(bool ar) => ar ? 'كلمة المرور' : 'Password';
  static String showPassword(bool ar) =>
      ar ? 'إظهار كلمة المرور' : 'Show password';
  static String hidePassword(bool ar) =>
      ar ? 'إخفاء كلمة المرور' : 'Hide password';
  static String initialSetup(bool ar) =>
      ar ? 'الإعداد الأولي للنظام' : 'Initial system setup';
  static String importRosterPrompt(bool ar) => ar
      ? 'استيراد كشف القوى العاملة (XLSX / CSV)'
      : 'Import workforce roster (XLSX / CSV)';
  static String selectFile(bool ar) => ar ? 'اختيار ملف' : 'Select file';
  static String completeSetup(bool ar) => ar
      ? 'إكمال الإعداد وتجهيز الحسابات'
      : 'Complete setup & prepare accounts';
  static String accountDisabled(bool ar) => ar
      ? 'هذا الحساب معطّل، راجع الإدارة'
      : 'This account is deactivated. Contact management.';
  static String accountLocked(bool ar) => ar
      ? 'الحساب مقفل مؤقتاً لكثرة المحاولات الخاطئة'
      : 'Account temporarily locked due to multiple failed attempts.';
}
