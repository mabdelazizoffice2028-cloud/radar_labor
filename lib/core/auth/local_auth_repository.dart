import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_account_mutator.dart';
import 'package:radar_labor/core/auth/local_auth_account_reader.dart';
import 'package:radar_labor/core/auth/local_auth_password_service.dart';
import 'package:radar_labor/core/auth/local_auth_signer.dart';
import 'package:radar_labor/core/auth/password_hasher.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/time/clock.dart';

export 'auth_exceptions.dart';

final class LocalAuthRepository {
  LocalAuthRepository(
    Object dbOrSettings, [
    Clock clock = const SystemClock(),
    PasswordHasher hasher = const PasswordHasher(),
  ]) : this._(
          dbOrSettings is AppDatabase
              ? dbOrSettings
              : (dbOrSettings as LocalSettingsRepository).database,
          clock,
          hasher,
        );

  LocalAuthRepository._(AppDatabase db, Clock clock, PasswordHasher hasher)
      : _reader = LocalAuthAccountReader(db),
        _passwords = LocalAuthPasswordService(db, hasher),
        _signer = LocalAuthSigner(
          db,
          clock,
          LocalAuthPasswordService(db, hasher),
          LocalAuthAccountReader(db),
        ),
        _mutator = LocalAuthAccountMutator(
          db,
          clock,
          LocalAuthPasswordService(db, hasher),
          LocalAuthAccountReader(db),
        );

  final LocalAuthAccountReader _reader;
  final LocalAuthPasswordService _passwords;
  final LocalAuthSigner _signer;
  final LocalAuthAccountMutator _mutator;

  Stream<ScopeSnapshot> watchScopes(String id) => _reader.watchScopes(id);
  Future<List<LocalAccount>> accounts({bool activeOnly = false}) => _reader.accounts(activeOnly: activeOnly);
  Future<LocalAccount?> signIn({AuthRole? role, required String accountId, required String password}) =>
      _signer.signIn(role: role, accountId: accountId, password: password);
  Future<void> changePassword(LocalAccount acc, String newPw, {String? currentPassword}) =>
      _passwords.changePassword(acc, newPw, currentPassword: currentPassword);
  Future<void> resetPassword(String accountId) => _passwords.resetPassword(accountId);
  Future<void> deactivateAccount(String id) => _mutator.deactivateAccount(id);
  Future<bool> ensureAccountForRole(AuthRole role, String name) => _mutator.ensureAccountForRole(role, name);
  Future<void> updateScopes(String id, {required List<String> teamIds, required List<String> housingIds}) =>
      _mutator.updateScopes(id, teamIds: teamIds, housingIds: housingIds);
  Future<void> createInitialAccounts({
    required String projectManagerEmployeeUid, required String hrEmployeeUid,
    required String projectManagerName, required String hrName,
  }) => _mutator.createInitialAccounts(
        projectManagerEmployeeUid: projectManagerEmployeeUid, hrEmployeeUid: hrEmployeeUid,
        projectManagerName: projectManagerName, hrName: hrName,
      );
  Future<String> createAccount({
    String? employeeUid, required String displayName, required AuthRole role,
    List<String> teamIds = const [], List<String> housingIds = const [],
  }) => _mutator.createAccount(
        employeeUid: employeeUid, displayName: displayName, role: role,
        teamIds: teamIds, housingIds: housingIds,
      );
}
