import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Local administrator screen for creating accounts, resetting PINs, and assigning scopes.
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
  bool _loading = true, _busy = false;
  bool get _ar => widget.arabic;
  String t(String ar, String en) => _ar ? ar : en;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final db = widget.database;
      final v = await Future.wait<Object>([
        _auth.accounts(),
        (db.select(db.employees)..where((r) => r.isActive)).get(),
        (db.select(db.teams)..where((r) => r.isActive)).get(),
        (db.select(db.housings)..where((r) => r.isActive)).get(),
      ]);
      if (!mounted) return;
      setState(() {
        _accounts = v[0] as List<LocalAccount>;
        _employees = v[1] as List<Employee>;
        _teams = v[2] as List<Team>;
        _housings = v[3] as List<Housing>;
        _loading = false;
        _error = null;
      });
    } on Exception catch (error) {
      if (mounted) setState(() => (_loading = false, _error = '$error'));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AdminStrings.userAccountsTitle(_ar))),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _busy ? null : _add,
      icon: const Icon(Icons.person_add_alt_1),
      label: Text(AdminStrings.addUser(_ar)),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(AppTokens.space16),
            children: [
              if (_error != null) Text(_error!),
              for (final account in _accounts) _buildAccountCard(account),
            ],
          ),
  );

  Widget _buildAccountCard(LocalAccount account) => Card(
    child: ListTile(
      leading: Icon(
        account.active ? Icons.account_circle_outlined : Icons.block_outlined,
        color: account.active ? AppTokens.primary : AppTokens.textSecondary,
      ),
      title: Text(account.displayName),
      subtitle: Text(
        '${account.role.label(arabic: _ar)} · ${_scopeLabel(account)}'
        '${account.active ? '' : ' · ${AdminStrings.accountDeactivatedBadge(_ar)}'}',
      ),
      trailing: PopupMenuButton<String>(
        key: ValueKey('account_menu_${account.id}'),
        onSelected: (action) => _onAccountAction(account, action),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'reset_pin',
            child: Text(AdminStrings.resetPasswordAction(_ar)),
          ),
          if (account.active)
            PopupMenuItem(
              value: 'deactivate',
              child: Text(AdminStrings.deactivateAccountAction(_ar)),
            ),
        ],
      ),
    ),
  );

  Future<void> _onAccountAction(LocalAccount account, String action) async {
    setState(() => _busy = true);
    try {
      if (action == 'reset_pin') {
        await _auth.resetPassword(account.id);
        await _reload();
        if (mounted) {
          final msg = AdminStrings.resetPasswordDone(
            _ar,
            AuthConstants.temporaryPassword,
          );
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      } else if (action == 'deactivate') {
        await _auth.deactivateAccount(account.id);
        await _reload();
      }
    } on Exception catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    if (_employees.isEmpty) return;
    final emp = ValueNotifier<String?>(_employees.first.employeeUid);
    final role = ValueNotifier<AuthRole>(AuthRole.siteSupervisor);
    final teams = ValueNotifier<Set<String>>({});
    final housings = ValueNotifier<Set<String>>({});
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => _buildAddDialog(ctx, role, emp, teams, housings),
    );
    void disposeAll() {
      for (final n in [emp, role, teams, housings]) {
        n.dispose();
      }
    }

    if (created != true) return disposeAll();
    if (role.value == AuthRole.housingSupervisor && housings.value.isEmpty) {
      setState(() => _error = AdminStrings.assignHousingRequired(_ar));
      return disposeAll();
    }
    final empRow = _employees.firstWhere((e) => e.employeeUid == emp.value);
    setState(() => (_busy = true, _error = null));
    try {
      await _auth.createAccount(
        employeeUid: empRow.employeeUid,
        displayName: _name(empRow),
        role: role.value,
        teamIds: teams.value.toList(),
        housingIds: housings.value.toList(),
      );
      await _reload();
    } on Exception catch (e) {
      if (!mounted) return;
      final conflict = e is AuthConflictException;
      setState(
        () => _error = conflict
            ? AdminStrings.accountConflictError(_ar)
            : AdminStrings.accountCreateError(_ar),
      );
    } finally {
      disposeAll();
      if (mounted) setState(() => _busy = false);
    }
  }

  AlertDialog _buildAddDialog(
    BuildContext context,
    ValueNotifier<AuthRole> role,
    ValueNotifier<String?> emp,
    ValueNotifier<Set<String>> teams,
    ValueNotifier<Set<String>> housings,
  ) => AlertDialog(
    title: Text(AdminStrings.addUser(_ar)),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _roleField(role),
            _employeeField(emp),
            ValueListenableBuilder(
              valueListenable: role,
              builder: (context, r, _) => switch (r) {
                AuthRole.siteSupervisor => _assignmentList(
                  [
                    for (final t in _teams)
                      (t.teamId, _entityName(t.nameAr, t.nameEn)),
                  ],
                  teams,
                  AdminStrings.assignedTeams(_ar),
                ),
                AuthRole.housingSupervisor => _assignmentList(
                  [
                    for (final h in _housings)
                      (h.housingId, _entityName(h.nameAr, h.nameEn)),
                  ],
                  housings,
                  AdminStrings.assignedHousing(_ar),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(AppStrings.cancel(_ar)),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text(t('إنشاء', 'Create')),
      ),
    ],
  );

  Widget _roleField(ValueNotifier<AuthRole> role) => ValueListenableBuilder(
    valueListenable: role,
    builder: (context, value, _) => DropdownButtonFormField<AuthRole>(
      initialValue: value,
      decoration: InputDecoration(labelText: AdminStrings.roleLabel(_ar)),
      items: [
        for (final r in AuthRole.values)
          DropdownMenuItem(
            value: r,
            child: Text(r.label(arabic: _ar)),
          ),
      ],
      onChanged: (next) => next == null ? null : role.value = next,
    ),
  );

  Widget _employeeField(ValueNotifier<String?> emp) => ValueListenableBuilder(
    valueListenable: emp,
    builder: (context, value, _) => DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: AdminStrings.employeeLabel(_ar)),
      items: [
        for (final e in _employees)
          DropdownMenuItem(value: e.employeeUid, child: Text(_name(e))),
      ],
      onChanged: (next) => emp.value = next,
    ),
  );

  Widget _assignmentList(
    List<(String, String)> options,
    ValueNotifier<Set<String>> selection,
    String title,
  ) => ValueListenableBuilder<Set<String>>(
    valueListenable: selection,
    builder: (context, sel, _) => ExpansionTile(
      title: Text(title),
      children: [
        for (final o in options)
          CheckboxListTile(
            value: sel.contains(o.$1),
            title: Text(o.$2),
            onChanged: (c) =>
                selection.value = {...sel, if (c == true) o.$1}
                  ..removeWhere((id) => c == false && id == o.$1),
          ),
      ],
    ),
  );

  String _name(Employee r) =>
      _ar ? r.fullNameAr : (r.fullNameEn ?? r.fullNameAr);
  String _entityName(String ar, String? en) => _ar ? ar : (en ?? ar);
  String _scopeLabel(LocalAccount a) => switch (a.role) {
    AuthRole.housingSupervisor =>
      '${a.housingIds.length} ${t('مساكن', 'housing')}',
    AuthRole.siteSupervisor => '${a.teamIds.length} ${t('فرق', 'teams')}',
    _ => t('كامل التطبيق', 'Full app'),
  };
}
