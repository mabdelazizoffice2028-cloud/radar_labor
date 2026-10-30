import 'package:radar_labor/core/l10n/bidi.dart';

/// Localized strings for Notification Center and sync coverage widgets.
abstract final class NotificationsStrings {
  static String centerTitle(bool ar) =>
      ar ? 'مركز التنبيهات' : 'Notification Center';
  static String centerLabel(bool ar) => ar ? 'التنبيهات' : 'Notifications';
  static String allComplete(bool ar) => ar
      ? 'جميع سجلات الحضور والسكن مكتملة لليوم!'
      : 'All attendance and housing records complete today!';
  static String localModeTitle(bool ar) => ar ? 'الوضع المحلي' : 'Local Mode';
  static String localModeSub(bool ar) => ar
      ? 'التطبيق يعمل دون اتصال بالسيرفر'
      : 'Working offline without server';
  static String pendingUploadsTitle(bool ar) =>
      ar ? 'حركات بانتظار الرفع' : 'Pending Uploads';
  static String pendingUploadsSub(bool ar, int count) => ar
      ? 'يوجد ${Bidi.isolateLtr(count.toString())} حركات مسجلة بانتظار المزامنة'
      : '$count pending updates waiting to sync';
  static String fullySyncedTitle(bool ar) =>
      ar ? 'تمت المزامنة' : 'Fully Synced';
  static String fullySyncedSub(bool ar) =>
      ar ? 'جميع البيانات مرفوعة ومطابقة للسيرفر' : 'All data synced with server';
  static String unrecordedTeams(bool ar, int count) => ar
      ? 'فرق لم يتم قيدها اليوم (${Bidi.isolateLtr(count.toString())})'
      : 'Unrecorded Teams Today ($count)';
  static String unrecordedHousings(bool ar, int count) => ar
      ? 'مساكن لم يتم قيدها اليوم (${Bidi.isolateLtr(count.toString())})'
      : 'Unrecorded Housing Today ($count)';
  static String supervisorPrefix(bool ar) => ar ? 'المشرف: ' : 'Supervisor: ';
  static String missingBadge(bool ar) => ar ? 'لم يسجل' : 'Missing';
}
