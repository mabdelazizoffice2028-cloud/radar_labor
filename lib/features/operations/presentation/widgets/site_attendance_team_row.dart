import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_attendance_more_menu.dart';

class SiteAttendanceTeamRow extends StatelessWidget {
  const SiteAttendanceTeamRow({
    required this.teams, required this.selected, required this.arabic,
    required this.canEditTeam, required this.onTeamChanged, required this.onEditTeam,
    required this.onClearAll, required this.onAddGuest, this.onCreateTeam, super.key,
  });

  final List<EntityOption> teams;
  final EntityOption? selected;
  final bool arabic;
  final bool canEditTeam;
  final ValueChanged<String?> onTeamChanged;
  final VoidCallback? onEditTeam;
  final VoidCallback? onCreateTeam;
  final VoidCallback onClearAll;
  final VoidCallback onAddGuest;

  void _onMenuAction(SiteAttendanceMenuAction action) => switch (action) {
    SiteAttendanceMenuAction.clearAll => onClearAll(),
    SiteAttendanceMenuAction.addFromAnotherTeam => onAddGuest(),
    SiteAttendanceMenuAction.editTeam => onEditTeam?.call(),
    SiteAttendanceMenuAction.createNewTeam => onCreateTeam?.call(),
  };

  @override
  Widget build(BuildContext context) {
    final singleTeam = teams.length == 1 ? (selected ?? teams.first) : null;
    return Row(
      children: [
        Expanded(
          child: singleTeam != null
              ? Text(singleTeam.displayName(arabic: arabic), style: Theme.of(context).textTheme.titleLarge)
              : DropdownButtonFormField<String>(
                  initialValue: selected?.id,
                  decoration: InputDecoration(
                    labelText: OperationsStrings.selectTeam(arabic),
                    border: const OutlineInputBorder(),
                  ),
                  items: teams.map((row) => DropdownMenuItem(
                    value: row.id, child: Text(row.displayName(arabic: arabic)),
                  )).toList(),
                  onChanged: onTeamChanged,
                ),
        ),
        SiteAttendanceMoreMenu(arabic: arabic, canEditTeam: canEditTeam, onSelected: _onMenuAction),
      ],
    );
  }
}
