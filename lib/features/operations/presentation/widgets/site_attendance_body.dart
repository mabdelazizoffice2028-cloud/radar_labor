import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/time/friday_resolver.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_counter_bar.dart';
import 'package:radar_labor/features/operations/presentation/widgets/cross_team_search_sheet.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_attendance_header.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_worker_list_view.dart';

final class SiteAttendanceBody extends StatelessWidget {
  const SiteAttendanceBody({
    required this.teams, required this.selected, required this.state, required this.arabic,
    required this.canEditTeam, required this.notifier, required this.onOpenEditTeam,
    required this.onSave, super.key,
  });

  final List<EntityOption> teams;
  final EntityOption? selected;
  final dynamic state;
  final bool arabic;
  final bool canEditTeam;
  final SiteAttendanceNotifier notifier;
  final VoidCallback onOpenEditTeam;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SiteAttendanceHeader(
        teams: teams, selected: selected, state: state, arabic: arabic, canEditTeam: canEditTeam,
        onTeamChanged: (id) => unawaited(notifier.selectTeam(teams.where((t) => t.id == id).firstOrNull)),
        onDateSelected: (d) => unawaited(notifier.selectDate(d)),
        onEditTeam: selected == null ? null : onOpenEditTeam,
        onSelectAll: notifier.selectAll,
        onSelectDefaultCrew: notifier.selectDefaultCrew,
        onAddGuest: () => CrossTeamSearchSheet.show(
          context: context, arabic: arabic, onSearch: notifier.searchGuests, onWorkerSelected: notifier.addGuestWorker,
        ),
      ),
      if (state.errorMessage != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
          child: Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      if (selected != null && state.rows.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space4),
          child: TextField(
            key: const ValueKey('site_worker_search_field'),
            decoration: InputDecoration(
              hintText: OperationsStrings.searchWorkersHint(arabic), prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radius12)),
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => notifier.setSearchQuery(''))
                  : null,
            ),
            onChanged: notifier.setSearchQuery,
          ),
        ),
      Expanded(
        child: SiteWorkerListView(
          state: state, selected: selected, arabic: arabic,
          onToggle: (id) { unawaited(FieldHaptics.attendanceChanged()); notifier.toggleWorker(id); },
          onRemoveGuest: notifier.removeGuestWorker,
        ),
      ),
      AttendanceCounterBar(
        presentCount: state.presentCount, arabic: arabic,
        enabled: selected != null && !state.isLoading, isSaving: state.isSaving, onSave: onSave,
        isFriday: FridayResolver.isFriday(state.selectedDate),
      ),
    ]);
  }
}
