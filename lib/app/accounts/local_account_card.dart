import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class LocalAccountCard extends StatelessWidget {
  const LocalAccountCard({
    required this.account, required this.arabic, required this.busy, required this.onAction, super.key,
  });

  final LocalAccount account;
  final bool arabic;
  final bool busy;
  final void Function(LocalAccount, String) onAction;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.account_circle_outlined, color: AppTokens.primary),
      title: Text(account.displayName),
      subtitle: Text('${account.role.label(arabic: arabic)} · ${_scope(account)}'),
      trailing: PopupMenuButton<String>(
        key: ValueKey('account_menu_${account.id}'),
        enabled: !busy,
        onSelected: (action) => onAction(account, action),
        itemBuilder: (context) => [
          PopupMenuItem(value: 'edit', child: Text(AdminStrings.editUser(arabic))),
          PopupMenuItem(value: 'reset_pin', child: Text(AdminStrings.resetPasswordAction(arabic))),
          PopupMenuItem(value: 'remove', child: Text(AdminStrings.deleteUser(arabic))),
        ],
      ),
    ),
  );

  String _scope(LocalAccount a) => switch (a.role) {
    AuthRole.housingSupervisor => AdminStrings.scopeHousingCount(arabic, a.housingIds.length),
    AuthRole.siteSupervisor => AdminStrings.scopeTeamsCount(arabic, a.teamIds.length),
    _ => AdminStrings.scopeFullApp(arabic),
  };
}
