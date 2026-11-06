abstract final class ShiftSettingsStrings {
  static String shiftStartLabel(bool ar) =>
      ar ? 'بداية وردية العمل' : 'Shift Start Time';

  static String shiftEndLabel(bool ar) =>
      ar ? 'نهاية وردية العمل' : 'Shift End Time';

  static String timeFormat(int totalMinutes, bool ar) {
    final h = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final m = (totalMinutes % 60).toString().padLeft(2, '0');
    return ar ? '$h:$m بتوقيت الرياض' : '$h:$m Riyadh time';
  }
}
