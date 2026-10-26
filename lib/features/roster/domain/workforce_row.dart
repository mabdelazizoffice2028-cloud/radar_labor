final class WorkforceRow {
  const WorkforceRow({
    required this.code,
    required this.name,
    required this.designation,
    required this.supplier,
    this.role = '',
    this.team = '',
    this.campus = '',
  });

  final String code;
  final String name;
  final String designation;
  final String supplier;

  /// Optional app role cell (e.g. "Site Supervisor", "Campus Supervisor").
  final String role;

  /// Optional team name linked to a site supervisor.
  final String team;

  /// Optional campus (housing) name linked to a campus supervisor.
  final String campus;
}
