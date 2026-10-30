import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/app/accounts/local_accounts_ops.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';

final class LocalAccountsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const LocalAccountsAppBar({
    required this.arabic,
    required this.busy,
    required this.controller,
    required this.onReload,
    required this.toast,
    super.key,
  });

  final bool arabic;
  final bool busy;
  final AccountsAdminController controller;
  final Future<void> Function() onReload;
  final void Function(String) toast;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(AdminStrings.userAccountsTitle(arabic)),
    actions: [
      TextButton.icon(
        onPressed: busy
            ? null
            : () => LocalAccountsOps.importRoster(
                context: context,
                controller: controller,
                arabic: arabic,
                toast: toast,
              ).then((_) => onReload()),
        icon: const Icon(Icons.upload_file),
        label: Text(AdminStrings.importNamesAction(arabic)),
      ),
    ],
  );
}
