import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:uuid/uuid.dart';

const _accountsKey = 'local_accounts_v1';
const _initialPassword = '123456';

final class AuthConflictException implements Exception {
  const AuthConflictException();
}

/// Stores account credentials only in the encrypted local application database.
final class LocalAuthRepository {
  LocalAuthRepository(this._settings);

  final LocalSettingsRepository _settings;
  static final _argon2id = Argon2id(
    parallelism: 1,
    memory: 19456,
    iterations: 2,
    hashLength: 32,
  );

  Future<List<LocalAccount>> accounts() async {
    final raw = await _settings.read(_accountsKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<Object?>;
    return List.unmodifiable(
      decoded.map(
        (entry) => LocalAccount.fromJson(entry! as Map<String, Object?>),
      ),
    );
  }

  Future<void> createInitialAccounts({
    required String projectManagerEmployeeUid,
    required String hrEmployeeUid,
    required String projectManagerName,
    required String hrName,
  }) async {
    final existing = await accounts();
    if (existing.isNotEmpty) throw const AuthConflictException();
    final created = [
      await _newAccount(
        employeeUid: projectManagerEmployeeUid,
        displayName: projectManagerName,
        role: AuthRole.projectManager,
      ),
      await _newAccount(
        employeeUid: hrEmployeeUid,
        displayName: hrName,
        role: AuthRole.hr,
      ),
    ];
    await _write(created);
  }

  Future<void> createAccount({
    required String employeeUid,
    required String displayName,
    required AuthRole role,
    List<String> teamIds = const [],
    List<String> housingIds = const [],
  }) async {
    final existing = await accounts();
    if (existing.any(
      (account) => account.employeeUid == employeeUid && account.role == role,
    )) {
      throw const AuthConflictException();
    }
    final account = await _newAccount(
      employeeUid: employeeUid,
      displayName: displayName,
      role: role,
      teamIds: teamIds,
      housingIds: housingIds,
    );
    await _write([...existing, account]);
  }

  Future<LocalAccount?> signIn({
    required AuthRole role,
    required String accountId,
    required String password,
  }) async {
    final account = (await accounts())
        .where((item) => item.id == accountId && item.role == role)
        .firstOrNull;
    if (account == null) return null;
    final candidate = await _hash(password, base64Url.decode(account.salt));
    if (!_constantTimeEquals(
      candidate,
      base64Url.decode(account.passwordHash),
    )) {
      return null;
    }
    return account;
  }

  Future<void> changePassword(LocalAccount account, String password) async {
    if (password.trim().length < 8) {
      throw ArgumentError('Password must contain at least 8 characters');
    }
    final salt = _randomBytes(16);
    final hash = await _hash(password, salt);
    final rows = (await accounts()).map((item) {
      if (item.id != account.id) return item;
      return LocalAccount(
        id: item.id,
        employeeUid: item.employeeUid,
        displayName: item.displayName,
        role: item.role,
        salt: base64UrlEncode(salt),
        passwordHash: base64UrlEncode(hash),
        mustChangePassword: false,
        teamIds: item.teamIds,
        housingIds: item.housingIds,
      );
    }).toList();
    await _write(rows);
  }

  Future<LocalAccount> _newAccount({
    required String employeeUid,
    required String displayName,
    required AuthRole role,
    List<String> teamIds = const [],
    List<String> housingIds = const [],
  }) async {
    final salt = _randomBytes(16);
    return LocalAccount(
      id: const Uuid().v4(),
      employeeUid: employeeUid,
      displayName: displayName,
      role: role,
      salt: base64UrlEncode(salt),
      passwordHash: base64UrlEncode(await _hash(_initialPassword, salt)),
      mustChangePassword: true,
      teamIds: List.unmodifiable(teamIds),
      housingIds: List.unmodifiable(housingIds),
    );
  }

  Future<List<int>> _hash(String password, List<int> salt) => Isolate.run(
    () async => (await _argon2id.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    )).extractBytes(),
  );

  Future<void> _write(List<LocalAccount> accounts) => _settings.write(
    _accountsKey,
    jsonEncode(accounts.map((account) => account.toJson()).toList()),
  );

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }
}
