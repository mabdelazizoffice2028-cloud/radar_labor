import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

final class RosterAdminAccountHelper {
  const RosterAdminAccountHelper({
    required this.database,
    required this.audit,
    required this.auth,
  });

  final AppDatabase database;
  final AuditLogRepository audit;
  final LocalAuthRepository auth;

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
      await audit.record(userId: actor.userId, action: 'account_created', entityType: 'account', entityId: created.id);
      return created.id;
    });
  }

  Future<void> resetPasswordAudited({required ActorContext actor, required String accountId}) =>
      _auditAccount(actor, accountId, 'password_reset', auth.resetPassword);

  Future<void> deactivateAccountAudited({required ActorContext actor, required String accountId}) =>
      _auditAccount(actor, accountId, 'account_deactivated', auth.deactivateAccount);

  Future<void> _auditAccount(
    ActorContext a,
    String id,
    String action,
    Future<void> Function(String) fn,
  ) {
    _guard(a.capabilities.canManageAccounts);
    return database.transaction(() async {
      await fn(id);
      await audit.record(userId: a.userId, action: action, entityType: 'account', entityId: id);
    });
  }

  void _guard(bool ok) => ok ? null : throw const OperationException(PermissionDenied());
}
