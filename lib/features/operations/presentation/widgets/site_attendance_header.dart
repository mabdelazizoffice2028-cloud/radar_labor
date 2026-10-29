import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_date_bar.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_attendance_more_menu.dart';

/// Top controls for team selection, date picker, bulk actions, and guest search.
class SiteAttendanceHeader extends StatelessWidget {
  const SiteAttendanceHeader({
    required this.teams,
    required this.selected,
    required this.state,
    required this.arabic,
    required this.canEditTeam,
    required this.onTeamChanged,
    required this.onDateSelected,
    required this.onSelectAll,
    required this.onAddGuest,
    this.onEditTeam,
    super.key,
  });

  final List<EntityOption> teams;
  final EntityOption? selected;
  final SiteAttendanceState state;
  final bool arabic;
  final bool canEditTeam;
  final ValueChanged<String?> onTeamChanged;
  final ValueChanged<String> onDateSelected;
  final VoidCallback? onEditTeam;
  final ValueChanged<bool> onSelectAll;
  final VoidCallback onAddGuest;

  void _onMenuAction(SiteAttendanceMenuAction action) => switch (action) {
    SiteAttendanceMenuAction.clearAll => onSelectAll(false),
    SiteAttendanceMenuAction.addFromAnotherTeam => onAddGuest(),
    SiteAttendanceMenuAction.editTeam => onEditTeam?.call(),
  };

  @override
  Widget build(BuildContext context) {
    final singleTeam = teams.length == 1 ? (selected ?? teams.first) : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space16,
        AppTokens.space12,
        AppTokens.space16,
        AppTokens.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: singleTeam != null
                    ? Text(
                        singleTeam.displayName(arabic: arabic),
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: selected?.id,
                        decoration: InputDecoration(
                          labelText: OperationsStrings.selectTeam(arabic),
                          border: const OutlineInputBorder(),
                        ),
                        items: teams
                            .map(
                              (row) => DropdownMenuItem(
                                value: row.id,
                                child: Text(row.displayName(arabic: arabic)),
                              ),
                            )
                            .toList(),
                        onChanged: onTeamChanged,
                      ),
              ),
              SiteAttendanceMoreMenu(
                arabic: arabic,
                canEditTeam: canEditTeam && onEditTeam != null,
                onSelected: _onMenuAction,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space8),
          AttendanceDateBar(
            selectedDate: state.selectedDate,
            todayDate: state.todayDate,
            isPastDate: state.isPastDate,
            initialSource: state.initialSource,
            initialSourceDate: state.initialSourceDate,
            skippedDraftCount: state.skippedDraftCount,
            arabic: arabic,
            onDateSelected: onDateSelected,
          ),
          const SizedBox(height: AppTokens.space8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: () => onSelectAll(true),
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(OperationsStrings.selectAll(arabic)),
            ),
          ),
        ],
      ),
    );
  }
}
