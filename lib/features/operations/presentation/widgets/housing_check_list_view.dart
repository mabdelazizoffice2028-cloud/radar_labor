import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_worker_tile.dart';

final class HousingCheckListView extends StatelessWidget {
  const HousingCheckListView({
    required this.state, required this.arabic, required this.onToggleAbsent, super.key,
  });

  final HousingCheckState state;
  final bool arabic;
  final ValueChanged<String> onToggleAbsent;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.rows.isEmpty) return Center(child: Text(OperationsStrings.noWorkersInHousing(arabic)));

    return ListView.builder(
      itemCount: state.filteredRows.length,
      itemBuilder: (context, i) => HousingWorkerTile(
        row: state.filteredRows[i],
        arabic: arabic,
        searchQuery: state.searchQuery,
        onStateChanged: (_) {
          FieldHaptics.attendanceChanged();
          onToggleAbsent(state.filteredRows[i].worker.id);
        },
      ),
    );
  }
}
