import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/account_form_dialog.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/app/accounts/local_accounts_dialog_factory.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';

final class LocalAccountsFab extends StatelessWidget {
  const LocalAccountsFab({
    required this.data,
    required this.busy,
    required this.arabic,
    required this.controller,
    required this.onRun,
    super.key,
  });

  final AccountsAdminData? data;
  final bool busy;
  final bool arabic;
  final AccountsAdminController controller;
  final Future<void> Function(Future<void> Function(), String) onRun;

  @override
  Widget build(BuildContext context) {
    final d = data;
    final disabled = busy || (d?.employees.isEmpty ?? true);
    return FloatingActionButton.extended(
      onPressed: disabled
          ? null
          : () async {
              final f = await AccountFormDialog.show(
                context,
                LocalAccountsDialogFactory.create(data: d!, arabic: arabic),
              );
              if (f != null) {
                await onRun(
                  () => controller.create(f),
                  AdminStrings.accountCreateError(arabic),
                );
              }
            },
      icon: const Icon(Icons.person_add_alt_1),
      label: Text(AdminStrings.addUser(arabic)),
    );
  }
}
