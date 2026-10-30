import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/login/login_flow_state.dart';
import 'package:radar_labor/app/login/role_picker.dart';
import 'package:radar_labor/app/widgets/login_account_picker.dart';
import 'package:radar_labor/app/widgets/login_error_banner.dart';
import 'package:radar_labor/app/widgets/login_password_row.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class AuthRoleFields extends StatelessWidget {
  const AuthRoleFields({
    required this.state, required this.arabic, required this.busy,
    required this.passwordController, required this.onRoleSelected,
    required this.onAccountChanged, required this.onSubmit, super.key,
  });

  final LoginFlowState state; final bool arabic, busy;
  final TextEditingController passwordController;
  final ValueChanged<AuthRole> onRoleSelected;
  final ValueChanged<String?> onAccountChanged; final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final role = state.selectedRole;
    final picker = RolePicker(arabic: arabic, selectedRole: role, onRoleSelected: onRoleSelected);
    if (role == null) return picker;
    final pass = LoginPasswordRow(controller: passwordController, busy: busy, arabic: arabic, onSubmit: onSubmit);
    if (role == AuthRole.projectManager || role == AuthRole.hr) {
      return Column(children: [picker, const SizedBox(height: AppTokens.space12), pass]);
    }
    if (state.accountsForRole.isEmpty) {
      return Column(children: [picker, const SizedBox(height: AppTokens.space12), LoginErrorBanner(message: AuthFlowStrings.noNamesYet(arabic))]);
    }
    return Column(
      children: [
        picker,
        const SizedBox(height: AppTokens.space12),
        LoginAccountPicker(state: state, arabic: arabic, busy: busy, onAccountChanged: onAccountChanged),
        const SizedBox(height: AppTokens.space12),
        pass,
      ],
    );
  }
}
