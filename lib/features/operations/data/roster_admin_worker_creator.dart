import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

final class RosterAdminWorkerCreator {
  const RosterAdminWorkerCreator({required this.database, required this.audit});

  final AppDatabase database;
  final AuditLogRepository audit;

  Future<String> create({
    required ActorContext actor,
    required String code,
    required String fullNameAr,
    String? fullNameEn,
    String category = 'Worker',
    String? supplier,
    String? teamId,
  }) async {
    if (!actor.capabilities.canManageReferenceData) {
      throw const OperationException(PermissionDenied());
    }
    final iqama = code.trim().length >= 10
        ? code.trim().substring(0, 10)
        : code.trim().padLeft(10, '0');
    final isRental = supplier != null && supplier.trim().isNotEmpty;
    await database.transaction(() async {
      await database.into(database.employees).insert(
            EmployeesCompanion.insert(
              iqamaNo: iqama,
              fullNameAr: fullNameAr.trim(),
              fullNameEn: Value(fullNameEn?.trim()),
              jobTitle: Value(category.trim()),
              jobCategory: Value(category.trim()),
              employmentType: Value(isRental ? 'rental' : 'company'),
              rentalCompany: Value(supplier?.trim()),
              currentTeamId: Value(teamId),
            ),
          );
      await audit.record(
        userId: actor.userId,
        action: 'worker_created',
        entityType: 'employee',
        entityId: iqama,
      );
    });
    return iqama;
  }
}
