import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/roster_wipe_plan.dart';

final class RosterAdminBackupHelper {
  const RosterAdminBackupHelper({required this.database, required this.audit});
  final AppDatabase database;
  final AuditLogRepository audit;

  Future<int> readRosterEpoch() async {
    final q = database.select(database.settings)..where((s) => s.key.equals(AppSettingKeys.rosterEpoch));
    return int.tryParse((await q.getSingleOrNull())?.value ?? '1') ?? 1;
  }

  Future<String> exportRosterBackupJson({required ActorContext actor}) async {
    _guard(actor.capabilities.canWipeRoster);
    final employees = await database.select(database.employees).get();
    final teams = await database.select(database.teams).get();
    return jsonEncode({
      'rosterEpoch': await readRosterEpoch(),
      'employees': [for (final e in employees) {'employeeUid': e.iqamaNo, 'employeeCode': e.iqamaNo, 'fullNameAr': e.fullNameAr, 'isActive': e.isActive}],
      'teams': [for (final t in teams) {'teamId': t.teamId, 'nameAr': t.nameAr}],
      'housings': [{'housingId': HousingConstants.defaultHousingId, 'nameAr': HousingConstants.defaultHousingNameAr}],
    });
  }

  Future<RosterWipePlan> wipeRoster({
    required ActorContext actor,
    required bool backupExported,
    required String confirmationText,
  }) async {
    _guard(actor.capabilities.canWipeRoster);
    return database.transaction(() async {
      final employees = await database.select(database.employees).get();
      final plan = RosterWipePlan.compute(
        backupExported: backupExported,
        confirmationText: confirmationText,
        currentEpoch: await readRosterEpoch(),
        employees: [for (final e in employees) (employeeUid: e.iqamaNo, isActive: e.isActive, currentTeamId: e.currentTeamId)],
      );
      for (final emp in employees) {
        if (!emp.isActive && emp.currentTeamId == null) continue;
        await (database.update(database.employees)..where((r) => r.iqamaNo.equals(emp.iqamaNo))).write(
          EmployeesCompanion(archivedAt: Value(audit.clock.nowUtc()), currentTeamId: const Value(null), rowVersion: Value(emp.rowVersion + 1)),
        );
      }
      await database.into(database.settings).insertOnConflictUpdate(
        SettingsCompanion.insert(key: AppSettingKeys.rosterEpoch, value: '${plan.nextEpoch}'),
      );
      await audit.record(userId: actor.userId, action: 'roster_wiped', entityType: 'roster', entityId: 'e_${plan.nextEpoch}');
      return plan;
    });
  }

  void _guard(bool ok) => ok ? null : throw const OperationException(PermissionDenied());
}
