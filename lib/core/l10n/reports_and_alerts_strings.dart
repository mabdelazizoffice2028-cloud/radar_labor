import 'package:radar_labor/core/l10n/bidi.dart';

/// Localized strings for Daily Reports and Iqama Expiry Alerts.
abstract final class ReportsAndAlertsStrings {
  static String generateDailyReport(bool ar) =>
      ar ? 'توليد تقرير اليوم' : 'Generate Daily Report';
  static String availableAfterHour(bool ar, int hour) => ar
      ? 'متاح بعد $hour:00 بتوقيت الرياض'
      : 'Available after $hour:00 Riyadh time';
  static String dailyReportDialogTitle(bool ar) =>
      ar ? 'تقرير العمليات اليومي' : 'Daily Operations Report';
  static String iqamaAlertTitle(bool ar) =>
      ar ? 'تنبيه إقامات العمال' : 'Workforce Iqama Alert';
  static String iqamaAlertSubtitle(bool ar, int totalCount, int expiredCount) =>
      ar
      ? 'يوجد ${Bidi.isolateLtr(totalCount.toString())} عامل شارفت إقاماتهم على الانتهاء ($expiredCount منتهية)'
      : '$totalCount workers with upcoming expiry ($expiredCount expired)';
  static String iqamaSheetTitle(bool ar, int count) => ar
      ? 'الإقامات المنتهية (${Bidi.isolateLtr(count.toString())})'
      : 'Iqama Expiry Alerts ($count)';
  static String iqamaExpiredDays(bool ar, int days, String iqama) =>
      ar ? 'منتهية منذ $days يوم ($iqama)' : 'Expired $days days ago ($iqama)';
  static String iqamaRemainingDays(bool ar, int days, String iqama) =>
      ar ? 'متبقي $days يوم ($iqama)' : '$days days remaining ($iqama)';
  static String dashboardTab(bool ar) => ar ? 'لوحة المتابعة' : 'Dashboard';
  static String usersTab(bool ar) => ar ? 'المستخدمين' : 'Users';
  static String teamNameEnLabel(bool ar) =>
      ar ? 'اسم الفريق (بالإنجليزية)' : 'Team name (English)';
  static String fridayOvertimeLabel(bool ar) =>
      ar ? 'إضافي الجمعة' : 'Friday Overtime';
}
