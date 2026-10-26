import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/login/login_flow_notifier.dart';
import 'package:radar_labor/app/widgets/auth_login_form.dart';
import 'package:radar_labor/app/widgets/change_temporary_password_dialog.dart';
import 'package:radar_labor/app/widgets/pin_login_form.dart';
import 'package:radar_labor/core/auth/account_provisioning_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

typedef AuthenticatedBuilder = Widget Function(
  LocalAccount account,
  VoidCallback onLogout,
);

/// Forces local authentication before rendering any application feature.
final class AuthGate extends StatefulWidget {
  const AuthGate({required this.database, required this.builder, super.key});

  final AppDatabase database;
  final AuthenticatedBuilder builder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

final class _AuthGateState extends State<AuthGate> {
  late final _auth = LocalAuthRepository(widget.database);
  late final _provisioning = AccountProvisioningRepository(
    widget.database,
    _auth,
  );
  final _flowNotifier = LoginFlowNotifier();

  LocalAccount? _activeAccount;
  String _locale = 'en';
  String? _error;
  bool _loading = true;
  bool _busy = false;

  bool get _arabic => _locale == 'ar';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _flowNotifier.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final settings = LocalSettingsRepository(widget.database);
      final locale = await settings.read('locale');
      final rememberedId = await settings.read(
        AppSettingKeys.lastLoggedInAccountId,
      );
      // Project manager and HR can always sign in, even on an empty database.
      await _provisioning.ensureAdminAccounts();
      final accounts = await _auth.accounts(activeOnly: true);

      if (!mounted) return;
      _flowNotifier.setAccounts(accounts, rememberedAccountId: rememberedId);
      setState(() {
        _locale = locale ?? 'en';
        _loading = false;
        _error = null;
      });
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _signIn(AuthRole role, String accountId, String password) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final account = await _auth.signIn(
        role: role,
        accountId: accountId,
        password: password,
      );
      if (account == null) {
        if (mounted) {
          setState(
            () => _error = AuthFlowStrings.invalidCredentialsOrLocked(_arabic),
          );
        }
        return;
      }
      if (account.mustChangePassword) {
        if (!mounted) return;
        final replacement = await ChangeTemporaryPasswordDialog.show(
          context,
          arabic: _arabic,
        );
        if (replacement == null) return;
        await _auth.changePassword(account, replacement);
        _activeAccount = (await _auth.accounts()).firstWhere(
          (a) => a.id == account.id,
        );
      } else {
        _activeAccount = account;
      }
      final settings = LocalSettingsRepository(widget.database);
      await settings.write(
        AppSettingKeys.lastLoggedInAccountId,
        _activeAccount!.id,
      );
      if (mounted) setState(() => _error = null);
    } on AccountLockedException catch (_) {
      if (mounted) setState(() => _error = AppStrings.accountLocked(_arabic));
    } on AccountDeactivatedException catch (_) {
      if (mounted) setState(() => _error = AppStrings.accountDisabled(_arabic));
    } on Object catch (_) {
      if (mounted) {
        setState(() => _error = AuthFlowStrings.signInFailed(_arabic));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _switchAccount() async {
    final settings = LocalSettingsRepository(widget.database);
    await settings.delete(AppSettingKeys.lastLoggedInAccountId);
    _flowNotifier.switchAccount();
    if (mounted) setState(() => _error = null);
  }

  void _logout() {
    _flowNotifier.clearRole();
    setState(() => _activeAccount = null);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeAccount != null) {
      return widget.builder(_activeAccount!, _logout);
    }
    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: Text(AppStrings.appTitle(_arabic)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radius12),
              ),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(AppTokens.space32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : StreamBuilder<LoginFlowState>(
                      stream: _flowNotifier.stream,
                      initialData: _flowNotifier.state,
                      builder: (context, snapshot) {
                        final state = snapshot.data ?? _flowNotifier.state;
                        final remembered = state.rememberedAccount;
                        if (state.isRememberedMode && remembered != null) {
                          return PinLoginForm(
                            account: remembered,
                            onSignIn: (password) => _signIn(
                              remembered.role,
                              remembered.id,
                              password,
                            ),
                            onSwitchAccount: _switchAccount,
                            busy: _busy,
                            errorMessage: _error,
                            arabic: _arabic,
                          );
                        }
                        return AuthLoginForm(
                          flowState: state,
                          onRoleSelected: (role) {
                            setState(() => _error = null);
                            _flowNotifier.selectRole(role);
                          },
                          onClearRole: () {
                            setState(() => _error = null);
                            _flowNotifier.clearRole();
                          },
                          onAccountChanged: (id) {
                            setState(() => _error = null);
                            _flowNotifier.selectAccount(id);
                          },
                          onSignIn: _signIn,
                          busy: _busy,
                          errorMessage: _error,
                          arabic: _arabic,
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
