/// Localized strings for the Part B role-first login flow (PRD §14.5, §23.2).
final class AuthFlowStrings {
  const AuthFlowStrings._();

  static String chooseRoleTitle(bool ar) =>
      ar ? 'اختر الدور للدخول' : 'Select your role to sign in';

  static String changeRole(bool ar) => ar ? 'تغيير الدور' : 'Change role';

  static String chooseNameLabel(bool ar) =>
      ar ? 'اختر الاسم' : 'Select your name';

  static String singleAccountNotice(bool ar, String name) =>
      ar ? 'الحساب: $name' : 'Account: $name';

  static String noNamesYet(bool ar) => ar
      ? 'لا توجد أسماء بعد، اطلب من الإداري استيراد القائمة'
      : 'No names yet. Ask the administrator to import the list.';

  static String enterPasswordLabel(bool ar) => ar ? 'رقم السر' : 'Password';

  static String selectRoleFirstError(bool ar) =>
      ar ? 'يرجى اختيار الدور أولاً' : 'Please select a role first';

  static String selectNameFirstError(bool ar) =>
      ar ? 'يرجى اختيار الاسم أولاً' : 'Please select your name first';

  static String enterPasswordError(bool ar) =>
      ar ? 'يرجى إدخال رقم السر' : 'Please enter your password';

  static String invalidCredentialsOrLocked(bool ar) => ar
      ? 'رقم السر غير صحيح أو الحساب مقفل مؤقتاً'
      : 'Incorrect password or account temporarily locked';

  static String signInFailed(bool ar) => ar
      ? 'تعذر تسجيل الدخول، أعد المحاولة'
      : 'Could not sign in. Please retry.';

  static String loadFailed(bool ar) => ar
      ? 'تعذر تحميل بيانات الدخول، أعد المحاولة'
      : 'Could not load sign-in data. Please retry.';

  static String newPasswordTitle(bool ar) =>
      ar ? 'إنشاء رقم سر جديد' : 'Create a new password';

  static String switchAccount(bool ar) =>
      ar ? 'تبديل الحساب' : 'Switch account';

  static String welcomeBack(bool ar) => ar ? 'مرحباً بعودتك' : 'Welcome back';

  static String passwordMinLength(bool ar) => ar
      ? 'كلمة المرور يجب ألا تقل عن 8 أحرف'
      : 'Must be at least 8 characters';

  static String passwordCannotBe123456(bool ar) =>
      ar ? 'لا يمكن استخدام 123456' : 'Cannot use 123456';

  static String passwordsDoNotMatch(bool ar) =>
      ar ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match';

  static String changeTemporaryPasswordTitle(bool ar) =>
      ar ? 'تغيير كلمة المرور المؤقتة' : 'Change temporary password';

  static String changeTemporaryPasswordDescription(bool ar) => ar
      ? 'يجب تعيين كلمة مرور جديدة لا تقل عن 8 أحرف ولا تساوي 123456.'
      : 'You must set a new password of at least 8 characters and not 123456.';

  static String initialSetupDescription(bool ar) => ar
      ? 'ابدأ باستيراد ملف القوى العاملة (XLSX / CSV). لن يُحفظ رقم الهوية الوطنية.'
      : 'Start by importing the workforce file. National ID numbers are never saved.';

  static String chooseRosterFile(bool ar) =>
      ar ? 'اختيار ملف Excel أو CSV' : 'Choose Excel or CSV file';

  static String projectManagerRole(bool ar) =>
      ar ? 'مدير المشروع' : 'Project manager';

  static String hrRole(bool ar) => ar ? 'الموارد البشرية' : 'HR';

  static String housingSupervisorRole(bool ar) => ar ? 'السكن' : 'Campus';

  static String siteSupervisorRole(bool ar) =>
      ar ? 'مشرف الموقع' : 'Site supervisor';

  static String viewerRole(bool ar) => ar ? 'مشاهد فقط' : 'View only';

  static String createAdminAccountsAction(bool ar) =>
      ar ? 'إنشاء حسابي الإدارة' : 'Create Admin Accounts';
}
