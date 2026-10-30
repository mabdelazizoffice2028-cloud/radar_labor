import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/account_form_dialog.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/app/accounts/local_accounts_action_handler.dart';
import 'package:radar_labor/app/accounts/local_accounts_dialog_factory.dart';
import 'package:radar_labor/app/accounts/local_accounts_list.dart';
import 'package:radar_labor/app/accounts/local_accounts_ops.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';

final class LocalAccountsScreen extends StatefulWidget {
  const LocalAccountsScreen({required this.database, required this.arabic, super.key});
  final AppDatabase database; final bool arabic;

  @override
  State<LocalAccountsScreen> createState() => _LocalAccountsScreenState();
}

final class _LocalAccountsScreenState extends State<LocalAccountsScreen> {
  late final _controller = AccountsAdminController(widget.database);
  AccountsAdminData? _data; String? _error; bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final data = await _controller.load();
      if (mounted) setState(() => (_data = data, _error = null));
    } on Exception catch (e) {
      debugPrint('LocalAccountsScreen reload error: $e');
      if (mounted) setState(() => _error = AdminStrings.accountsLoadError(widget.arabic));
    }
  }

  Future<void> _run(Future<void> Function() action, String failure) async {
    setState(() => (_busy = true, _error = null));
    try { await action(); await _reload(); } on Exception catch (e) {
      debugPrint('LocalAccountsScreen action error: $e');
      if (mounted) setState(() => _error = failure);
    } finally { if (mounted) setState(() => _busy = false); }
  }

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _onBatchActivate(List<Employee> selected, AuthRole role) => _run(() async {
    final count = await _controller.batchActivateSupervisors(selectedEmployees: selected, role: role);
    _toast(AdminStrings.batchActivated(widget.arabic, count));
  }, AdminStrings.accountCreateError(widget.arabic));

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return Scaffold(
      appBar: AppBar(title: Text(AdminStrings.userAccountsTitle(widget.arabic)), actions: [
        TextButton.icon(
          onPressed: _busy ? null : () => LocalAccountsOps.importRoster(
            context: context, controller: _controller, arabic: widget.arabic, toast: _toast,
          ).then((_) => _reload()),
          icon: const Icon(Icons.upload_file), label: Text(AdminStrings.importNamesAction(widget.arabic)),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy || (d?.employees.isEmpty ?? true) ? null : () async {
          final f = await AccountFormDialog.show(context, LocalAccountsDialogFactory.create(data: d!, arabic: widget.arabic));
          if (f != null) await _run(() => _controller.create(f), AdminStrings.accountCreateError(widget.arabic));
        },
        icon: const Icon(Icons.person_add_alt_1), label: Text(AdminStrings.addUser(widget.arabic)),
      ),
      body: d == null ? Center(child: _error == null ? const CircularProgressIndicator() : Text(_error!)) : LocalAccountsList(
        data: d, arabic: widget.arabic, busy: _busy, error: _error,
        onAction: (a, act) => LocalAccountsActionHandler.handleAction(
          context: context, account: a, action: act, data: d, controller: _controller,
          arabic: widget.arabic, run: _run, toast: _toast,
        ),
        onBatchActivate: _onBatchActivate,
      ),
    );
  }
}
