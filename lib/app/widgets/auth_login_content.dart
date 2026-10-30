import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/login/login_flow_notifier.dart';
import 'package:radar_labor/app/widgets/auth_login_form.dart';
import 'package:radar_labor/app/widgets/auth_login_validator.dart';
import 'package:radar_labor/app/widgets/pin_login_form.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class AuthLoginContent extends StatelessWidget {
  const AuthLoginContent({
    required this.flowNotifier,
    required this.loading,
    required this.busy,
    required this.error,
    required this.arabic,
    required this.onSignIn,
    required this.onSwitchAccount,
    super.key,
  });

  final LoginFlowNotifier flowNotifier;
  final bool loading;
  final bool busy;
  final String? error;
  final bool arabic;
  final LoginSubmitCallback onSignIn;
  final VoidCallback onSwitchAccount;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(AppTokens.space32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<LoginFlowState>(
      stream: flowNotifier.stream,
      initialData: flowNotifier.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? flowNotifier.state;
        final remembered = state.rememberedAccount;
        if (state.isRememberedMode && remembered != null) {
          return PinLoginForm(
            account: remembered,
            onSignIn: (password) => onSignIn(
              remembered.role,
              remembered.id,
              password,
            ),
            onSwitchAccount: onSwitchAccount,
            busy: busy,
            errorMessage: error,
            arabic: arabic,
          );
        }
        return AuthLoginForm(
          flowState: state,
          onRoleSelected: flowNotifier.selectRole,
          onAccountChanged: flowNotifier.selectAccount,
          onSignIn: onSignIn,
          busy: busy,
          errorMessage: error,
          arabic: arabic,
        );
      },
    );
  }
}
