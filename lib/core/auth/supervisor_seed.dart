import 'package:radar_labor/core/auth/auth_role.dart';

final class SupervisorSeed {
  const SupervisorSeed({
    required this.employeeUid,
    required this.displayName,
    required this.role,
    this.teamName = '',
    this.campusName = '',
  });

  final String employeeUid;
  final String displayName;
  final AuthRole role;
  final String teamName;
  final String campusName;
}
