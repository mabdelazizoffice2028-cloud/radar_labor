/// Small domain values shared by daily-operation screens and repositories.
final class EntityOption {
  const EntityOption({required this.id, required this.nameAr, this.nameEn});

  final String id;
  final String nameAr;
  final String? nameEn;

  String displayName({required bool arabic}) =>
      (nameEn != null && nameEn!.trim().isNotEmpty) ? nameEn! : nameAr;
}

final class WorkerOption {
  const WorkerOption({
    required this.id,
    required this.code,
    required this.nameAr,
    this.nameEn,
    this.employmentType = 'company',
    this.jobCategory = 'direct_labor',
  });

  final String id;
  final String code;
  final String nameAr;
  final String? nameEn;
  final String employmentType;
  final String jobCategory;

  String displayName({required bool arabic}) =>
      (nameEn != null && nameEn!.trim().isNotEmpty) ? nameEn! : nameAr;
}

final class HousingCheckUndo {
  const HousingCheckUndo({
    required this.date,
    required this.housingId,
    required this.previousAbsences,
    required this.currentAbsences,
    required this.wasChecked,
  });

  final String date;
  final String housingId;
  final Set<String> previousAbsences;
  final Set<String> currentAbsences;
  final bool wasChecked;
}

final class SiteAttendanceUndo {
  const SiteAttendanceUndo({
    required this.date,
    required this.teamId,
    required this.previousPresent,
    required this.currentPresent,
    required this.wasSubmitted,
  });

  final String date;
  final String teamId;
  final Set<String> previousPresent;
  final Set<String> currentPresent;
  final bool wasSubmitted;
}
