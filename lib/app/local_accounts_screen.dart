import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';

/// Local administrator screen for creating accounts and assigning scopes.
final class LocalAccountsScreen extends StatefulWidget {
  const LocalAccountsScreen({
    required this.database,
    required this.arabic,
    super.key,
  });
  final AppDatabase database;
  final bool arabic;

  @override
  State<LocalAccountsScreen> createState() => _LocalAccountsScreenState();
}

final class _LocalAccountsScreenState extends State<LocalAccountsScreen> {
  late final _auth = LocalAuthRepository(widget.database);
  List<LocalAccount> _accounts = const [];
  List<Employee> _employees = const [];
  List<Team> _teams = const [];
  List<Housing> _housings = const [];
  String? _error;
  bool _loading = true;
  bool _busy = false;
  String t(String ar, String en) => widget.arabic ? ar : en;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final values = await Future.wait<Object>([
        _auth.accounts(),
        (widget.database.select(
          widget.database.employees,
        )..where((row) => row.isActive)).get(),
        (widget.database.select(
          widget.database.teams,
        )..where((row) => row.isActive)).get(),
        (widget.database.select(
          widget.database.housings,
        )..where((row) => row.isActive)).get(),
      ]);
      if (!mounted) return;
      setState(() {
        _accounts = values[0] as List<LocalAccount>;
        _employees = values[1] as List<Employee>;
        _teams = values[2] as List<Team>;
        _housings = values[3] as List<Housing>;
        _loading = false;
        _error = null;
      });
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(t('إدارة المستخدمين', 'User accounts'))),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _busy ? null : _add,
      icon: const Icon(Icons.person_add_alt_1),
      label: Text(t('إضافة مستخدم', 'Add user')),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text(_error!))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final account in _accounts)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_circle_outlined),
                    title: Text(account.displayName),
                    subtitle: Text(
                      '${account.role.label(arabic: widget.arabic)} · ${_scopeLabel(account)}',
                    ),
                    trailing: account.mustChangePassword
                        ? const Icon(Icons.key_outlined)
                        : null,
                  ),
                ),
            ],
          ),
  );

  Future<void> _add() async {
    if (_employees.isEmpty) return;
    final employee = ValueNotifier<String?>(_employees.first.employeeUid);
    final role = ValueNotifier<AuthRole>(AuthRole.housingSupervisor);
    final teams = ValueNotifier<Set<String>>({});
    final housings = ValueNotifier<Set<String>>({});
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('إضافة مستخدم', 'Add user')),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder(
                  valueListenable: role,
                  builder: (context, value, _) =>
                      DropdownButtonFormField<AuthRole>(
                        initialValue: value,
                        decoration: InputDecoration(
                          labelText: t('الدور', 'Role'),
                        ),
                        items: AuthRole.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.label(arabic: widget.arabic)),
                              ),
                            )
                            .toList(),
                        onChanged: (next) {
                          if (next != null) role.value = next;
                        },
                      ),
                ),
                ValueListenableBuilder(
                  valueListenable: employee,
                  builder: (context, value, _) =>
                      DropdownButtonFormField<String>(
                        initialValue: value,
                        decoration: InputDecoration(
                          labelText: t('الموظف', 'Employee'),
                        ),
                        items: _employees
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.employeeUid,
                                child: Text(_name(item)),
                              ),
                            )
                            .toList(),
                        onChanged: (next) => employee.value = next,
                      ),
                ),
                ValueListenableBuilder(
                  valueListenable: role,
                  builder: (context, currentRole, _) {
                    if (currentRole == AuthRole.siteSupervisor) {
                      return _assignmentList(
                        _teams
                            .map(
                              (item) => (
                                item.teamId,
                                _entityName(item.nameAr, item.nameEn),
                              ),
                            )
                            .toList(),
                        teams,
                        t('الفرق المسندة', 'Assigned teams'),
                      );
                    }
                    if (currentRole == AuthRole.housingSupervisor) {
                      return _assignmentList(
                        _housings
                            .map(
                              (item) => (
                                item.housingId,
                                _entityName(item.nameAr, item.nameEn),
                              ),
                            )
                            .toList(),
                        housings,
                        t('المساكن المسندة', 'Assigned housing'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('إنشاء', 'Create')),
          ),
        ],
      ),
    );
    if (created != true) return;
    final employeeRow = _employees.firstWhere(
      (item) => item.employeeUid == employee.value,
    );
    if ((role.value == AuthRole.siteSupervisor && teams.value.isEmpty) ||
        (role.value == AuthRole.housingSupervisor && housings.value.isEmpty)) {
      setState(
        () => _error = t(
          'اختر نطاقًا واحدًا على الأقل للمشرف',
          'Assign at least one team or housing',
        ),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth.createAccount(
        employeeUid: employeeRow.employeeUid,
        displayName: _name(employeeRow),
        role: role.value,
        teamIds: teams.value.toList(),
        housingIds: housings.value.toList(),
      );
      await _reload();
    } on Exception catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AuthConflictException
              ? t(
                  'هذا المستخدم موجود بالفعل لهذا الدور',
                  'This user already has that role',
                )
              : t('تعذر إنشاء الحساب', 'Could not create account'),
        );
      }
    } finally {
      employee.dispose();
      role.dispose();
      teams.dispose();
      housings.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _assignmentList(
    List<(String, String)> options,
    ValueNotifier<Set<String>> selection,
    String title,
  ) => ValueListenableBuilder<Set<String>>(
    valueListenable: selection,
    builder: (context, selected, _) => ExpansionTile(
      title: Text(title),
      children: [
        for (final item in options)
          CheckboxListTile(
            value: selected.contains(item.$1),
            title: Text(item.$2),
            onChanged: (checked) =>
                selection.value = {...selected, if (checked == true) item.$1}
                  ..removeWhere((id) => checked == false && id == item.$1),
          ),
      ],
    ),
  );

  String _name(Employee row) =>
      widget.arabic ? row.fullNameAr : (row.fullNameEn ?? row.fullNameAr);
  String _entityName(String ar, String? en) => widget.arabic ? ar : (en ?? ar);
  String _scopeLabel(LocalAccount account) => switch (account.role) {
    AuthRole.housingSupervisor =>
      '${account.housingIds.length} ${t('مساكن', 'housing')}',
    AuthRole.siteSupervisor => '${account.teamIds.length} ${t('فرق', 'teams')}',
    _ => t('كامل التطبيق', 'Full app'),
  };
}
