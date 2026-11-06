import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/operations/data/backup/database_backup_exporter.dart';
import 'package:radar_labor/features/operations/data/backup/database_backup_models.dart';
import 'package:radar_labor/features/operations/data/backup/database_restore_applier.dart';
import 'package:radar_labor/features/operations/data/backup/database_restore_validator.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

final class DatabaseBackupService {
  const DatabaseBackupService({required this.database, required this.audit});
  final AppDatabase database;
  final AuditLogRepository audit;

  static const _validConfirmations = {'استعادة نسخة احتياطية', 'RESTORE BACKUP'};

  Future<String> exportBackupJson({required ActorContext actor}) async {
    _guard(actor.capabilities.canWipeRoster || actor.capabilities.canManageReferenceData);
    final jsonStr = await DatabaseBackupExporter.export(database, audit.clock);
    await audit.record(
      userId: actor.userId,
      action: 'backup_exported',
      entityType: 'database_backup',
      entityId: 'size:${jsonStr.length}',
    );
    return jsonStr;
  }

  Future<void> restoreBackupJson({
    required ActorContext actor,
    required String jsonStr,
    required String confirmationText,
  }) async {
    _guard(actor.capabilities.canWipeRoster || actor.capabilities.canManageReferenceData);
    if (!_validConfirmations.contains(confirmationText.trim())) {
      throw const BackupValidationException('Explicit confirmation text is required.');
    }
    final validated = DatabaseRestoreValidator.validate(jsonStr);
    await DatabaseRestoreApplier.apply(database, validated);
    await audit.record(
      userId: actor.userId,
      action: 'backup_restored',
      entityType: 'database_backup',
      entityId: 'events:${validated.events.length}|employees:${validated.employees.length}',
    );
  }

  void _guard(bool allowed) {
    if (!allowed) throw const OperationException(PermissionDenied());
  }
}
