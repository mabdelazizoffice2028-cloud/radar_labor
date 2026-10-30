import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/account_form_fields.dart';
import 'package:radar_labor/app/accounts/account_form_submitter.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

typedef ScopeOption = (String, String);

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
  final List<ScopeOption> employees;
  final List<ScopeOption> teams;
  final List<ScopeOption> housings;
  final LocalAccount? initial;

  static Future<AccountFormResult?> show(BuildContext context, AccountFormDialog dialog) =>
      showDialog<AccountFormResult>(context: context, builder: (_) => dialog);

  @override
  State<AccountFormDialog> createState() => _AccountFormDialogState();
}

final class _AccountFormDialogState extends State<AccountFormDialog> {
  late final _name = TextEditingController(text: widget.initial?.displayName ?? widget.employees.firstOrNull?.$2);
  late String? _employeeUid = widget.employees.firstOrNull?.$1;
  late AuthRole _role = widget.initial?.role ?? AuthRole.siteSupervisor;
  late final Set<String> _teams = {...?widget.initial?.teamIds};
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = AdminStrings.nameRequired(widget.arabic));
      return;
    }
    Navigator.pop(
      context,
      AccountFormSubmitter.buildResult(
        isAdding: widget.initial == null,
        employeeUid: _employeeUid,
        initialEmployeeUid: widget.initial?.employeeUid,
        displayName: name,
        role: _role,
        teams: _teams,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.initial == null ? AdminStrings.addUser(widget.arabic) : AdminStrings.editUser(widget.arabic)),
    content: AccountFormFields(
      arabic: widget.arabic,
      isAdding: widget.initial == null,
      employees: widget.employees,
      nameController: _name,
      selectedRole: _role,
      teams: widget.teams,
      selectedTeams: _teams,
      errorMessage: _error,
      onSelectEmployee: (uid, name) => setState(() { _employeeUid = uid; _name.text = name; }),
      onRoleChanged: (r) => setState(() => _role = r),
      onToggleTeam: (id, sel) => setState(() => sel ? _teams.add(id) : _teams.remove(id)),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.cancel(widget.arabic))),
      FilledButton(onPressed: _submit, child: Text(AppStrings.save(widget.arabic))),
    ],
  );
}
