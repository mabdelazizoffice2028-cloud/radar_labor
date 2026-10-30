import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

final class LocalAccountsOps {
  static Future<bool?> confirmRemove(BuildContext context, LocalAccount account, bool arabic) =>
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(AdminStrings.deleteUserConfirm(arabic, account.displayName)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel(arabic))),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AdminStrings.deleteUser(arabic))),
          ],
        ),
      );

  static Future<void> importRoster({
    required BuildContext context,
    required AccountsAdminController controller,
    required bool arabic,
    required void Function(String) toast,
  }) async {
    final preview = await controller.pickImport();
    if (preview == null || !context.mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AdminStrings.importReviewTitle(arabic)),
        content: Text(AdminStrings.importReviewBody(arabic, preview.rows.length, preview.supervisorCount)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel(arabic))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AdminStrings.importConfirm(arabic))),
        ],
      ),
    );
    if (accepted != true) return;
    final r = await controller.commitImport(preview);
    if (context.mounted) {
      toast(AdminStrings.importDone(arabic, r.added, r.updated, r.accountsCreated));
    }
  }
}
