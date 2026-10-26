import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/login/login_flow_notifier.dart';
import 'package:radar_labor/app/widgets/auth_login_form.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';

void main() {
  LocalAccount makeAccount({
    required String id,
    required String name,
    required AuthRole role,
    bool active = true,
  }) => LocalAccount(
    id: id,
    employeeUid: 'emp-$id',
    displayName: name,
    role: role,
    salt: 'salt',
    passwordHash: 'hash',
    mustChangePassword: false,
    active: active,
  );

  group('LoginFlowNotifier (PRD §23.2, D-20)', () {
    test('filters active accounts by role and sorts by NameCollation', () {
      final notifier = LoginFlowNotifier([
        makeAccount(id: 'sup-2', name: 'ياسر', role: AuthRole.siteSupervisor),
        makeAccount(id: 'sup-1', name: 'أحمد', role: AuthRole.siteSupervisor),
        makeAccount(
          id: 'sup-inactive',
          name: 'بدر',
          role: AuthRole.siteSupervisor,
          active: false,
        ),
        makeAccount(
          id: 'pm-1',
          name: 'المدير العام',
          role: AuthRole.projectManager,
        ),
      ]);

      notifier.selectRole(AuthRole.siteSupervisor);
      expect(notifier.state.showNameDropdown, isTrue);
      expect(notifier.state.accountsForRole.map((a) => a.id).toList(), [
        'sup-1',
        'sup-2',
      ]);
      expect(notifier.state.selectedAccountId, 'sup-1');

      // Single supervisor still shows dropdown per PRD §23.2
      final singleSup = LoginFlowNotifier([
        makeAccount(
          id: 'sup-only',
          name: 'خالد',
          role: AuthRole.housingSupervisor,
        ),
      ])..selectRole(AuthRole.housingSupervisor);
      expect(singleSup.state.showNameDropdown, isTrue);

      // Single projectManager auto-selects and hides dropdown
      notifier.selectRole(AuthRole.projectManager);
      expect(notifier.state.showNameDropdown, isFalse);
      expect(notifier.state.selectedAccountId, 'pm-1');

      // Role with no accounts
      notifier.selectRole(AuthRole.viewer);
      expect(notifier.state.accountsForRole, isEmpty);
      expect(notifier.state.selectedAccountId, isNull);
    });
  });

  group('LocalAuthRepository Part B requirements (BC-5, BC-6)', () {
    late AppDatabase db;
    late LocalAuthRepository auth;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      auth = LocalAuthRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'signIn rejects mismatched role and resetPassword restores temporary PIN',
      () async {
        await auth.createInitialAccounts(
          projectManagerEmployeeUid: 'emp-pm',
          hrEmployeeUid: 'emp-hr',
          projectManagerName: 'PM',
          hrName: 'HR',
        );
        // BC-6: siteSupervisor created without any initial team
        await auth.createAccount(
          employeeUid: 'emp-sup',
          displayName: 'Site Sup',
          role: AuthRole.siteSupervisor,
        );

        final accounts = await auth.accounts();
        final sup = accounts.firstWhere(
          (a) => a.role == AuthRole.siteSupervisor,
        );
        expect(sup.teamIds, isEmpty);

        // Mismatched role is rejected even with valid password (BC-5)
        final wrongRoleAttempt = await auth.signIn(
          role: AuthRole.projectManager,
          accountId: sup.id,
          password: AuthConstants.temporaryPassword,
        );
        expect(wrongRoleAttempt, isNull);

        // Matching role succeeds
        final validAttempt = await auth.signIn(
          role: AuthRole.siteSupervisor,
          accountId: sup.id,
          password: AuthConstants.temporaryPassword,
        );
        expect(validAttempt, isNotNull);

        // Change password, then lock account, then reset password
        await auth.changePassword(sup, 'new-secret-88');
        for (var i = 0; i < AuthConstants.maxFailedAttempts; i++) {
          await auth.signIn(
            role: AuthRole.siteSupervisor,
            accountId: sup.id,
            password: 'wrong-password',
          );
        }
        expect(
          await auth.signIn(
            role: AuthRole.siteSupervisor,
            accountId: sup.id,
            password: 'new-secret-88',
          ),
          isNull,
        );

        await auth.resetPassword(sup.id);
        final afterReset = await auth.signIn(
          role: AuthRole.siteSupervisor,
          accountId: sup.id,
          password: AuthConstants.temporaryPassword,
        );
        expect(afterReset, isNotNull);
        expect(afterReset!.mustChangePassword, isTrue);
      },
    );
  });

  group('AuthLoginForm widget (Role -> Name -> Password)', () {
    testWidgets(
      'renders role picker, then name/password step and submits role',
      (tester) async {
        final notifier = LoginFlowNotifier([
          makeAccount(
            id: 'pm-1',
            name: 'مدير المشروع',
            role: AuthRole.projectManager,
          ),
          makeAccount(
            id: 'sup-1',
            name: 'مشرف أ',
            role: AuthRole.siteSupervisor,
          ),
        ]);

        AuthRole? submittedRole;
        String? submittedAccountId;
        String? submittedPassword;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: StreamBuilder<LoginFlowState>(
                  stream: notifier.stream,
                  initialData: notifier.state,
                  builder: (context, snapshot) {
                    final state = snapshot.data ?? notifier.state;
                    return AuthLoginForm(
                      flowState: state,
                      onRoleSelected: notifier.selectRole,
                      onClearRole: notifier.clearRole,
                      onAccountChanged: notifier.selectAccount,
                      onSignIn: (role, accountId, password) async {
                        submittedRole = role;
                        submittedAccountId = accountId;
                        submittedPassword = password;
                      },
                      busy: false,
                      errorMessage: null,
                      arabic: true,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(
          find.byKey(const ValueKey('role_card_siteSupervisor')),
          findsOneWidget,
        );
        await tester.tap(
          find.byKey(const ValueKey('role_card_siteSupervisor')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('account_dropdown_siteSupervisor')),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const ValueKey('password_field')),
          '123456',
        );
        await tester.tap(find.byKey(const ValueKey('login_submit_button')));
        await tester.pump();

        expect(submittedRole, AuthRole.siteSupervisor);
        expect(submittedAccountId, 'sup-1');
        expect(submittedPassword, '123456');
      },
    );
  });
}
