/// Localized strings for simplified attendance conflict resolution (Phase 6).
final class ConflictResolutionStrings {
  const ConflictResolutionStrings._();

  static String currentRecordTitle(bool ar) =>
      ar ? 'السجل الحالي (الذي يتم حفظه)' : 'Current Record (Being Saved)';

  static String conflictingRecordTitle(bool ar) =>
      ar ? 'السجل المتعارض' : 'Conflicting Record';

  static String resolveAsCorrectionTitle(bool ar) =>
      ar ? 'نعم، صحّح السجل السابق' : 'Yes, correct previous record';

  static String resolveAsCorrectionDesc(bool ar) => ar
      ? 'يحذف العامل من الفريق السابق ويسجله في هذا الفريق.'
      : 'Removes the worker from the other team and records them in this team.';

  static String resolveAsTransferTitle(bool ar) => ar
      ? 'عمل في الفريقين اليوم — نقل خلال اليوم'
      : 'Worked in both teams today — transfer';

  static String resolveAsTransferDesc(bool ar) => ar
      ? 'يحتفظ بكلا السجلين ويوثق حركة نقل خلال اليوم.'
      : 'Keeps both records and logs an intra-day transfer.';

  static String resolveSkipWorkerTitle(bool ar) =>
      ar ? 'لا، احتفظ بالسجل السابق فقط' : 'No, keep previous record only';

  static String resolveSkipWorkerDesc(bool ar) => ar
      ? 'يتجاهل إضافة العامل إلى هذا الفريق.'
      : 'Skips adding the worker to this team.';
}
