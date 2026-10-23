/// Localized labels used by the pure attendance-message formatter.
final class AttendanceMessageStrings {
  const AttendanceMessageStrings({
    required this.absenceCount,
    required this.noAbsences,
    required this.confirmNoAbsences,
    required this.presenceCount,
    required this.noPresence,
    required this.confirmNoPresence,
  });

  factory AttendanceMessageStrings.fromLanguage({required bool arabic}) =>
      arabic
      ? const AttendanceMessageStrings.arabic()
      : const AttendanceMessageStrings.english();

  const AttendanceMessageStrings.arabic()
    : absenceCount = 'عدد الغائبين',
      noAbsences = 'لا يوجد غائبون',
      confirmNoAbsences = 'تأكيد عدم وجود غائبين؟',
      presenceCount = 'عدد الحاضرين',
      noPresence = 'لا يوجد حاضرين',
      confirmNoPresence = 'لم تحدد عمالًا. هل تسجل الفريق بصفر حضور؟';

  const AttendanceMessageStrings.english()
    : absenceCount = 'Absent workers',
      noAbsences = 'No absences',
      confirmNoAbsences = 'Confirm that nobody is absent?',
      presenceCount = 'Present workers',
      noPresence = 'No workers present',
      confirmNoPresence = 'No workers selected. Submit zero present?';

  final String absenceCount;
  final String noAbsences;
  final String confirmNoAbsences;
  final String presenceCount;
  final String noPresence;
  final String confirmNoPresence;
}
