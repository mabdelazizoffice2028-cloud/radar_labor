import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Selectable scope option: `(id, label)`.
typedef ScopeOption = (String, String);

/// Add/edit dialog for a sign-in name: person, display name, role and scope.
final class AccountFormDialog extends StatefulWidget {
  const AccountFormDialog({
    required this.arabic,
    required this.employees,
    required this.teams,
    required this.housings,
    this.initial,
    super.key,
  });

  final bool arabic;

  /// `(employeeUid, name)` choices; only used when adding a new account.
  final List<ScopeOption> employees;
  final List<ScopeOption> teams;
  final List<ScopeOption> housings;
  final LocalAccount? initial;

  static Future<AccountFormResult?> show(
    BuildContext context,
    AccountFormDialog dialog,
  ) => showDialog<AccountFormResult>(context: context, builder: (_) => dialog);

  @override
  State<AccountFormDialog> createState() => _AccountFormDialogState();
}

final class _AccountFormDialogState extends State<AccountFormDialog> {
  late final _name = TextEditingController(
    text: widget.initial?.displayName ?? widget.employees.firstOrNull?.$2,
  );
  late String? _employeeUid = widget.employees.firstOrNull?.$1;
  late AuthRole _role = widget.initial?.role ?? AuthRole.siteSupervisor;
  late final Set<String> _teams = {...?widget.initial?.teamIds};
  late final Set<String> _housings = {...?widget.initial?.housingIds};
  String? _error;

  bool get _ar => widget.arabic;
  bool get _adding => widget.initial == null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = AdminStrings.nameRequired(_ar));
      return;
    }
    if (_role == AuthRole.housingSupervisor &&
        widget.housings.isNotEmpty &&
        _housings.isEmpty) {
      setState(() => _error = AdminStrings.assignHousingRequired(_ar));
      return;
    }
    Navigator.pop(
      context,
      AccountFormResult(
        employeeUid: _adding ? _employeeUid : widget.initial?.employeeUid,
        displayName: name,
        role: _role,
        teamIds: _role == AuthRole.siteSupervisor ? _teams.toList() : const [],
        housingIds: _role == AuthRole.housingSupervisor
            ? _housings.toList()
            : const [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      _adding ? AdminStrings.addUser(_ar) : AdminStrings.editUser(_ar),
    ),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_adding)
              DropdownButtonFormField<String>(
                initialValue: _employeeUid,
                decoration: InputDecoration(
                  labelText: AdminStrings.employeeLabel(_ar),
                ),
                items: [
                  for (final e in widget.employees)
                    DropdownMenuItem(value: e.$1, child: Text(e.$2)),
                ],
                onChanged: (uid) => setState(() {
                  _employeeUid = uid;
                  final match = widget.employees.where((e) => e.$1 == uid);
                  if (match.isNotEmpty) _name.text = match.first.$2;
                }),
              ),
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: AdminStrings.displayNameLabel(_ar),
              ),
            ),
            DropdownButtonFormField<AuthRole>(
              initialValue: _role,
              decoration: InputDecoration(
                labelText: AdminStrings.roleLabel(_ar),
              ),
              items: [
                for (final r in AuthRole.values)
                  DropdownMenuItem(
                    value: r,
                    child: Text(r.label(arabic: _ar)),
                  ),
              ],
              onChanged: (r) => setState(() => _role = r ?? _role),
            ),
            if (_role == AuthRole.siteSupervisor)
              _scopeList(widget.teams, _teams, AdminStrings.assignedTeams(_ar)),
            if (_role == AuthRole.housingSupervisor)
              _scopeList(
                widget.housings,
                _housings,
                AdminStrings.assignedHousing(_ar),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppTokens.statusUnknown),
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(AppStrings.cancel(_ar)),
      ),
      FilledButton(onPressed: _submit, child: Text(AppStrings.save(_ar))),
    ],
  );

  Widget _scopeList(
    List<ScopeOption> options,
    Set<String> selection,
    String title,
  ) => ExpansionTile(
    title: Text(title),
    initiallyExpanded: true,
    children: [
      for (final o in options)
        CheckboxListTile(
          value: selection.contains(o.$1),
          title: Text(o.$2),
          onChanged: (checked) => setState(
            () =>
                checked == true ? selection.add(o.$1) : selection.remove(o.$1),
          ),
        ),
    ],
  );
}
