import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/time/friday_resolver.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_date_bar.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_attendance_action_row.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_attendance_team_row.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_friday_banner.dart';

/// Top controls for team selection, date picker, bulk actions, and guest search.
class SiteAttendanceHeader extends StatelessWidget {
  const SiteAttendanceHeader({
    required this.teams, required this.selected, required this.state,
    required this.arabic, required this.canEditTeam, required this.onTeamChanged,
    required this.onDateSelected, required this.onSelectAll,
    required this.onSelectDefaultCrew, required this.onAddGuest,
    this.onEditTeam, super.key,
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
  final VoidCallback onSelectDefaultCrew;
  final VoidCallback onAddGuest;

  @override
  Widget build(BuildContext context) {
    final isFriday = FridayResolver.isFriday(state.selectedDate);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space16, AppTokens.space12, AppTokens.space16, AppTokens.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SiteAttendanceTeamRow(
            teams: teams, selected: selected, arabic: arabic,
            canEditTeam: canEditTeam && onEditTeam != null,
            onTeamChanged: onTeamChanged, onEditTeam: onEditTeam,
            onClearAll: () => onSelectAll(false), onAddGuest: onAddGuest,
          ),
          const SizedBox(height: AppTokens.space8),
          AttendanceDateBar(
            selectedDate: state.selectedDate, todayDate: state.todayDate,
            isPastDate: state.isPastDate, initialSource: state.initialSource,
            initialSourceDate: state.initialSourceDate,
            skippedDraftCount: state.skippedDraftCount,
            arabic: arabic, onDateSelected: onDateSelected,
          ),
          if (isFriday) ...[
            const SizedBox(height: AppTokens.space8),
            SiteFridayBanner(arabic: arabic),
          ],
          const SizedBox(height: AppTokens.space8),
          SiteAttendanceActionRow(
            arabic: arabic,
            onSelectAll: onSelectAll,
            onSelectDefaultCrew: onSelectDefaultCrew,
          ),
        ],
      ),
    );
  }
}
