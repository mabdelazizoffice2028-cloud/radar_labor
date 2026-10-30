import 'package:drift/drift.dart' as drift;
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

Future<void> showAddWorkerDialog({
  required BuildContext context,
  required AppDatabase database,
  required bool arabic,
  required void Function(String) showMessage,
}) async {
  final teams = await (database.select(database.teams)..where((r) => r.isActive)).get();
  if (!context.mounted) return;
  final code = TextEditingController();
  final nameCtrl = TextEditingController();
  String? teamId;

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSt) => AlertDialog(
        title: Text(AppStrings.addWorker(arabic)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: code, decoration: InputDecoration(labelText: AppStrings.workerCode(arabic))),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: arabic ? 'اسم العامل (بالإنجليزية)' : 'Worker name (English)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String?>(
                initialValue: teamId,
                decoration: InputDecoration(labelText: AppStrings.currentTeam(arabic)),
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text(AppStrings.noTeam(arabic))),
                  ...teams.map((t) => DropdownMenuItem(value: t.teamId, child: Text(t.nameEn ?? t.nameAr))),
                ],
                onChanged: (v) => setSt(() => teamId = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel(arabic))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.save(arabic))),
        ],
      ),
    ),
  );

  if (saved != true || code.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) return;
  final iqama = code.text.trim();
  final name = nameCtrl.text.trim();
  final existing = await (database.select(database.employees)..where((e) => e.iqamaNo.equals(iqama))).get();
  if (existing.isNotEmpty) {
    showMessage(AppStrings.workerCodeExists(arabic));
    return;
  }
  await database.into(database.employees).insert(EmployeesCompanion.insert(
    iqamaNo: iqama, fullNameAr: name, fullNameEn: drift.Value(name), currentTeamId: drift.Value(teamId),
  ));
  await AuditLogRepository(database: database).record(
    userId: null, action: 'worker_created', entityType: 'worker', entityId: iqama,
  );
}
