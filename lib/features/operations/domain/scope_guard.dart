import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/scope_date_guard.dart';

export 'package:radar_labor/features/operations/domain/scope_date_guard.dart';

abstract final class ScopeGuard {
  static void requireCapability(bool allowed) {
    if (!allowed) throw const OperationException(PermissionDenied());
  }

  static void guardSiteRecord({
    required ActorContext actor, required ScopeSnapshot scope, required String teamId,
    required String date, required String todayBusinessDate, DateTime? nowUtc,
    int lockoutHour = 23, int maxBackdateDays = OperationsConstants.maxBackdateDays,
  }) {
    requireCapability(actor.capabilities.canRecordSite);
    if (!scope.allowsTeam(teamId)) throw const OperationException(PermissionDenied());
    ScopeDateGuard.guardLockout(
      role: actor.role, date: date, todayBusinessDate: todayBusinessDate,
      nowUtc: nowUtc, lockoutHour: lockoutHour,
    );
    ScopeDateGuard.guardDateWindow(
      date: date, todayBusinessDate: todayBusinessDate,
      capabilities: actor.capabilities, maxBackdateDays: maxBackdateDays,
    );
  }

  static void guardHousingRecord({
    required ActorContext actor, required ScopeSnapshot scope, required String housingId,
    String? date, String? todayBusinessDate, DateTime? nowUtc,
    int lockoutHour = 20, int maxBackdateDays = OperationsConstants.maxBackdateDays,
  }) {
    requireCapability(actor.capabilities.canRecordHousing);
    if (!scope.allowsHousing(housingId)) throw const OperationException(PermissionDenied());
    if (date != null && todayBusinessDate != null) {
      ScopeDateGuard.guardLockout(
        role: actor.role, date: date, todayBusinessDate: todayBusinessDate,
        nowUtc: nowUtc, lockoutHour: lockoutHour,
      );
      ScopeDateGuard.guardDateWindow(
        date: date, todayBusinessDate: todayBusinessDate,
        capabilities: actor.capabilities, maxBackdateDays: maxBackdateDays,
      );
    }
  }

  static void guardTeamSetup(ActorContext actor) =>
      requireCapability(actor.capabilities.canSetupTeam && actor.role == AuthRole.siteSupervisor);

  static void guardTeamEdit({
    required ActorContext actor, required ScopeSnapshot scope, required String teamId,
  }) {
    requireCapability(actor.capabilities.canEditOwnTeamMembers);
    if (!scope.allowsTeam(teamId)) throw const OperationException(PermissionDenied());
  }

  static void guardDateWindow({
    required String date, required String todayBusinessDate,
    required RoleCapabilities capabilities, int maxBackdateDays = OperationsConstants.maxBackdateDays,
  }) => ScopeDateGuard.guardDateWindow(
    date: date, todayBusinessDate: todayBusinessDate,
    capabilities: capabilities, maxBackdateDays: maxBackdateDays,
  );
}
