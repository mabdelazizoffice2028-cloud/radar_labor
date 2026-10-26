import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_date_bar.dart';

/// Top controls for team selection, date picker, bulk actions, and guest search.
class SiteAttendanceHeader extends StatelessWidget {
  const SiteAttendanceHeader({
    required this.teams,
    required this.selected,
    required this.state,
    required this.arabic,
    required this.canEditTeam,
    required this.canCreateTeam,
    required this.onTeamChanged,
    required this.onDateSelected,
    required this.onCreateTeam,
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
  final bool canCreateTeam;
  final ValueChanged<String?> onTeamChanged;
  final ValueChanged<String> onDateSelected;
  final VoidCallback? onEditTeam;
  final VoidCallback onCreateTeam;
  final ValueChanged<bool> onSelectAll;
  final VoidCallback onAddGuest;

  @override
  Widget build(BuildContext context) {
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
                child: DropdownButtonFormField<String>(
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
              if (canEditTeam && onEditTeam != null) ...[
                const SizedBox(width: AppTokens.space4),
                IconButton(
                  tooltip: OperationsStrings.editTeam(arabic),
                  onPressed: onEditTeam,
                  icon: const Icon(Icons.group_add_outlined),
                ),
              ],
              if (canCreateTeam) ...[
                const SizedBox(width: AppTokens.space4),
                IconButton(
                  tooltip: OperationsStrings.createNewTeam(arabic),
                  onPressed: onCreateTeam,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
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
          Wrap(
            spacing: AppTokens.space8,
            runSpacing: AppTokens.space4,
            children: [
              OutlinedButton.icon(
                onPressed: () => onSelectAll(true),
                icon: const Icon(Icons.done_all, size: 18),
                label: Text(OperationsStrings.selectAll(arabic)),
              ),
              OutlinedButton.icon(
                onPressed: () => onSelectAll(false),
                icon: const Icon(Icons.deselect, size: 18),
                label: Text(OperationsStrings.clearAll(arabic)),
              ),
              OutlinedButton.icon(
                onPressed: onAddGuest,
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: Text(OperationsStrings.addFromAnotherTeam(arabic)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
