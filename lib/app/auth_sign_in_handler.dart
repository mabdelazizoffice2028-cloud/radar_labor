import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/auth_gate_service.dart';
import 'package:radar_labor/app/widgets/change_temporary_password_dialog.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';

final class AuthSignInHandler {
  const AuthSignInHandler._();

  static Future<(LocalAccount?, String?)> handleSignIn({
    required BuildContext context,
    required AuthGateService service,
    required AuthRole role,
    required String id,
    required String password,
    required bool isArabic,
  }) async {
    try {
      var acc = await service.auth.signIn(role: role, accountId: id, password: password);
      if (acc == null) return (null, AuthFlowStrings.invalidCredentialsOrLocked(isArabic));
      if (acc.mustChangePassword) {
        if (!context.mounted) return (null, null);
        final next = await ChangeTemporaryPasswordDialog.show(context, arabic: isArabic);
        if (next == null) return (null, null);
        await service.auth.changePassword(acc, next);
        acc = await service.refreshAccount(acc.id);
      }
      await service.rememberAccount(acc.id);
      return (acc, null);
    } on AccountLockedException {
      return (null, AppStrings.accountLocked(isArabic));
    } on AccountDeactivatedException {
      return (null, AppStrings.accountDisabled(isArabic));
    } on Object catch (e) {
      debugPrint('Auth sign-in unexpected error (${e.runtimeType}).');
      return (null, AuthFlowStrings.signInFailed(isArabic));
    }
  }
}
