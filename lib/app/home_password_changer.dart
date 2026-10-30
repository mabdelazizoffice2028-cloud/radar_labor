import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/user_password_change_dialog.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

final class HomePasswordChanger {
  static Future<void> changePassword({
    required BuildContext context,
    required AppDatabase database,
    required LocalAccount account,
    required bool ar,
  }) async {
    final values = await showDialog<(String, String, String)>(
      context: context,
      builder: (_) => UserPasswordChangeDialog(arabic: ar),
    );
    if (values == null || !context.mounted) return;
    final invalidLen = values.$2.length < AuthConstants.minPasswordLength ||
        values.$2.length > AuthConstants.maxPasswordLength;
    if (invalidLen || values.$2 != values.$3) {
      _toast(context, AppStrings.passwordMismatch(ar));
      return;
    }
    try {
      final auth = LocalAuthRepository(LocalSettingsRepository(database));
      final verified = await auth.signIn(role: account.role, accountId: account.id, password: values.$1);
      if (verified == null) {
        if (context.mounted) _toast(context, AppStrings.passwordIncorrect(ar));
        return;
      }
      await auth.changePassword(verified, values.$2);
      if (context.mounted) _toast(context, AppStrings.passwordChanged(ar));
    } on AccountLockedException {
      if (context.mounted) _toast(context, AppStrings.accountLocked(ar));
    } on AccountDeactivatedException {
      if (context.mounted) _toast(context, AppStrings.accountDisabled(ar));
    } on Exception catch (e) {
      debugPrint('Password change failed: $e');
      if (context.mounted) _toast(context, AppStrings.passwordChangeFailed(ar));
    }
  }

  static void _toast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }
}
