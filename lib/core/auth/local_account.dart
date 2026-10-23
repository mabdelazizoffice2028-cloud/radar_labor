import 'auth_role.dart';
import 'auth_session.dart';

final class LocalAccount {
  const LocalAccount({
    required this.id,
    required this.employeeUid,
    required this.displayName,
    required this.role,
    required this.salt,
    required this.passwordHash,
    required this.mustChangePassword,
    this.teamIds = const [],
    this.housingIds = const [],
    this.active = true,
  });

  final String id;
  final String employeeUid;
  final String displayName;
  final AuthRole role;
  final String salt;
  final String passwordHash;
  final bool mustChangePassword;
  final List<String> teamIds;
  final List<String> housingIds;
  final bool active;

  AuthSession toSession() => AuthSession(
    id: id,
    employeeUid: employeeUid,
    displayName: displayName,
    role: role,
    mustChangePassword: mustChangePassword,
    teamIds: teamIds,
    housingIds: housingIds,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'employeeUid': employeeUid,
    'displayName': displayName,
    'role': role.name,
    'salt': salt,
    'passwordHash': passwordHash,
    'mustChangePassword': mustChangePassword,
    'teamIds': teamIds,
    'housingIds': housingIds,
    'active': active,
  };

  factory LocalAccount.fromJson(Map<String, Object?> json) => LocalAccount(
    id: json['id']! as String,
    employeeUid: json['employeeUid']! as String,
    displayName: json['displayName']! as String,
    role: AuthRole.values.byName(json['role']! as String),
    salt: json['salt']! as String,
    passwordHash: json['passwordHash']! as String,
    mustChangePassword: json['mustChangePassword']! as bool,
    teamIds: List<String>.unmodifiable(json['teamIds']! as List<Object?>),
    housingIds: List<String>.unmodifiable(json['housingIds']! as List<Object?>),
    active: (json['active'] as bool?) ?? true,
  );
}
