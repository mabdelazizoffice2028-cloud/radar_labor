import 'package:radar_labor/app/login/login_flow_state.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';

typedef LoginSubmitCallback = Future<void> Function(
  AuthRole role,
  String accountId,
  String password,
);

final class AuthLoginValidator {
  const AuthLoginValidator._();

  static String? validate({
    required LoginFlowState state,
    required String password,
    required bool arabic,
  }) {
    final role = state.selectedRole;
    if (role == null) return AuthFlowStrings.selectRoleFirstError(arabic);
    final accountId = resolveAccountId(state);
    if (accountId == null || accountId.isEmpty) {
      return AuthFlowStrings.selectNameFirstError(arabic);
    }
    if (password.isEmpty) return AuthFlowStrings.enterPasswordError(arabic);
    return null;
  }

  static String? resolveAccountId(LoginFlowState state) {
    final role = state.selectedRole;
    final isAdmin = role == AuthRole.projectManager || role == AuthRole.hr;
    return isAdmin
        ? (state.selectedAccountId ?? state.accountsForRole.firstOrNull?.id)
        : state.selectedAccountId;
  }
}
