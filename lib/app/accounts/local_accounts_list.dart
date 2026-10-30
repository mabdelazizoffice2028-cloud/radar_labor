import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/app/accounts/local_account_card.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class LocalAccountsList extends StatelessWidget {
  const LocalAccountsList({
    required this.data,
    required this.arabic,
    required this.busy,
    required this.error,
    required this.onAction,
    super.key,
  });

  final AccountsAdminData data;
  final bool arabic;
  final bool busy;
  final String? error;
  final void Function(LocalAccount a, String action) onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppTokens.space16, AppTokens.space16, AppTokens.space16, 100),
      children: [
        if (busy) const LinearProgressIndicator(),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.space8),
            child: Text(error!, style: const TextStyle(color: AppTokens.statusUnknown)),
          ),
        if (!data.hasSupervisors)
          Card(
            color: AppTokens.primarySoft,
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.space12),
              child: Text(AdminStrings.noNamesHint(arabic)),
            ),
          ),
        for (final a in data.accounts)
          LocalAccountCard(account: a, arabic: arabic, busy: busy, onAction: onAction),
      ],
    );
  }
}
