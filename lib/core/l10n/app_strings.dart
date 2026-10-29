/// Centralized bilingual UI strings for Radar Labor.
abstract final class AppStrings {
  static String appTitle(bool ar) => ar ? 'رادار ليبور' : 'Radar Labour';
  static String homeTab(bool ar) => ar ? 'الرئيسية' : 'Home';
  static String workersTab(bool ar) => ar ? 'العمال' : 'Workers';
  static String teamsTab(bool ar) => ar ? 'الفرق' : 'Teams';
  static String housingTab(bool ar) => ar ? 'السكن' : 'Campus';
  static String checkInTab(bool ar) => ar ? 'التسجيل اليومي' : 'Daily check-in';
  static String settingsTab(bool ar) => ar ? 'الإعدادات' : 'Settings';
  static String signOut(bool ar) => ar ? 'تسجيل الخروج' : 'Sign out';
  static String changePassword(bool ar) =>
      ar ? 'تغيير كلمة المرور' : 'Change password';
  static String manageUsers(bool ar) =>
      ar ? 'إدارة المستخدمين' : 'Manage users';
  static String language(bool ar) => ar ? 'اللغة' : 'Language';
  static String arabic(bool ar) => ar ? 'العربية' : 'Arabic';
  static String english(bool ar) => ar ? 'الإنجليزية' : 'English';
  static String currentPassword(bool ar) =>
      ar ? 'كلمة المرور الحالية' : 'Current password';
  static String newPassword(bool ar) =>
      ar ? 'الجديدة (8 أحرف على الأقل)' : 'New (at least 8 characters)';
  static String confirmPassword(bool ar) =>
      ar ? 'تأكيد كلمة المرور' : 'Confirm password';
  static String save(bool ar) => ar ? 'حفظ' : 'Save';
  static String cancel(bool ar) => ar ? 'إلغاء' : 'Cancel';
  static String passwordChanged(bool ar) =>
      ar ? 'تم تغيير كلمة المرور بنجاح' : 'Password changed successfully';
  static String passwordMismatch(bool ar) => ar
      ? 'كلمتا المرور غير متطابقتين أو أقل من 8 أحرف'
      : 'Passwords do not match or are under 8 characters';
  static String passwordIncorrect(bool ar) =>
      ar ? 'كلمة المرور الحالية غير صحيحة' : 'Current password is incorrect';
  static String passwordChangeFailed(bool ar) => ar
      ? 'تعذر تغيير كلمة المرور. حاول مرة أخرى.'
      : 'Could not change the password. Please try again.';
  static String settingsGeneral(bool ar) => ar ? 'عام' : 'General';
  static String settingsAccount(bool ar) => ar ? 'الحساب' : 'Account';
  static String settingsAdministration(bool ar) =>
      ar ? 'الإدارة' : 'Administration';
  static String settingsAboutDevice(bool ar) =>
      ar ? 'حول هذا الجهاز' : 'About this device';
  static String encryptedDatabase(bool ar) =>
      ar ? 'قاعدة بيانات مشفرة محلياً' : 'Encrypted local database';
  static String worksOffline(bool ar) =>
      ar ? 'يعمل دون إنترنت' : 'Works offline';

  // Workers & Entities
  static String addWorker(bool ar) => ar ? 'إضافة عامل' : 'Add worker';
  static String searchWorker(bool ar) =>
      ar ? 'بحث بالاسم أو الرقم' : 'Search name or code';
  static String noWorkersYet(bool ar) =>
      ar ? 'لا يوجد عمال بعد — اضغط إضافة' : 'No workers yet — tap Add';
  static String workerCode(bool ar) => ar ? 'رقم العامل' : 'Worker code';
  static String arabicName(bool ar) => ar ? 'الاسم بالعربية' : 'Arabic name';
  static String englishName(bool ar) =>
      ar ? 'الاسم بالإنجليزية' : 'English name';
  static String currentTeam(bool ar) => ar ? 'الفريق الحالي' : 'Current team';
  static String currentHousing(bool ar) =>
      ar ? 'السكن الحالي' : 'Current campus';
  static String noTeam(bool ar) => ar ? 'بدون فريق' : 'No team';
  static String noHousing(bool ar) => ar ? 'بدون سكن' : 'No campus';
  static String markOnSite(bool ar) => ar ? 'تسجيل بالموقع' : 'Mark on site';
  static String markAbsent(bool ar) => ar ? 'تسجيل غياب' : 'Mark absent';
  static String assignTeamHousingFirst(bool ar) => ar
      ? 'عيّن العامل إلى فريق وسكن أولاً'
      : 'Assign the worker to a team and campus first';
  static String workerCodeExists(bool ar) =>
      ar ? 'رقم العامل مستخدم بالفعل' : 'Worker code already exists';
  static String workerSaveFailed(bool ar) => ar
      ? 'تعذر حفظ العامل. حاول مرة أخرى.'
      : 'Could not save the worker. Please try again.';
  static String addTeam(bool ar) => ar ? 'إضافة فريق' : 'Add team';
  static String addHousing(bool ar) => ar ? 'إضافة سكن' : 'Add campus';
  static String add(bool ar) => ar ? 'إضافة' : 'Add';
  static String noDataYet(bool ar) =>
      ar ? 'لا توجد بيانات بعد — اضغط إضافة' : 'Nothing here yet — tap Add';

  // Auth & Startup
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
