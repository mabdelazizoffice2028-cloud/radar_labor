import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

final class RosterAdminWorkerUpdater {
  const RosterAdminWorkerUpdater({required this.database, required this.audit});

  final AppDatabase database;
  final AuditLogRepository audit;

  Future<void> update({
    required ActorContext actor,
    required String uid,
    String? nameAr,
    String? nameEn,
    String? category,
    Value<String?> teamId = const Value.absent(),
  }) async {
    _guard(actor);
    await database.transaction(() async {
      final ex = await _requireEmp(uid);
      await (database.update(database.employees)..where((r) => r.iqamaNo.equals(uid)))
          .write(EmployeesCompanion(
        fullNameAr: nameAr != null ? Value(nameAr.trim()) : const Value.absent(),
        fullNameEn: nameEn != null ? Value(nameEn.trim()) : const Value.absent(),
        jobTitle: category != null ? Value(category.trim()) : const Value.absent(),
        currentTeamId: teamId,
        rowVersion: Value(ex.rowVersion + 1),
      ));
      await audit.record(
        userId: actor.userId,
        action: 'worker_updated',
        entityType: 'employee',
        entityId: uid,
      );
    });
  }

  Future<void> archive({required ActorContext actor, required String uid}) async {
    _guard(actor);
    await database.transaction(() async {
      final ex = await _requireEmp(uid);
      await (database.update(database.employees)..where((r) => r.iqamaNo.equals(uid)))
          .write(EmployeesCompanion(
        archivedAt: Value(audit.clock.nowUtc()),
        currentTeamId: const Value(null),
        rowVersion: Value(ex.rowVersion + 1),
      ));
      await audit.record(
        userId: actor.userId,
        action: 'worker_archived',
        entityType: 'employee',
        entityId: uid,
      );
    });
  }

  Future<Employee> _requireEmp(String uid) async =>
      await (database.select(database.employees)..where((e) => e.iqamaNo.equals(uid)))
          .getSingleOrNull() ??
      (throw OperationException(WorkersUnavailable({uid})));

  void _guard(ActorContext actor) {
    if (!actor.capabilities.canManageReferenceData) {
      throw const OperationException(PermissionDenied());
    }
  }
}
