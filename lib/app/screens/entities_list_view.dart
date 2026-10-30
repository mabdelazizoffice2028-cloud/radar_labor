import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/entity_card_tile.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

class EntitiesListView extends StatelessWidget {
  const EntitiesListView({
    required this.stream,
    required this.isTeam,
    required this.arabic,
    super.key,
  });

  final Stream<List<String>> stream;
  final bool isTeam;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: stream,
      builder: (context, state) {
        final rows = state.data ?? [];
        if (rows.isEmpty) {
          return Center(child: Text(AppStrings.noDataYet(arabic)));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: rows.length,
          itemBuilder: (context, i) => EntityCardTile(
            title: rows[i],
            isTeam: isTeam,
          ),
        );
      },
    );
  }
}
