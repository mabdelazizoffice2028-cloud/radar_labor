import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/app/accounts/local_accounts_action_handler.dart';
import 'package:radar_labor/app/accounts/local_accounts_app_bar.dart';
import 'package:radar_labor/app/accounts/local_accounts_body.dart';
import 'package:radar_labor/app/accounts/local_accounts_fab.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';

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
  void initState() { super.initState(); _reload(); }

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
    try {
      await action(); await _reload();
    } on Exception catch (e) {
      debugPrint('LocalAccountsScreen action error: $e');
      if (mounted) setState(() => _error = failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String m) => AppSnackBar.showSuccess(context, message: m);

  void _onAction(LocalAccount a, String act) => LocalAccountsActionHandler.handleAction(
    context: context, account: a, action: act, data: _data!, controller: _controller,
    arabic: widget.arabic, run: _run, toast: _toast,
  );

  Future<void> _onBatch(List<Employee> sel, AuthRole role) => _run(() async {
    final c = await _controller.batchActivateSupervisors(selectedEmployees: sel, role: role);
    _toast(AdminStrings.batchActivated(widget.arabic, c));
  }, AdminStrings.accountCreateError(widget.arabic));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: LocalAccountsAppBar(arabic: widget.arabic, busy: _busy, controller: _controller, onReload: _reload, toast: _toast),
    floatingActionButton: LocalAccountsFab(data: _data, busy: _busy, arabic: widget.arabic, controller: _controller, onRun: _run),
    body: LocalAccountsBody(data: _data, arabic: widget.arabic, busy: _busy, error: _error, onAction: _onAction, onBatchActivate: _onBatch),
  );
}
