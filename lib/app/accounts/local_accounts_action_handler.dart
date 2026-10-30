import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/account_form_dialog.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/app/accounts/local_accounts_dialog_factory.dart';
import 'package:radar_labor/app/accounts/local_accounts_ops.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';

abstract final class LocalAccountsActionHandler {
  static Future<void> handleAction({
    required BuildContext context,
    required LocalAccount account,
    required String action,
    required AccountsAdminData data,
    required AccountsAdminController controller,
    required bool arabic,
    required Future<void> Function(Future<void> Function() action, String failure) run,
    required void Function(String) toast,
  }) async {
    if (action == 'edit') {
      final f = await AccountFormDialog.show(context, LocalAccountsDialogFactory.create(data: data, arabic: arabic, initial: account));
      if (f != null) await run(() => controller.update(account, f), AdminStrings.accountUpdateError(arabic));
    } else if (action == 'reset_pin') {
      await run(() async {
        await controller.resetPassword(account.id);
        toast(AdminStrings.resetPasswordDone(arabic, AuthConstants.temporaryPassword));
      }, AdminStrings.accountUpdateError(arabic));
    } else if (action == 'remove' && await LocalAccountsOps.confirmRemove(context, account, arabic) == true) {
      await run(() => controller.remove(account), AdminStrings.accountUpdateError(arabic));
    }
  }
}
