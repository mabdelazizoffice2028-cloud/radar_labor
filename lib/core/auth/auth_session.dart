import 'package:radar_labor/core/auth/auth_role.dart';

/// Presentation-safe authenticated session representing the active user.
/// Contains zero cryptographic hashes, salts, or sensitive credential secrets.
final class AuthSession {
  const AuthSession({
    required this.id,
    this.employeeUid,
    required this.displayName,
    required this.role,
    this.mustChangePassword = false,
    this.teamIds = const [],
    this.housingIds = const [],
  });

  final String id;
  final String? employeeUid;
  final String displayName;
  final AuthRole role;
  final bool mustChangePassword;
  final List<String> teamIds;
  final List<String> housingIds;
}
