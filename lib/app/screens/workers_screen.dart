import 'package:drift/drift.dart' as drift;
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:uuid/uuid.dart';

/// Screen for viewing and managing workforce employees (BC-2: direct event recording removed).
final class WorkersScreen extends StatefulWidget {
  const WorkersScreen({
    required this.database,
    required this.events,
    required this.arabic,
    super.key,
  });

  final AppDatabase database;
  final EventRepository events;
  final bool arabic;

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

final class _WorkersScreenState extends State<WorkersScreen> {
  String _query = '';

  Future<void> _add() async {
    final teams = await (widget.database.select(
      widget.database.teams,
    )..where((row) => row.isActive)).get();
    final housings = await (widget.database.select(
      widget.database.housings,
    )..where((row) => row.isActive)).get();
    if (!mounted) return;

    final code = TextEditingController();
    final arabicName = TextEditingController();
    final englishName = TextEditingController();
    String? selectedTeam;
    String? selectedHousing;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: Text(AppStrings.addWorker(widget.arabic)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: code,
                  decoration: InputDecoration(
                    labelText: AppStrings.workerCode(widget.arabic),
                  ),
                ),
                TextField(
                  controller: arabicName,
                  decoration: InputDecoration(
                    labelText: AppStrings.arabicName(widget.arabic),
                  ),
                ),
                TextField(
                  controller: englishName,
                  decoration: InputDecoration(
                    labelText: AppStrings.englishName(widget.arabic),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  initialValue: selectedTeam,
                  decoration: InputDecoration(
                    labelText: AppStrings.currentTeam(widget.arabic),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(AppStrings.noTeam(widget.arabic)),
                    ),
                    ...teams.map(
                      (team) => DropdownMenuItem<String?>(
                        value: team.teamId,
                        child: Text(
                          widget.arabic
                              ? team.nameAr
                              : (team.nameEn ?? team.nameAr),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      updateDialog(() => selectedTeam = value),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  initialValue: selectedHousing,
                  decoration: InputDecoration(
                    labelText: AppStrings.currentHousing(widget.arabic),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(AppStrings.noHousing(widget.arabic)),
                    ),
                    ...housings.map(
                      (housing) => DropdownMenuItem<String?>(
                        value: housing.housingId,
                        child: Text(
                          widget.arabic
                              ? housing.nameAr
                              : (housing.nameEn ?? housing.nameAr),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      updateDialog(() => selectedHousing = value),
                ),
              ],
            ),
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
      ),
    );

    if (saved != true ||
        code.text.trim().isEmpty ||
        arabicName.text.trim().isEmpty) {
      return;
    }

    try {
      await widget.database
          .into(widget.database.employees)
          .insert(
            EmployeesCompanion.insert(
              employeeUid: const Uuid().v4(),
              employeeCode: code.text.trim(),
              fullNameAr: arabicName.text.trim(),
              fullNameEn: drift.Value(
                englishName.text.trim().isEmpty
                    ? null
                    : englishName.text.trim(),
              ),
              category: 'general',
              currentTeamId: drift.Value(selectedTeam),
              housingId: drift.Value(selectedHousing),
            ),
          );
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.workerCodeExists(widget.arabic))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _add,
      icon: const Icon(Icons.person_add_alt_1),
      label: Text(AppStrings.addWorker(widget.arabic)),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: AppStrings.searchWorker(widget.arabic),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Employee>>(
            stream: widget.database.select(widget.database.employees).watch(),
            builder: (context, state) {
              final queryNorm = _query.trim().toLowerCase();
              final workers = (state.data ?? []).where((worker) {
                if (queryNorm.isEmpty) return true;
                return worker.fullNameAr.toLowerCase().contains(queryNorm) ||
                    worker.employeeCode.toLowerCase().contains(queryNorm) ||
                    (worker.fullNameEn ?? '').toLowerCase().contains(queryNorm);
              }).toList();
              if (workers.isEmpty) {
                return Center(
                  child: Text(AppStrings.noWorkersYet(widget.arabic)),
                );
              }
              return ListView.builder(
                itemCount: workers.length,
                itemBuilder: (context, i) {
                  final worker = workers[i];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        widget.arabic
                            ? worker.fullNameAr
                            : (worker.fullNameEn ?? worker.fullNameAr),
                      ),
                      subtitle: Text(
                        '${AppStrings.workerCode(widget.arabic)}: ${worker.employeeCode}',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
