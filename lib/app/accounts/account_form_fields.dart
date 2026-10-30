import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/account_form_dialog.dart';
import 'package:radar_labor/app/accounts/account_team_scope_tile.dart';
import 'package:radar_labor/app/accounts/account_worker_search_field.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class AccountFormFields extends StatelessWidget {
  const AccountFormFields({
    required this.arabic,
    required this.isAdding,
    required this.employees,
    required this.nameController,
    required this.selectedRole,
    required this.teams,
    required this.selectedTeams,
    required this.onSelectEmployee,
    required this.onRoleChanged,
    required this.onToggleTeam,
    this.errorMessage,
    super.key,
  });

  final bool arabic, isAdding;
  final List<ScopeOption> employees;
  final TextEditingController nameController;
  final AuthRole selectedRole;
  final List<ScopeOption> teams;
  final Set<String> selectedTeams;
  final void Function(String uid, String name) onSelectEmployee;
  final ValueChanged<AuthRole> onRoleChanged;
  final void Function(String teamId, bool selected) onToggleTeam;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 420,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAdding && selectedRole != AuthRole.viewer)
            AccountWorkerSearchField(
              arabic: arabic,
              employees: employees,
              onSelectEmployee: onSelectEmployee,
            ),
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: AdminStrings.displayNameLabel(arabic)),
          ),
          DropdownButtonFormField<AuthRole>(
            isExpanded: true,
            initialValue: selectedRole,
            decoration: InputDecoration(labelText: AdminStrings.roleLabel(arabic)),
            items: [
              for (final r in AuthRole.values)
                DropdownMenuItem(value: r, child: Text(r.label(arabic: arabic))),
            ],
            onChanged: (r) => {if (r != null) onRoleChanged(r)},
          ),
          if (selectedRole == AuthRole.siteSupervisor)
            AccountTeamScopeTile(
              arabic: arabic,
              teams: teams,
              selectedTeams: selectedTeams,
              onToggleTeam: onToggleTeam,
            ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(errorMessage!, style: const TextStyle(color: AppTokens.statusUnknown)),
            ),
        ],
      ),
    ),
  );
}
