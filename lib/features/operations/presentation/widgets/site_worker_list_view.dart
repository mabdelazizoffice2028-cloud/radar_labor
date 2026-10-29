import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_row_tile.dart';

/// Worker list view for site attendance screen.
class SiteWorkerListView extends StatelessWidget {
  const SiteWorkerListView({
    required this.state,
    required this.selected,
    required this.arabic,
    required this.onToggle,
    required this.onRemoveGuest,
    super.key,
  });

  final SiteAttendanceState state;
  final EntityOption? selected;
  final bool arabic;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onRemoveGuest;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (selected == null) {
      return Center(child: Text(OperationsStrings.addTeamToStart(arabic)));
    }
    if (state.rows.isEmpty) {
      return Center(child: Text(OperationsStrings.noWorkersInTeam(arabic)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space8,
      ),
      itemCount: state.filteredRows.length,
      itemBuilder: (context, index) {
        final row = state.filteredRows[index];
        return AttendanceRowTile(
          row: row,
          arabic: arabic,
          searchQuery: state.searchQuery,
          onToggle: () => onToggle(row.worker.id),
          onRemoveGuest: row.isGuest
              ? () => onRemoveGuest(row.worker.id)
              : null,
        );
      },
    );
  }
}
