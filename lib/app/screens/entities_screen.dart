import 'package:drift/drift.dart' as drift;
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/entities_add_dialog.dart';
import 'package:radar_labor/app/screens/entities_list_view.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:uuid/uuid.dart';

final class EntitiesScreen extends StatefulWidget {
  const EntitiesScreen({
    required this.database, required this.arabic, required this.teams, super.key,
  });

  final AppDatabase database;
  final bool arabic;
  final bool teams;

  @override
  State<EntitiesScreen> createState() => _EntitiesScreenState();
}

final class _EntitiesScreenState extends State<EntitiesScreen> {
  Future<void> _add() async {
    final name = await showAddTeamDialog(context: context, arabic: widget.arabic);
    if (name == null || !mounted) return;
    final teamId = const Uuid().v4();
    await widget.database.into(widget.database.teams).insert(
      TeamsCompanion.insert(teamId: teamId, nameAr: name, nameEn: drift.Value(name)),
    );
    await AuditLogRepository(database: widget.database).record(
      userId: null, action: 'team_created', entityType: 'team', entityId: teamId,
    );
  }

  Stream<List<String>> _buildStream() {
    if (!widget.teams) {
      return Stream.value([HousingConstants.defaultHousingName]);
    }
    return widget.database.select(widget.database.teams).watch().map(
      (rows) => rows
          .map((r) => (r.nameEn != null && r.nameEn!.trim().isNotEmpty) ? r.nameEn! : r.nameAr)
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: widget.teams
          ? FloatingActionButton.extended(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: Text(AppStrings.add(widget.arabic)),
            )
          : null,
      body: EntitiesListView(
        stream: _buildStream(),
        isTeam: widget.teams,
        arabic: widget.arabic,
      ),
    );
  }
}
