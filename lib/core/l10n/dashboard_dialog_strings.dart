abstract final class DashboardDialogStrings {
  static String resolveConflictTitle(bool ar) =>
      ar ? 'تسوية التعارض' : 'Resolve conflict';
  static String optionalNote(bool ar) =>
      ar ? 'ملاحظة اختيارية' : 'Optional note';
  static String saveResolution(bool ar) =>
      ar ? 'حفظ التسوية' : 'Save resolution';
  static String justifyAbsenceTitle(bool ar) =>
      ar ? 'تبرير الغياب' : 'Justify absence';
  static String reasonSick(bool ar) => ar ? 'مرض' : 'Sick leave';
  static String reasonPersonalPermission(bool ar) =>
      ar ? 'إذن شخصي' : 'Personal permission';
  static String reasonOfficialErrand(bool ar) =>
      ar ? 'مأمورية' : 'Official errand';
  static String reasonOther(bool ar) => ar ? 'سبب آخر' : 'Other';
  static String quickReasonOptional(bool ar) =>
      ar ? 'سبب سريع (اختياري)' : 'Quick reason (optional)';
  static String noteOptional(bool ar) =>
      ar ? 'ملاحظة (اختيارية)' : 'Note (optional)';
  static String saveJustification(bool ar) =>
      ar ? 'حفظ التبرير' : 'Save justification';
  static String resolutionConfirmPresentLeftEarly(bool ar) =>
      ar ? 'اعتماد الحضور، خرج مبكرًا' : 'Confirm present, left early';
  static String resolutionMovedDuringDay(bool ar) =>
      ar ? 'انتقل خلال اليوم' : 'Moved during the day';
  static String resolutionHousingError(bool ar) =>
      ar ? 'خطأ من الكامبوس' : 'CAMPOS error';
  static String resolutionSiteError(bool ar) =>
      ar ? 'خطأ من الموقع' : 'Site error';
  static String resolutionOfficialErrand(bool ar) =>
      ar ? 'مأمورية أو إذن' : 'Official errand or permission';
  static String listSeparator(bool ar) => ar ? '، ' : ', ';
}
