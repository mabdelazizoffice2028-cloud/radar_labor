import 'package:radar_labor/core/l10n/auth_flow_strings.dart';

enum AuthRole { projectManager, hr, housingSupervisor, siteSupervisor, viewer }

extension AuthRoleLabel on AuthRole {
  String label({required bool arabic}) => switch (this) {
    AuthRole.projectManager => AuthFlowStrings.projectManagerRole(arabic),
    AuthRole.hr => AuthFlowStrings.hrRole(arabic),
    AuthRole.housingSupervisor => AuthFlowStrings.housingSupervisorRole(arabic),
    AuthRole.siteSupervisor => AuthFlowStrings.siteSupervisorRole(arabic),
    AuthRole.viewer => AuthFlowStrings.viewerRole(arabic),
  };
}
