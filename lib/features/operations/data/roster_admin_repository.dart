import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/operations/data/roster_admin_account_helper.dart';
import 'package:radar_labor/features/operations/data/roster_admin_backup_helper.dart';
import 'package:radar_labor/features/operations/data/roster_admin_importer.dart';
import 'package:radar_labor/features/operations/data/roster_admin_worker_creator.dart';
import 'package:radar_labor/features/operations/data/roster_admin_worker_updater.dart';
import 'package:radar_labor/features/operations/domain/roster_wipe_plan.dart';

final class RosterAdminRepository {
  RosterAdminRepository({required this.database, required this.audit, LocalAuthRepository? auth})
      : auth = auth ?? LocalAuthRepository(database),
        _backup = RosterAdminBackupHelper(database: database, audit: audit),
        _acc = RosterAdminAccountHelper(database: database, audit: audit, auth: auth ?? LocalAuthRepository(database)),
        _importer = RosterAdminImporter(database: database, audit: audit),
        _creator = RosterAdminWorkerCreator(database: database, audit: audit),
        _updater = RosterAdminWorkerUpdater(database: database, audit: audit);

  final AppDatabase database;
  final AuditLogRepository audit;
  final LocalAuthRepository auth;
  final RosterAdminBackupHelper _backup;
  final RosterAdminAccountHelper _acc;
  final RosterAdminImporter _importer;
  final RosterAdminWorkerCreator _creator;
  final RosterAdminWorkerUpdater _updater;

  Future<int> readRosterEpoch() => _backup.readRosterEpoch();
  Future<String> exportRosterBackupJson({required ActorContext actor}) => _backup.exportRosterBackupJson(actor: actor);
  Future<RosterWipePlan> wipeRoster({required ActorContext actor, required bool backupExported, required String confirmationText}) =>
      _backup.wipeRoster(actor: actor, backupExported: backupExported, confirmationText: confirmationText);

  Future<String> createAccountAudited({required ActorContext actor, String? employeeUid, required String displayName, required AuthRole role, List<String> teamIds = const [], List<String> housingIds = const []}) =>
      _acc.createAccountAudited(actor: actor, employeeUid: employeeUid, displayName: displayName, role: role, teamIds: teamIds, housingIds: housingIds);
  Future<void> resetPasswordAudited({required ActorContext actor, required String accountId}) => _acc.resetPasswordAudited(actor: actor, accountId: accountId);
  Future<void> deactivateAccountAudited({required ActorContext actor, required String accountId}) => _acc.deactivateAccountAudited(actor: actor, accountId: accountId);
  Future<RosterImportResult> importRosterAudited({required ActorContext actor, required List<RosterImportEntry> rows}) => _importer.importRosterAudited(actor: actor, rows: rows);

  Future<String> createWorker({
    required ActorContext actor,
    required String code,
    required String fullNameAr,
    String? fullNameEn,
    String category = 'Worker',
    String? supplier,
    String? teamId,
    String? housingId,
  }) => _creator.create(actor: actor, code: code, fullNameAr: fullNameAr, fullNameEn: fullNameEn, category: category, supplier: supplier, teamId: teamId);

  Future<void> updateWorker({
    required ActorContext actor,
    required String employeeUid,
    String? fullNameAr,
    String? fullNameEn,
    String? category,
    Value<String?> currentTeamId = const Value.absent(),
    Value<String?> housingId = const Value.absent(),
  }) => _updater.update(actor: actor, uid: employeeUid, nameAr: fullNameAr, nameEn: fullNameEn, category: category, teamId: currentTeamId);

  Future<void> archiveWorker({required ActorContext actor, required String employeeUid}) =>
      _updater.archive(actor: actor, uid: employeeUid);
}
