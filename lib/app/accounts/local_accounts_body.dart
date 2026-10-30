import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/app/accounts/local_accounts_list.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/database/app_database.dart';

final class LocalAccountsBody extends StatelessWidget {
  const LocalAccountsBody({
    required this.data,
    required this.arabic,
    required this.busy,
    required this.error,
    required this.onAction,
    required this.onBatchActivate,
    super.key,
  });

  final AccountsAdminData? data;
  final bool arabic;
  final bool busy;
  final String? error;
  final void Function(LocalAccount, String) onAction;
  final Future<void> Function(List<Employee>, AuthRole) onBatchActivate;

  @override
  Widget build(BuildContext context) {
    final d = data;
    if (d == null) {
      return Center(
        child: error == null
            ? const CircularProgressIndicator()
            : Text(error!),
      );
    }
    return LocalAccountsList(
      data: d,
      arabic: arabic,
      busy: busy,
      error: error,
      onAction: onAction,
      onBatchActivate: onBatchActivate,
    );
  }
}
