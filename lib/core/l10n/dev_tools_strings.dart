/// Localized strings for Preferences dev tools, clearing data, and importing rosters.
abstract final class DevToolsStrings {
  static String confirmClearTitle(bool ar) =>
      ar ? 'تأكيد مسح البيانات' : 'Confirm Data Clear';
  static String confirmClearBody(bool ar) => ar
      ? 'هل أنت متأكد من مسح جميع أحداث الحضور والتسجيل التجريبية؟ لن يتم حذف العمال أو الفرق، فقط الحركات.'
      : 'Are you sure you want to clear all test attendance and registration events? Workers and teams will not be deleted, only ledger entries.';
  static String cancel(bool ar) => ar ? 'إلغاء' : 'Cancel';
  static String clearData(bool ar) => ar ? 'مسح البيانات' : 'Clear Data';
  static String clearSuccess(bool ar) =>
      ar ? 'تم مسح بيانات التجارب بنجاح' : 'Test data cleared successfully';
  static String clearFailed(bool ar) =>
      ar ? 'فشل مسح البيانات' : 'Failed to clear test data';
  static String clearTitle(bool ar) =>
      ar ? 'مسح بيانات التجارب' : 'Clear Test Data';
  static String clearSubtitle(bool ar) => ar
      ? 'تصفير الحركات اليومية وإعادة ضبط اللوحة'
      : 'Reset daily entries and dashboard';
  static String importCardTitle(bool ar) => ar
      ? 'استيراد كشف العمال (Excel / CSV)'
      : 'Import workforce roster (Excel / CSV)';
  static String importCardSubtitle(bool ar) => ar
      ? 'تحديث بيانات العمال وتعيين المشرفين'
      : 'Update worker roster & supervisor assignments';
  static String importFailed(bool ar) =>
      ar ? 'تعذر استيراد الملف' : 'Could not import the file';
}
