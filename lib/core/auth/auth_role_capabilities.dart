import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';

extension AuthRoleCapabilities on AuthRole {
  RoleCapabilities get capabilities => switch (this) {
    AuthRole.projectManager || AuthRole.hr => RoleCapabilities.admin,
    AuthRole.housingSupervisor => RoleCapabilities.housingSupervisor,
    AuthRole.siteSupervisor => RoleCapabilities.siteSupervisor,
    AuthRole.viewer => RoleCapabilities.viewer,
  };
}
