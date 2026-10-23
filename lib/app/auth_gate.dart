import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/auth_login_form.dart';
import 'package:radar_labor/app/widgets/auth_setup_view.dart';
import 'package:radar_labor/app/widgets/change_temporary_password_dialog.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
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

  List<LocalAccount> _accounts = const [];
  List<Employee> _employees = const [];
  LocalAccount? _activeAccount;
  String _locale = 'en';
  String? _error;
  bool _loading = true;
  bool _busy = false;

  String? _selectedAccountId;
  String? _selectedManagerUid;
  String? _selectedHrUid;

  bool get _arabic => _locale == 'ar';

  @override
  void initState() {
    super.initState();
    _load();
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
      setState(() {
        _locale = locale ?? 'en';
        _accounts = accounts;
        _employees = employees;
        _selectedAccountId = accounts.firstOrNull?.id;
        _selectedManagerUid = employees.firstOrNull?.employeeUid;
        _selectedHrUid = employees.skip(1).firstOrNull?.employeeUid;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _signIn(String accountId, String password) async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final account = await _auth.signIn(
        accountId: accountId,
        password: password,
      );

      if (account == null) {
        if (!mounted) return;
        setState(() {
          _error = _arabic
              ? 'كلمة المرور غير صحيحة أو الحساب مقفل مؤقتاً'
              : 'Incorrect password or account temporarily locked';
        });
        return;
      }

      if (account.mustChangePassword) {
        final replacement = await _showChangeTemporaryPasswordDialog();
        if (replacement == null) {
          setState(() => _busy = false);
          return;
        }
        await _auth.changePassword(account, replacement);
        _activeAccount = LocalAccount(
          id: account.id,
          employeeUid: account.employeeUid,
          displayName: account.displayName,
          role: account.role,
          salt: account.salt,
          passwordHash: account.passwordHash,
          mustChangePassword: false,
          teamIds: account.teamIds,
          housingIds: account.housingIds,
          active: account.active,
        );
      } else {
        _activeAccount = account;
      }

      if (mounted) {
        setState(() {
          _error = null;
          _busy = false;
        });
      }
    } on AccountLockedException catch (_) {
      if (mounted) {
        setState(() => _error = AppStrings.accountLocked(_arabic));
      }
    } on AccountDeactivatedException catch (_) {
      if (mounted) {
        setState(() => _error = AppStrings.accountDisabled(_arabic));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = _arabic
              ? 'تعذر تسجيل الدخول، أعد المحاولة'
              : 'Could not sign in. Please retry.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _showChangeTemporaryPasswordDialog() =>
      ChangeTemporaryPasswordDialog.show(context, arabic: _arabic);

  void _logout() {
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
      if (file == null) return;
      if (!mounted) return;
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
    } catch (_) {
      if (mounted) {
        setState(() => _error = _arabic ? 'تعذر استيراد الملف' : 'Could not import workforce file');
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
      final manager = _employees.firstWhere((e) => e.employeeUid == _selectedManagerUid);
      final hr = _employees.firstWhere((e) => e.employeeUid == _selectedHrUid);
      await _auth.createInitialAccounts(
        projectManagerEmployeeUid: manager.employeeUid,
        hrEmployeeUid: hr.employeeUid,
        projectManagerName: _arabic ? manager.fullNameAr : (manager.fullNameEn ?? manager.fullNameAr),
        hrName: _arabic ? hr.fullNameAr : (hr.fullNameEn ?? hr.fullNameAr),
      );
      await _load();
    } catch (_) {
      if (mounted) {
        setState(() => _error = _arabic ? 'تعذر إنشاء الحسابين' : 'Could not create initial accounts');
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
                      onManagerChanged: (v) => setState(() => _selectedManagerUid = v),
                      onHrChanged: (v) => setState(() => _selectedHrUid = v),
                      onPickRoster: _pickRoster,
                      onCreateAdmins: _createAdmins,
                      busy: _busy,
                      errorMessage: _error,
                      arabic: _arabic,
                    )
                  : AuthLoginForm(
                      accounts: _accounts,
                      selectedAccountId: _selectedAccountId,
                      onAccountChanged: (v) => setState(() => _selectedAccountId = v),
                      onSignIn: _signIn,
                      busy: _busy,
                      errorMessage: _error,
                      arabic: _arabic,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
