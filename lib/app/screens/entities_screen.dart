import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/entities_list_view.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class EntitiesScreen extends StatelessWidget {
  const EntitiesScreen({
    required this.database,
    required this.arabic,
    required this.teams,
    super.key,
  });

  final AppDatabase database;
  final bool arabic;
  final bool teams;

  Stream<List<String>> _buildStream() {
    if (!teams) {
      return Stream.value([HousingConstants.defaultHousingName]);
    }
    return database
        .select(database.teams)
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => (r.nameEn != null && r.nameEn!.trim().isNotEmpty)
                    ? r.nameEn!
                    : r.nameAr,
              )
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.transparent,
      body: EntitiesListView(
        stream: _buildStream(),
        isTeam: teams,
        arabic: arabic,
      ),
    );
  }
}
