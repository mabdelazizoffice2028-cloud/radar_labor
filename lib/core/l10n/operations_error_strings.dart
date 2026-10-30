abstract final class OperationsErrorStrings {
  static String errPermissionDenied(bool ar) => ar
      ? 'ليست لديك صلاحية لهذا الإجراء.'
      : "You don't have permission for this action.";
  static String errDateOutOfWindow(bool ar) => ar
      ? 'هذا التاريخ خارج المدة المسموح بها للتسجيل.'
      : 'This date is outside the allowed recording window.';
  static String errFutureDate(bool ar) =>
      ar ? 'لا يمكن التسجيل لتاريخ مستقبلي.' : 'Future dates are not allowed.';
  static String errWorkersUnavailable(bool ar) => ar
      ? 'بعض العمال لم يعودوا متاحين وأُزيلوا من تحديدك. راجع القائمة واحفظ من جديد.'
      : 'Some workers are no longer available and were removed from your selection. Review and save again.';
  static String errScopeChanged(bool ar) => ar
      ? 'هذا الفريق لم يعد مسندًا إليك. راجع الإدارة.'
      : 'This team is no longer assigned to you. Contact management.';
  static String errUnresolvedConflicts(bool ar) =>
      ar ? 'عالج كل التعارضات للمتابعة.' : 'Resolve all conflicts to continue.';
  static String errTeamNameInvalid(bool ar) =>
      ar ? 'أدخل اسم فريق صحيحًا.' : 'Enter a valid team name.';
  static String errTeamNameExists(bool ar) => ar
      ? 'يوجد فريق بهذا الاسم بالفعل.'
      : 'A team with this name already exists.';
  static String errSaveFailed(bool ar) => ar
      ? 'تعذر الحفظ. تحديدك محفوظ، حاول مرة أخرى.'
      : 'Could not save. Your selection is kept, please try again.';
  static String errDatabaseBusy(bool ar) => ar
      ? 'قاعدة البيانات مشغولة. انتظر لحظة وحاول مجددًا.'
      : 'The database is busy. Wait a moment and try again.';
  static String errSessionRevoked(bool ar) => ar
      ? 'أنهت الإدارة جلستك. سجّل الدخول من جديد.'
      : 'Your session was ended by management. Sign in again.';
  static String errActivationRequired(bool ar) => ar
      ? 'اتصل بالإنترنت مرة واحدة لتفعيل هذا الجهاز.'
      : 'Connect to the internet once to activate this device.';
  static String errSyncFailed(bool ar) => ar
      ? 'تم الحفظ على هذا الجهاز، لكن فشلت المزامنة مع السيرفر. بياناتك محفوظة وستبقى معلّقة.'
      : 'Saved on this device, but syncing with the server failed. Your data is safe and stays pending.';
  static String errRosterWipeNotConfirmed(bool ar) => ar
      ? 'أكّد المسح وصدّر نسخة احتياطية أولًا.'
      : 'Confirm the wipe and export a backup first.';
  static String errFridayAbsenceNotAllowed(bool ar) => ar
      ? 'يوم الجمعة عطلة رسمية (لا يوجد تسجيل غياب). يمكنك فقط الاطلاع على السجل السابق.'
      : 'Friday is an official rest day (no absence recording). You may only view previous history.';
}
