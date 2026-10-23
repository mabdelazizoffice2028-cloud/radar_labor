import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
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
  late final _auth = LocalAuthRepository(
    LocalSettingsRepository(widget.database),
  );
  late final _importer = WorkforceImportRepository(widget.database);
  List<LocalAccount> _accounts = const [];
  List<Employee> _employees = const [];
  LocalAccount? _activeAccount;
  String _locale = 'en';
  String? _error;
  bool _loading = true;
  bool _busy = false;
  int _failedAttempts = 0;
  AuthRole? _selectedRole;
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
    try {
      final settings = LocalSettingsRepository(widget.database);
      final locale = await settings.read('locale');
      final accounts = await _auth.accounts();
      final employees = await (widget.database.select(
        widget.database.employees,
      )..where((employee) => employee.isActive)).get();
      if (!mounted) return;
      setState(() {
        _locale = locale ?? 'en';
        _accounts = accounts;
        _employees = employees;
        _selectedRole ??= accounts.firstOrNull?.role;
        _selectedAccountId ??= accounts.firstOrNull?.id;
        _selectedManagerUid ??= employees.firstOrNull?.employeeUid;
        _selectedHrUid ??= employees.skip(1).firstOrNull?.employeeUid;
        _loading = false;
      });
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeAccount != null) return widget.builder(_activeAccount!, _logout);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1d4ed8)),
        scaffoldBackgroundColor: const Color(0xfff3f7fe),
      ),
      home: Directionality(
        textDirection: _arabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(title: Text(_t('رادار ليبور', 'Radar Labor'))),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _loading
                  ? const CircularProgressIndicator()
                  : _error != null
                  ? _failure()
                  : _accounts.isEmpty
                  ? _initialSetup()
                  : _login(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _failure() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_t('تعذر فتح الحسابات المحلية', 'Could not open local accounts')),
        Text(_error ?? ''),
        FilledButton(
          onPressed: _load,
          child: Text(_t('إعادة المحاولة', 'Retry')),
        ),
      ],
    ),
  );

  Widget _initialSetup() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.people_alt_outlined, size: 54),
        Text(
          _t('إعداد التطبيق', 'Set up Radar Labor'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          _t(
            'ابدأ باستيراد ملف القوى. لن يُحفظ رقم الهوية.',
            'Import the workforce list. Identity numbers are discarded.',
          ),
        ),
        const SizedBox(height: 16),
        if (_employees.isEmpty)
          FilledButton.icon(
            onPressed: _busy ? null : _pickRoster,
            icon: const Icon(Icons.upload_file),
            label: Text(
              _t('اختيار ملف Excel أو CSV', 'Choose Excel or CSV file'),
            ),
          )
        else ...[
          DropdownButtonFormField<String>(
            initialValue: _selectedManagerUid,
            decoration: InputDecoration(
              labelText: _t('مدير المشروع', 'Project manager'),
            ),
            items: _employees
                .map(
                  (e) => DropdownMenuItem(
                    value: e.employeeUid,
                    child: Text(_name(e)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedManagerUid = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedHrUid,
            decoration: InputDecoration(
              labelText: _t('مسؤول HR', 'HR administrator'),
            ),
            items: _employees
                .map(
                  (e) => DropdownMenuItem(
                    value: e.employeeUid,
                    child: Text(_name(e)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedHrUid = value),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed:
                _busy ||
                    _selectedManagerUid == null ||
                    _selectedHrUid == null ||
                    _selectedManagerUid == _selectedHrUid
                ? null
                : _createAdmins,
            child: Text(
              _t('إنشاء حسابي الإدارة', 'Create administrator accounts'),
            ),
          ),
        ],
        if (_busy)
          const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
      ],
    ),
  );

  Widget _login() {
    final availableRoles = AuthRole.values
        .where((role) => _accounts.any((account) => account.role == role))
        .toList();
    final people = _accounts
        .where((account) => account.role == _selectedRole)
        .toList();
    return _LoginForm(
      arabic: _arabic,
      roles: availableRoles,
      accounts: people,
      selectedRole: _selectedRole,
      selectedAccountId: _selectedAccountId,
      locked: _failedAttempts >= 5,
      onRole: (role) => setState(() {
        _selectedRole = role;
        _selectedAccountId = _accounts.firstWhere((a) => a.role == role).id;
      }),
      onAccount: (id) => setState(() => _selectedAccountId = id),
      onSubmit: _signIn,
      onError: _error,
    );
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
          title: Text(_t('معاينة الاستيراد', 'Review import')),
          content: Text(
            _t(
              'سيتم استيراد ${rows.length} عاملًا. سيتم تجاهل رقم الهوية بالكامل.',
              '${rows.length} workers will be imported. Identity numbers will be discarded.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_t('إلغاء', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(_t('استيراد', 'Import')),
            ),
          ],
        ),
      );
      if (accepted != true) return;
      await _importer.commit(rows);
      await _load();
    } on Exception catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
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
        projectManagerName: _name(manager),
        hrName: _name(hr),
      );
      await _load();
    } on Exception catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signIn() async {
    if (_failedAttempts >= 5 ||
        _selectedRole == null ||
        _selectedAccountId == null) {
      return;
    }
    final password = await _passwordDialog(firstLogin: false);
    if (password == null) return;
    setState(() => _busy = true);
    try {
      final account = await _auth.signIn(
        role: _selectedRole!,
        accountId: _selectedAccountId!,
        password: password,
      );
      if (account == null) {
        setState(() {
          _failedAttempts++;
          _error = _t('كلمة المرور غير صحيحة', 'Incorrect password');
        });
        return;
      }
      if (account.mustChangePassword) {
        final replacement = await _passwordDialog(firstLogin: true);
        if (replacement == null) return;
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
        );
      } else {
        _activeAccount = account;
      }
      if (mounted) {
        setState(() {
          _failedAttempts = 0;
          _error = null;
        });
      }
    } on Exception catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _logout() => setState(() => _activeAccount = null);

  Future<String?> _passwordDialog({required bool firstLogin}) async {
    final controller = TextEditingController();
    final confirmation = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: !firstLogin,
      builder: (context) => AlertDialog(
        title: Text(
          firstLogin
              ? _t('تغيير كلمة المرور المؤقتة', 'Change temporary password')
              : _t('تسجيل الدخول', 'Sign in'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: _t('كلمة المرور', 'Password'),
              ),
            ),
            if (firstLogin)
              TextField(
                controller: confirmation,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _t('تأكيد كلمة المرور', 'Confirm password'),
                ),
              ),
          ],
        ),
        actions: [
          if (!firstLogin)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t('إلغاء', 'Cancel')),
            ),
          FilledButton(
            onPressed: () {
              if (firstLogin &&
                  (controller.text.length < 8 ||
                      controller.text != confirmation.text)) {
                return;
              }
              if (!firstLogin && controller.text.isEmpty) return;
              Navigator.pop(context, controller.text);
            },
            child: Text(_t('متابعة', 'Continue')),
          ),
        ],
      ),
    );
  }

  String _name(Employee employee) => _arabic
      ? employee.fullNameAr
      : (employee.fullNameEn ?? employee.fullNameAr);
  String _friendlyError(Exception error) => error is FormatException
      ? _t(
          'تنسيق الملف غير صحيح أو يحتوي على تكرار.',
          'The file format is invalid or contains duplicates.',
        )
      : _t(
          'تعذر إكمال العملية. أعد المحاولة.',
          'Could not complete the operation. Please retry.',
        );
  String _t(String arabic, String english) => _arabic ? arabic : english;
}

