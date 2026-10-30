import 'package:drift/drift.dart' as drift;
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/worker_add_dialog_view.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:uuid/uuid.dart';

Future<void> showAddWorkerDialog({
  required BuildContext context,
  required AppDatabase database,
  required bool arabic,
  required void Function(String) showMessage,
  String? actorUserId,
  Clock clock = const SystemClock(),
}) async {
  final teams = await (database.select(database.teams)..where((r) => r.isActive)).get();
  if (!context.mounted) return;
  final code = TextEditingController();
  final nameCtrl = TextEditingController();
  final key = GlobalKey<WorkerAddDialogViewState>();

  try {
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => WorkerAddDialogView(
        key: key, codeController: code, nameController: nameCtrl, teams: teams, arabic: arabic,
      ),
    );

    if (saved != true || code.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) return;
    final iqama = code.text.trim();
    final name = nameCtrl.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(iqama)) {
      await FieldHaptics.error();
      showMessage(AppStrings.invalidIqama(arabic));
      return;
    }
    final teamId = key.currentState?.selectedTeamId;
    final existing = await (database.select(database.employees)..where((e) => e.iqamaNo.equals(iqama))).get();
    if (existing.isNotEmpty) {
      await FieldHaptics.error();
      showMessage(AppStrings.workerCodeExists(arabic));
      return;
    }

    final now = clock.nowUtc();
    try {
      await database.transaction(() async {
        await database.into(database.employees).insert(
          EmployeesCompanion.insert(
            iqamaNo: iqama, fullNameAr: name, fullNameEn: drift.Value(name), currentTeamId: drift.Value(teamId),
          ),
        );
        await database.into(database.workerHistory).insert(
          WorkerHistoryCompanion.insert(
            historyId: const Uuid().v4(), iqamaNo: iqama, action: 'manual_create',
            details: drift.Value('Worker created: $name'), createdAt: now,
          ),
        );
      });
      await FieldHaptics.success();
      await AuditLogRepository(database: database, clock: clock).record(
        userId: actorUserId, action: 'worker_created', entityType: 'worker', entityId: iqama,
      );
    } catch (e) {
      debugPrint('Error adding worker: $e');
      await FieldHaptics.error();
      showMessage(AppStrings.workerSaveFailed(arabic));
    }
  } finally {
    code.dispose();
    nameCtrl.dispose();
  }
}
