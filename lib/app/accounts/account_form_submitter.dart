import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/constants/app_constants.dart';

final class AccountFormSubmitter {
  const AccountFormSubmitter._();

  static AccountFormResult buildResult({
    required bool isAdding,
    required String? employeeUid,
    required String? initialEmployeeUid,
    required String displayName,
    required AuthRole role,
    required Set<String> teams,
  }) {
    final effectiveHousings = role == AuthRole.housingSupervisor
        ? const [HousingConstants.defaultHousingId]
        : const <String>[];
    return AccountFormResult(
      employeeUid: isAdding ? employeeUid : initialEmployeeUid,
      displayName: displayName.trim(),
      role: role,
      teamIds: role == AuthRole.siteSupervisor ? teams.toList() : const [],
      housingIds: effectiveHousings,
    );
  }
}
