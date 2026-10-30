import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/account_form_dialog.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';

final class AccountTeamScopeTile extends StatelessWidget {
  const AccountTeamScopeTile({
    required this.arabic,
    required this.teams,
    required this.selectedTeams,
    required this.onToggleTeam,
    super.key,
  });

  final bool arabic;
  final List<ScopeOption> teams;
  final Set<String> selectedTeams;
  final void Function(String teamId, bool selected) onToggleTeam;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text(AdminStrings.assignedTeams(arabic)),
    initiallyExpanded: true,
    children: [
      for (final t in teams)
        CheckboxListTile(
          value: selectedTeams.contains(t.$1),
          title: Text(t.$2),
          onChanged: (checked) => onToggleTeam(t.$1, checked == true),
        ),
    ],
  );
}
