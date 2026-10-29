import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/login/login_flow_state.dart';
import 'package:radar_labor/app/widgets/auth_login_body.dart';
import 'package:radar_labor/app/widgets/auth_login_validator.dart';
import 'package:radar_labor/core/auth/auth_role.dart';

final class AuthLoginForm extends StatelessWidget {
  const AuthLoginForm({
    required this.flowState,
    required this.onRoleSelected,
    this.onClearRole,
    required this.onAccountChanged,
    required this.onSignIn,
    required this.busy,
    required this.errorMessage,
    required this.arabic,
    super.key,
  });

  final LoginFlowState flowState;
  final ValueChanged<AuthRole> onRoleSelected;
  final VoidCallback? onClearRole;
  final ValueChanged<String?> onAccountChanged;
  final LoginSubmitCallback onSignIn;
  final bool busy;
  final String? errorMessage;
  final bool arabic;

  @override
  Widget build(BuildContext context) => AuthLoginBody(
        flowState: flowState,
        onRoleSelected: onRoleSelected,
        onClearRole: onClearRole,
        onAccountChanged: onAccountChanged,
        onSignIn: onSignIn,
        busy: busy,
        errorMessage: errorMessage,
        arabic: arabic,
      );
}
