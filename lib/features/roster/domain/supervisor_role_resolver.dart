import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/features/roster/domain/workforce_row.dart';

/// Decides which imported rows are supervisors that need a login account.
///
/// The optional `Role` column wins; otherwise the `Designation` column is used
/// only when it explicitly mentions a supervisor. Only the two supervisor
/// roles are ever produced — administrators are never created from a file.
final class SupervisorRoleResolver {
  const SupervisorRoleResolver();

  static const _supervisorWords = ['supervisor', 'مشرف'];
  static const _campusWords = ['campus', 'housing', 'camp', 'سكن'];
  static const _siteWords = ['site', 'موقع'];

  AuthRole? resolve(WorkforceRow row) {
    final roleCell = row.role.trim().toLowerCase();
    if (roleCell.isNotEmpty) return _fromText(roleCell, explicit: true);
    return _fromText(row.designation.trim().toLowerCase(), explicit: false);
  }

  AuthRole? _fromText(String text, {required bool explicit}) {
    if (text.isEmpty) return null;
    final supervisor = _supervisorWords.any(text.contains);
    if (!explicit && !supervisor) return null;
    if (_campusWords.any(text.contains)) return AuthRole.housingSupervisor;
    if (supervisor || _siteWords.any(text.contains)) {
      return AuthRole.siteSupervisor;
    }
    return null;
  }
}
