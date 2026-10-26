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

  static String noAccountsForRole(bool ar) => ar
      ? 'لا يوجد حساب نشط لهذا الدور بعد. راجع الإدارة.'
      : 'No active account exists for this role yet. Contact administration.';

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

  static String newPasswordTitle(bool ar) =>
      ar ? 'إنشاء رقم سر جديد' : 'Create a new password';
}
