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
}
