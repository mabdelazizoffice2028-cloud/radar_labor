enum CoverageKind { housing, team }

final class CoverageWarning {
  const CoverageWarning({
    required this.kind,
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.supervisorNames = const <String>[],
  });

  final CoverageKind kind;
  final String id;
  final String nameAr;
  final String? nameEn;
  final List<String> supervisorNames;
}

final class DashboardCoverage {
  const DashboardCoverage({
    required this.businessDate,
    required this.missingHousings,
    required this.missingTeams,
  });

  final String businessDate;
  final List<CoverageWarning> missingHousings;
  final List<CoverageWarning> missingTeams;
}
