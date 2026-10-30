import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/roster_wipe_plan.dart';
import 'package:uuid/uuid.dart';

final class RosterAdminImporter {
  const RosterAdminImporter({required this.database, required this.audit});
  final AppDatabase database;
  final AuditLogRepository audit;

  Future<RosterImportResult> importRosterAudited({
    required ActorContext actor,
    required List<RosterImportEntry> rows,
  }) async {
    if (!actor.capabilities.canManageReferenceData) {
      throw const OperationException(PermissionDenied());
    }
    _validateRows(rows);
    return database.transaction(() async {
      var added = 0, updated = 0;
      final existing = await database.select(database.employees).get();
      final byCode = {for (final e in existing) e.iqamaNo: e};
      const uuid = Uuid();
      final now = audit.clock.nowUtc();

      for (final r in rows) {
        final iqama = r.code.trim();
        final ex = byCode[iqama];
        final cat = r.designation.isEmpty ? 'direct_labor' : r.designation;
        final isRental = r.supplier.isNotEmpty;
        if (ex == null) {
          await database.into(database.employees).insert(EmployeesCompanion.insert(
            iqamaNo: iqama, fullNameAr: r.name, fullNameEn: Value(r.name), jobTitle: Value(cat), jobCategory: Value(cat),
            employmentType: Value(isRental ? 'rental' : 'company'), rentalCompany: Value(isRental ? r.supplier : null),
          ));
          await database.into(database.workerHistory).insert(WorkerHistoryCompanion.insert(
            historyId: uuid.v4(), iqamaNo: iqama, action: 'imported_create',
            details: Value('Roster import: ${r.name}'), userId: Value(actor.userId), createdAt: now,
          ));
          added++;
        } else {
          await (database.update(database.employees)..where((e) => e.iqamaNo.equals(iqama))).write(EmployeesCompanion(
            fullNameAr: Value(r.name), fullNameEn: Value(r.name), jobTitle: Value(cat),
            rentalCompany: Value(isRental ? r.supplier : null), employmentType: Value(isRental ? 'rental' : 'company'),
            archivedAt: const Value(null), rowVersion: Value(ex.rowVersion + 1),
          ));
          await database.into(database.workerHistory).insert(WorkerHistoryCompanion.insert(
            historyId: uuid.v4(), iqamaNo: iqama, action: 'imported_update',
            details: Value('Roster import update: ${r.name}'), userId: Value(actor.userId), createdAt: now,
          ));
          updated++;
        }
      }
      await audit.record(userId: actor.userId, action: 'roster_imported', entityType: 'roster', entityId: 'n_${rows.length}');
      return RosterImportResult(added: added, updated: updated);
    });
  }

  void _validateRows(List<RosterImportEntry> rows) {
    final seen = <String>{};
    final regex = RegExp(r'^\d{10}$');
    for (final r in rows) {
      final code = r.code.trim();
      if (!regex.hasMatch(code)) {
        throw FormatException('رقم الإقامة غير صالح (يجب 10 أرقام): $code');
      }
      if (!seen.add(code)) {
        throw FormatException('رقم إقامة مكرر داخل ملف الاستيراد: $code');
      }
    }
  }
}
