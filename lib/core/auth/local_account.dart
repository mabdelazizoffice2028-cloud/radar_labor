import 'auth_role.dart';

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
  );
}
