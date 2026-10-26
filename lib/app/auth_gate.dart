import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/login/login_flow_notifier.dart';
import 'package:radar_labor/app/widgets/auth_login_form.dart';
import 'package:radar_labor/app/widgets/auth_setup_view.dart';
import 'package:radar_labor/app/widgets/change_temporary_password_dialog.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/roster/data/workforce_file_picker.dart';
import 'package:radar_labor/features/roster/data/workforce_import_repository.dart';
import 'package:radar_labor/features/roster/domain/workforce_import_parser.dart';

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
  late final _importer = WorkforceImportRepository(widget.database);
  final _flowNotifier = LoginFlowNotifier();

  List<LocalAccount> _accounts = const [];
  List<Employee> _employees = const [];
  LocalAccount? _activeAccount;
  String _locale = 'en';
  String? _error;
  bool _loading = true;
  bool _busy = false;
  String? _selectedManagerUid;
  String? _selectedHrUid;

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
      final accounts = await _auth.accounts(activeOnly: true);
      final employees = await (widget.database.select(
        widget.database.employees,
      )..where((e) => e.isActive)).get();

      if (!mounted) return;
      _flowNotifier.setAccounts(accounts);
      setState(() {
        _locale = locale ?? 'en';
        _accounts = accounts;
        _employees = employees;
        _selectedManagerUid = employees.firstOrNull?.employeeUid;
        _selectedHrUid = employees.skip(1).firstOrNull?.employeeUid;
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

  void _logout() {
    _flowNotifier.clearRole();
    setState(() => _activeAccount = null);
    _load();
  }

  Future<void> _pickRoster() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await WorkforceFilePicker().pick();
      if (file == null || !mounted) return;
      final rows = const WorkforceImportParser().parse(
        filename: file.name,
        bytes: file.bytes,
      );
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_arabic ? 'معاينة الاستيراد' : 'Review import'),
          content: Text(
            _arabic
                ? 'سيتم استيراد ${rows.length} عاملاً وتجاهل أرقام الهويات بالكامل.'
                : '${rows.length} workers will be imported. Identity numbers will be discarded.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.cancel(_arabic)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(_arabic ? 'استيراد' : 'Import'),
            ),
          ],
        ),
      );
      if (accepted != true) return;
      await _importer.commit(rows);
      await _load();
    } on Object catch (_) {
      if (mounted) {
        setState(
          () => _error = _arabic
              ? 'تعذر استيراد الملف'
              : 'Could not import workforce file',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createAdmins() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final manager = _employees.firstWhere(
        (e) => e.employeeUid == _selectedManagerUid,
      );
      final hr = _employees.firstWhere((e) => e.employeeUid == _selectedHrUid);
      await _auth.createInitialAccounts(
        projectManagerEmployeeUid: manager.employeeUid,
        hrEmployeeUid: hr.employeeUid,
        projectManagerName: _arabic
            ? manager.fullNameAr
            : (manager.fullNameEn ?? manager.fullNameAr),
        hrName: _arabic ? hr.fullNameAr : (hr.fullNameEn ?? hr.fullNameAr),
      );
      await _load();
    } on Object catch (_) {
      if (mounted) {
        setState(
          () => _error = _arabic
              ? 'تعذر إنشاء الحسابين'
              : 'Could not create initial accounts',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
                  : _accounts.isEmpty
                  ? AuthSetupView(
                      employees: _employees,
                      selectedManagerUid: _selectedManagerUid,
                      selectedHrUid: _selectedHrUid,
                      onManagerChanged: (v) =>
                          setState(() => _selectedManagerUid = v),
                      onHrChanged: (v) => setState(() => _selectedHrUid = v),
                      onPickRoster: _pickRoster,
                      onCreateAdmins: _createAdmins,
                      busy: _busy,
                      errorMessage: _error,
                      arabic: _arabic,
                    )
                  : StreamBuilder<LoginFlowState>(
                      stream: _flowNotifier.stream,
                      initialData: _flowNotifier.state,
                      builder: (context, snapshot) => AuthLoginForm(
                        flowState: snapshot.data ?? _flowNotifier.state,
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
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
