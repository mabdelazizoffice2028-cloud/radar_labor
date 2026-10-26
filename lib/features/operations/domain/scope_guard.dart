import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

/// Pure domain authorization and business-date window guard (PRD §5.5).
abstract final class ScopeGuard {
  static void requireCapability(bool allowed) {
    if (!allowed) {
      throw const OperationException(PermissionDenied());
    }
  }

  /// Validates that [actor] can record site attendance for [teamId] on [date].
  static void guardSiteRecord({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
    required String date,
    required String todayBusinessDate,
    int maxBackdateDays = OperationsConstants.maxBackdateDays,
  }) {
    requireCapability(actor.capabilities.canRecordSite);
    if (!scope.allowsTeam(teamId)) {
      throw const OperationException(PermissionDenied());
    }
    guardDateWindow(
      date: date,
      todayBusinessDate: todayBusinessDate,
      capabilities: actor.capabilities,
      maxBackdateDays: maxBackdateDays,
    );
  }

  /// Validates that [actor] can record housing check for [housingId] on [date].
  static void guardHousingRecord({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String housingId,
    String? date,
    String? todayBusinessDate,
    int maxBackdateDays = OperationsConstants.maxBackdateDays,
  }) {
    requireCapability(actor.capabilities.canRecordHousing);
    if (!scope.allowsHousing(housingId)) {
      throw const OperationException(PermissionDenied());
    }
    if (date != null && todayBusinessDate != null) {
      guardDateWindow(
        date: date,
        todayBusinessDate: todayBusinessDate,
        capabilities: actor.capabilities,
        maxBackdateDays: maxBackdateDays,
      );
    }
  }

  /// Validates that [actor] can create a new team via the wizard (PRD §7.3).
  static void guardTeamSetup(ActorContext actor) {
    requireCapability(
      actor.capabilities.canSetupTeam && actor.role == AuthRole.siteSupervisor,
    );
  }

  /// Validates that [actor] can edit members of [teamId] (PRD §7.4).
  static void guardTeamEdit({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
  }) {
    requireCapability(actor.capabilities.canEditOwnTeamMembers);
    if (!scope.allowsTeam(teamId)) {
      throw const OperationException(PermissionDenied());
    }
  }

  /// Validates that [date] is not in the future and within [maxBackdateDays] of [todayBusinessDate].
  static void guardDateWindow({
    required String date,
    required String todayBusinessDate,
    required RoleCapabilities capabilities,
    int maxBackdateDays = OperationsConstants.maxBackdateDays,
  }) {
    final target = _parseIsoDate(date);
    final today = _parseIsoDate(todayBusinessDate);
    if (target == null || today == null) {
      throw const OperationException(DateOutOfWindow());
    }
    final diffDays = today.difference(target).inDays;
    if (diffDays < 0) {
      throw const OperationException(FutureDate());
    }
    if (diffDays > 0) {
      requireCapability(capabilities.canEditPastDays);
      if (diffDays > maxBackdateDays) {
        throw const OperationException(DateOutOfWindow());
      }
    }
  }

  static DateTime? _parseIsoDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final parsed = DateTime.utc(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }
}
