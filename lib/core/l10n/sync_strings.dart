/// Localized strings for Part B automatic offline-first sync & session status (PRD §14.5, §23.6).
final class SyncStrings {
  const SyncStrings._();

  static String syncedStatus(bool ar) => ar ? 'تمت المزامنة' : 'Synced';

  static String localMode(bool ar) => ar ? 'محلي' : 'Local Mode';

  static String pendingUploadStatus(bool ar, int count) {
    if (ar) {
      return 'بانتظار الرفع ($count)';
    }
    return count == 1 ? 'Pending upload (1)' : 'Pending upload ($count)';
  }

  static String syncingStatus(bool ar) =>
      ar ? 'جارٍ المزامنة...' : 'Syncing...';

  static String offlineReadyStatus(bool ar) =>
      ar ? 'محلي (جاهز للعمل بلا اتصال)' : 'Local (offline-ready)';

  static String sessionRevokedMessage(bool ar) =>
      ar ? 'أنهت الإدارة جلستك.' : 'Administration has ended your session.';

  static String activationRequiredMessage(bool ar) => ar
      ? 'يلزم الاتصال مرة واحدة لتفعيل الجهاز وتنزيل بيانات القوى.'
      : 'A one-time connection is required to activate this device and download roster data.';
}
