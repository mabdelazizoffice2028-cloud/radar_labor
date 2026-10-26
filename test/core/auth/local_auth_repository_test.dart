import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';

void main() {
  late AppDatabase database;
  late LocalAuthRepository auth;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    auth = LocalAuthRepository(LocalSettingsRepository(database));
  });

  tearDown(() => database.close());

  test('initialAccounts_useTemporaryPasswordAndRequireChange', () async {
    await auth.createInitialAccounts(
      projectManagerEmployeeUid: 'employee-1',
      hrEmployeeUid: 'employee-2',
      projectManagerName: 'Manager',
      hrName: 'HR',
    );
    final accounts = await auth.accounts();
    final manager = accounts.firstWhere(
      (account) => account.role == AuthRole.projectManager,
    );

    expect(manager.mustChangePassword, isTrue);
    expect(
      await auth.signIn(
        role: manager.role,
        accountId: manager.id,
        password: '123456',
      ),
      isNotNull,
    );
    expect(
      await auth.signIn(
        role: manager.role,
        accountId: manager.id,
        password: 'wrong',
      ),
      isNull,
    );

    await auth.changePassword(manager, 'long-password-1');
    final changed = (await auth.accounts()).firstWhere(
      (item) => item.id == manager.id,
    );
    expect(changed.mustChangePassword, isFalse);
    expect(
      await auth.signIn(
        role: manager.role,
        accountId: manager.id,
        password: '123456',
      ),
      isNull,
    );
    expect(
      await auth.signIn(
        role: manager.role,
        accountId: manager.id,
        password: 'long-password-1',
      ),
      isNotNull,
    );
  });

  test('signIn_withoutRole_succeedsDirectlyWithAccountId', () async {
    await auth.createInitialAccounts(
      projectManagerEmployeeUid: 'emp-1',
      hrEmployeeUid: 'emp-2',
      projectManagerName: 'Manager',
      hrName: 'HR',
    );
    final accounts = await auth.accounts();
    final hr = accounts.firstWhere((a) => a.role == AuthRole.hr);

    final signedIn = await auth.signIn(accountId: hr.id, password: '123456');
    expect(signedIn, isNotNull);
    expect(signedIn!.displayName, equals('HR'));
    expect(signedIn.role, equals(AuthRole.hr));
  });

  test('changePassword_rejectsTemporaryPasswordAndSamePassword', () async {
    await auth.createInitialAccounts(
      projectManagerEmployeeUid: 'emp-1',
      hrEmployeeUid: 'emp-2',
      projectManagerName: 'Manager',
      hrName: 'HR',
    );
    final manager = (await auth.accounts()).first;

    expect(
      () => auth.changePassword(manager, '123456'),
      throwsA(isA<ArgumentError>()),
    );

    expect(
      () => auth.changePassword(manager, 'short'),
      throwsA(isA<ArgumentError>()),
    );

    expect(
      () => auth.changePassword(
        manager,
        'new-password-123',
        currentPassword: 'wrong-current',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('failedAttempts_triggersLockoutAfterMaxAttempts', () async {
    await auth.createInitialAccounts(
      projectManagerEmployeeUid: 'emp-1',
      hrEmployeeUid: 'emp-2',
      projectManagerName: 'Manager',
      hrName: 'HR',
    );
    final manager = (await auth.accounts()).first;

    for (var i = 0; i < 4; i++) {
      final res = await auth.signIn(accountId: manager.id, password: 'bad');
      expect(res, isNull);
    }

    // 5th failed attempt locks out the account
    final fifth = await auth.signIn(accountId: manager.id, password: 'bad');
    expect(fifth, isNull);

    // Now even correct password fails while locked out
    final lockedAttempt = await auth.signIn(
      accountId: manager.id,
      password: '123456',
    );
    expect(lockedAttempt, isNull);
  });

  test('deactivateAccount_preventsSignIn', () async {
    await auth.createInitialAccounts(
      projectManagerEmployeeUid: 'emp-1',
      hrEmployeeUid: 'emp-2',
      projectManagerName: 'Manager',
      hrName: 'HR',
    );
    final manager = (await auth.accounts()).first;

    await auth.deactivateAccount(manager.id);

    expect(
      () => auth.signIn(accountId: manager.id, password: '123456'),
      throwsA(isA<AccountDeactivatedException>()),
    );

    final activeAccounts = await auth.accounts(activeOnly: true);
    expect(activeAccounts.any((a) => a.id == manager.id), isFalse);
  });

  test('updateScopes_correctlyStoresAndReturnsAssignedScopes', () async {
    await auth.createInitialAccounts(
      projectManagerEmployeeUid: 'emp-1',
      hrEmployeeUid: 'emp-2',
      projectManagerName: 'Manager',
      hrName: 'HR',
    );
    final hr = (await auth.accounts()).firstWhere((a) => a.role == AuthRole.hr);

    await auth.updateScopes(
      hr.id,
      teamIds: ['team-alpha', 'team-beta'],
      housingIds: ['housing-1'],
    );

    final updated = (await auth.accounts()).firstWhere((a) => a.id == hr.id);
    expect(updated.teamIds, containsAll(['team-alpha', 'team-beta']));
    expect(updated.housingIds, contains('housing-1'));
  });
}
