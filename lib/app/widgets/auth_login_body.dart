import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/login/login_flow_state.dart';
import 'package:radar_labor/app/widgets/auth_login_validator.dart';
import 'package:radar_labor/app/widgets/auth_role_fields.dart';
import 'package:radar_labor/app/widgets/login_form_layout.dart';
import 'package:radar_labor/core/auth/auth_role.dart';

final class AuthLoginBody extends StatefulWidget {
  const AuthLoginBody({
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
  State<AuthLoginBody> createState() => _AuthLoginBodyState();
}

final class _AuthLoginBodyState extends State<AuthLoginBody> {
  final _password = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _onRole(AuthRole r) {
    _password.clear();
    setState(() => _localError = null);
    widget.onRoleSelected(r);
  }

  void _handleSubmit() {
    setState(() => _localError = null);
    final err = AuthLoginValidator.validate(
      state: widget.flowState,
      password: _password.text,
      arabic: widget.arabic,
    );
    if (err != null) return setState(() => _localError = err);
    final id = AuthLoginValidator.resolveAccountId(widget.flowState)!;
    widget.onSignIn(widget.flowState.selectedRole!, id, _password.text);
  }

  @override
  Widget build(BuildContext context) => LoginFormLayout(
        arabic: widget.arabic,
        banner: _localError ?? widget.errorMessage,
        child: AuthRoleFields(
          state: widget.flowState,
          arabic: widget.arabic,
          busy: widget.busy,
          passwordController: _password,
          onRoleSelected: _onRole,
          onAccountChanged: widget.onAccountChanged,
          onSubmit: _handleSubmit,
        ),
      );
}
