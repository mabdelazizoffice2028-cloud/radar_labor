import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/user_password_change_dialog.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';

final class HomePasswordChanger {
  static Future<void> changePassword({
    required BuildContext context,
    required AppDatabase database,
    required LocalAccount account,
    required bool ar,
  }) async {
    final values = await showDialog<(String, String, String)>(
      context: context, builder: (_) => UserPasswordChangeDialog(arabic: ar),
    );
    if (values == null || !context.mounted) return;
    final invalidLen = values.$2.length < AuthConstants.minPasswordLength ||
        values.$2.length > AuthConstants.maxPasswordLength;
    if (invalidLen || values.$2 != values.$3) {
      await FieldHaptics.error();
      if (context.mounted) AppSnackBar.showWarning(context, message: AppStrings.passwordMismatch(ar));
      return;
    }
    try {
      final auth = LocalAuthRepository(LocalSettingsRepository(database));
      final verified = await auth.signIn(role: account.role, accountId: account.id, password: values.$1);
      if (verified == null) {
        await FieldHaptics.error();
        if (context.mounted) AppSnackBar.showError(context, message: AppStrings.passwordIncorrect(ar));
        return;
      }
      await auth.changePassword(verified, values.$2);
      await FieldHaptics.success();
      if (context.mounted) AppSnackBar.showSuccess(context, message: AppStrings.passwordChanged(ar));
    } on AccountLockedException {
      await FieldHaptics.error();
      if (context.mounted) AppSnackBar.showError(context, message: AppStrings.accountLocked(ar));
    } on AccountDeactivatedException {
      await FieldHaptics.error();
      if (context.mounted) AppSnackBar.showError(context, message: AppStrings.accountDisabled(ar));
    } on Exception catch (e) {
      await FieldHaptics.error();
      debugPrint('Password change failed: $e');
      if (context.mounted) AppSnackBar.showError(context, message: AppStrings.passwordChangeFailed(ar));
    }
  }
}
