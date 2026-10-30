abstract final class LockoutStrings {
  static String housingLockout(bool ar) => ar ? 'ساعة قفل السكن' : 'Housing Lockout Hour';
  static String siteLockout(bool ar) => ar ? 'ساعة قفل الموقع' : 'Site Lockout Hour';
  static String hourFormat(int hour, bool ar) => ar ? '$hour:00 بتوقيت الرياض' : '$hour:00 Riyadh time';
}
