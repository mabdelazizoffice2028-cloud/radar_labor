import 'package:drift/drift.dart' as drift;
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:uuid/uuid.dart';

/// Screen for viewing and managing organizational entities (Teams or Housings).
final class EntitiesScreen extends StatefulWidget {
  const EntitiesScreen({
    required this.database,
    required this.arabic,
    required this.teams,
    super.key,
  });

  final AppDatabase database;
  final bool arabic;
  final bool teams;

  @override
  State<EntitiesScreen> createState() => _EntitiesScreenState();
}

final class _EntitiesScreenState extends State<EntitiesScreen> {
  Future<void> _add() async {
    final ar = TextEditingController();
    final en = TextEditingController();

    final title = widget.teams
        ? AppStrings.addTeam(widget.arabic)
        : AppStrings.addHousing(widget.arabic);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ar,
              decoration: InputDecoration(
                labelText: AppStrings.arabicName(widget.arabic),
              ),
            ),
            TextField(
              controller: en,
              decoration: InputDecoration(
                labelText: AppStrings.englishName(widget.arabic),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel(widget.arabic)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.save(widget.arabic)),
          ),
        ],
      ),
    );

    if (saved != true || ar.text.trim().isEmpty) return;
    final id = const Uuid().v4();

    if (widget.teams) {
      await widget.database
          .into(widget.database.teams)
          .insert(
            TeamsCompanion.insert(
              teamId: id,
              nameAr: ar.text.trim(),
              nameEn: drift.Value(
                en.text.trim().isEmpty ? null : en.text.trim(),
              ),
            ),
          );
    } else {
      await widget.database
          .into(widget.database.housings)
          .insert(
            HousingsCompanion.insert(
              housingId: id,
              nameAr: ar.text.trim(),
              nameEn: drift.Value(
                en.text.trim().isEmpty ? null : en.text.trim(),
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.teams
        ? widget.database
              .select(widget.database.teams)
              .watch()
              .map(
                (rows) => rows
                    .map(
                      (row) => widget.arabic
                          ? row.nameAr
                          : (row.nameEn ?? row.nameAr),
                    )
                    .toList(),
              )
        : widget.database
              .select(widget.database.housings)
              .watch()
              .map(
                (rows) => rows
                    .map(
                      (row) => widget.arabic
                          ? row.nameAr
                          : (row.nameEn ?? row.nameAr),
                    )
                    .toList(),
              );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.add(widget.arabic)),
      ),
      body: StreamBuilder<List<String>>(
        stream: stream,
        builder: (context, state) {
          final rows = state.data ?? [];
          if (rows.isEmpty) {
            return Center(child: Text(AppStrings.noDataYet(widget.arabic)));
          }
          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final name = rows[i];
              return Card(
                child: ListTile(
                  leading: Icon(
                    widget.teams ? Icons.groups_2 : Icons.apartment,
                  ),
                  title: Text(name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
