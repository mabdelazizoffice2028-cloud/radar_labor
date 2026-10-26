import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/roster_wipe_plan.dart';
import 'package:uuid/uuid.dart';

/// Repository for audited administrative mutations on workforce, teams, housings, and accounts (PRD §17.4, §23.4, §23.5).
final class RosterAdminRepository {
  RosterAdminRepository({
    required this.database,
    required this.audit,
    required this.auth,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase database;
  final AuditLogRepository audit;
  final LocalAuthRepository auth;
  final Uuid _uuid;

  Future<int> readRosterEpoch() async {
    final q = database.select(database.settings)
      ..where((s) => s.key.equals(AppSettingKeys.rosterEpoch));
    return int.tryParse((await q.getSingleOrNull())?.value ?? '1') ?? 1;
  }

  Future<String> createWorker({
    required ActorContext actor,
    required String code,
    required String fullNameAr,
    String? fullNameEn,
    String category = 'Worker',
    String? supplier,
    String? teamId,
    String? housingId,
  }) async {
    _guard(actor.capabilities.canManageReferenceData);
    final uid = _uuid.v4();
    await database.transaction(() async {
      await _insertEmp(
        EmployeesCompanion.insert(
          employeeUid: uid,
          employeeCode: code.trim(),
          fullNameAr: fullNameAr.trim(),
          fullNameEn: Value(fullNameEn?.trim()),
          category: category.trim(),
          supplier: Value(supplier?.trim()),
          currentTeamId: Value(teamId),
          housingId: Value(housingId),
        ),
      );
      await _log(actor.userId, 'worker_created', 'employee', uid);
    });
    return uid;
  }

  Future<void> updateWorker({
    required ActorContext actor,
    required String employeeUid,
    String? fullNameAr,
    String? fullNameEn,
    String? category,
    Value<String?> currentTeamId = const Value.absent(),
    Value<String?> housingId = const Value.absent(),
  }) async {
    _guard(actor.capabilities.canManageReferenceData);
    await database.transaction(() async {
      final ex = await _requireEmployee(employeeUid);
      Value<String> opt(String? v) =>
          v == null ? const Value.absent() : Value(v.trim());
      await _writeEmp(
        employeeUid,
        EmployeesCompanion(
          fullNameAr: opt(fullNameAr),
          fullNameEn: opt(fullNameEn),
          category: opt(category),
          currentTeamId: currentTeamId,
          housingId: housingId,
          rowVersion: Value(ex.rowVersion + 1),
        ),
      );
      await _log(actor.userId, 'worker_updated', 'employee', employeeUid);
    });
  }

  /// Archives a worker (`isActive = false`) while preserving historical events (D-24).
  Future<void> archiveWorker({
    required ActorContext actor,
    required String employeeUid,
  }) async {
    _guard(actor.capabilities.canManageReferenceData);
    await database.transaction(() async {
      final ex = await _requireEmployee(employeeUid);
      await _writeEmp(employeeUid, _archiveCompanion(ex.rowVersion + 1));
      await _log(actor.userId, 'worker_archived', 'employee', employeeUid);
    });
  }

  EmployeesCompanion _archiveCompanion(int nextVer) => EmployeesCompanion(
    isActive: const Value(false),
    currentTeamId: const Value(null),
    rowVersion: Value(nextVer),
  );

  Future<String> createAccountAudited({
    required ActorContext actor,
    String? employeeUid,
    required String displayName,
    required AuthRole role,
    List<String> teamIds = const [],
    List<String> housingIds = const [],
  }) async {
    _guard(actor.capabilities.canManageAccounts);
    return database.transaction(() async {
      await auth.createAccount(
        employeeUid: employeeUid,
        displayName: displayName,
        role: role,
        teamIds: teamIds,
        housingIds: housingIds,
      );
      final needle = displayName.trim().toLowerCase();
      final created = (await auth.accounts()).firstWhere(
        (a) =>
            a.role == role &&
            (employeeUid != null
                ? a.employeeUid == employeeUid
                : a.displayName.toLowerCase() == needle),
      );
      await _log(actor.userId, 'account_created', 'account', created.id);
      return created.id;
    });
  }

  Future<void> resetPasswordAudited({
    required ActorContext actor,
    required String accountId,
  }) => _auditAccount(actor, accountId, 'password_reset', auth.resetPassword);

  Future<void> deactivateAccountAudited({
    required ActorContext actor,
    required String accountId,
  }) => _auditAccount(
    actor,
    accountId,
    'account_deactivated',
    auth.deactivateAccount,
  );

  Future<void> _auditAccount(
    ActorContext a,
    String id,
    String action,
    Future<void> Function(String) fn,
  ) {
    _guard(a.capabilities.canManageAccounts);
    return database.transaction(() async {
      await fn(id);
      await _log(a.userId, action, 'account', id);
    });
  }

  /// Imports workforce rows atomically, reactivating matching `employee_code` rows (D-29) and recording audit.
  Future<RosterImportResult> importRosterAudited({
    required ActorContext actor,
    required List<RosterImportEntry> rows,
  }) async {
    _guard(actor.capabilities.canManageReferenceData);
    return database.transaction(() async {
      var added = 0, updated = 0;
      final byCode = {
        for (final emp in await database.select(database.employees).get())
          emp.employeeCode.toLowerCase(): emp,
      };
      for (final row in rows) {
        final existing = byCode[row.code.toLowerCase()];
        final cat = row.designation.isEmpty ? 'Worker' : row.designation;
        final sup = row.supplier.isEmpty ? null : row.supplier;
        if (existing == null) {
          await _insertEmp(
            EmployeesCompanion.insert(
              employeeUid: _uuid.v4(),
              employeeCode: row.code,
              fullNameAr: row.name,
              fullNameEn: Value(row.name),
              category: cat,
              supplier: Value(sup),
            ),
          );
          added++;
        } else {
          await _writeEmp(
            existing.employeeUid,
            EmployeesCompanion(
              fullNameAr: Value(row.name),
              fullNameEn: Value(row.name),
              category: Value(cat),
              supplier: Value(sup),
              isActive: const Value(true),
              rowVersion: Value(existing.rowVersion + 1),
            ),
          );
          updated++;
        }
      }
      await _log(actor.userId, 'roster_imported', 'roster', 'n_${rows.length}');
      return RosterImportResult(added: added, updated: updated);
    });
  }

  /// Exports a privacy-safe JSON backup of roster reference data before a roster wipe (PRD §23.4).
  Future<String> exportRosterBackupJson({required ActorContext actor}) async {
    _guard(actor.capabilities.canWipeRoster);
    final employees = await database.select(database.employees).get();
    final teams = await database.select(database.teams).get();
    final housings = await database.select(database.housings).get();
    return jsonEncode({
      'rosterEpoch': await readRosterEpoch(),
      'employees': [for (final e in employees) _empMap(e)],
      'teams': [
        for (final t in teams) {'teamId': t.teamId, 'nameAr': t.nameAr},
      ],
      'housings': [
        for (final h in housings)
          {'housingId': h.housingId, 'nameAr': h.nameAr},
      ],
    });
  }

  Map<String, Object?> _empMap(Employee e) => {
    'employeeUid': e.employeeUid,
    'employeeCode': e.employeeCode,
    'fullNameAr': e.fullNameAr,
    'isActive': e.isActive,
  };

  /// Executes an atomic roster wipe: archives all workers, clears team assignments, increments `roster_epoch`, and audits (PRD §23.4).
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
        employees: [for (final e in employees) _wipeTuple(e)],
      );
      for (final emp in employees) {
        if (!emp.isActive && emp.currentTeamId == null) continue;
        await _writeEmp(emp.employeeUid, _archiveCompanion(emp.rowVersion + 1));
      }
      final sComp = SettingsCompanion.insert(
        key: AppSettingKeys.rosterEpoch,
        value: '${plan.nextEpoch}',
      );
      await database.into(database.settings).insertOnConflictUpdate(sComp);
      await _log(actor.userId, 'roster_wiped', 'roster', 'e_${plan.nextEpoch}');
      return plan;
    });
  }

  ({String employeeUid, bool isActive, String? currentTeamId}) _wipeTuple(
    Employee e,
  ) => (
    employeeUid: e.employeeUid,
    isActive: e.isActive,
    currentTeamId: e.currentTeamId,
  );

  Future<int> _insertEmp(EmployeesCompanion c) =>
      database.into(database.employees).insert(c);

  Future<int> _writeEmp(String uid, EmployeesCompanion c) => (database.update(
    database.employees,
  )..where((r) => r.employeeUid.equals(uid))).write(c);

  Future<void> _log(String? u, String a, String t, String id) =>
      audit.record(userId: u, action: a, entityType: t, entityId: id);

  Future<Employee> _requireEmployee(String uid) async =>
      await (database.select(
        database.employees,
      )..where((e) => e.employeeUid.equals(uid))).getSingleOrNull() ??
      (throw OperationException(WorkersUnavailable({uid})));

  void _guard(bool ok) =>
      ok ? null : throw const OperationException(PermissionDenied());
}
