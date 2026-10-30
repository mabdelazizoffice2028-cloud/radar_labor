import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

abstract final class ScopeDateGuard {
  static void guardLockout({
    required AuthRole role,
    required String date,
    required String todayBusinessDate,
    required DateTime? nowUtc,
    required int lockoutHour,
  }) {
    if (role == AuthRole.projectManager || role == AuthRole.hr) return;
    if (date != todayBusinessDate || nowUtc == null) return;
    if (nowUtc.toRiyadh().hour >= lockoutHour) {
      throw const OperationException(DayLockedOut());
    }
  }

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
      if (diffDays > maxBackdateDays) {
        throw const OperationException(DateOutOfWindow());
      }
      if (!capabilities.canEditPastDays) {
        throw const OperationException(PermissionDenied());
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