final class _LoginForm extends StatefulWidget {
  const _LoginForm({
    required this.arabic,
    required this.roles,
    required this.accounts,
    required this.selectedRole,
    required this.selectedAccountId,
    required this.locked,
    required this.onRole,
    required this.onAccount,
    required this.onSubmit,
    required this.onError,
  });
  final bool arabic, locked;
  final List<AuthRole> roles;
  final List<LocalAccount> accounts;
  final AuthRole? selectedRole;
  final String? selectedAccountId;
  final ValueChanged<AuthRole?> onRole;
  final ValueChanged<String?> onAccount;
  final VoidCallback onSubmit;
  final String? onError;
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

final class _LoginFormState extends State<_LoginForm> {
  String _t(String ar, String en) => widget.arabic ? ar : en;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_outline, size: 54),
        Text(
          _t('تسجيل الدخول', 'Sign in'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        DropdownButtonFormField<AuthRole>(
          initialValue: widget.selectedRole,
          decoration: InputDecoration(labelText: _t('الدور', 'Role')),
          items: widget.roles
              .map(
                (role) => DropdownMenuItem(
                  value: role,
                  child: Text(role.label(arabic: widget.arabic)),
                ),
              )
              .toList(),
          onChanged: widget.onRole,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue:
              widget.accounts.any(
                (account) => account.id == widget.selectedAccountId,
              )
              ? widget.selectedAccountId
              : null,
          decoration: InputDecoration(labelText: _t('المستخدم', 'User')),
          items: widget.accounts
              .map(
                (account) => DropdownMenuItem(
                  value: account.id,
                  child: Text(account.displayName),
                ),
              )
              .toList(),
          onChanged: widget.onAccount,
        ),
        if (widget.onError != null)
          Text(widget.onError!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: widget.locked ? null : widget.onSubmit,
          icon: const Icon(Icons.login),
          label: Text(_t('دخول', 'Sign in')),
        ),
        if (widget.locked)
          Text(
            _t(
              'تم إيقاف المحاولة مؤقتًا. أعد تشغيل التطبيق.',
              'Sign-in locked. Restart the app to retry.',
            ),
          ),
      ],
    ),
  );
}
