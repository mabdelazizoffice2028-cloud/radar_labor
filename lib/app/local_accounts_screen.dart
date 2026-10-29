import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/account_form_dialog.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Administrator screen for the sign-in names: import Excel, add, edit
/// (name, role, scope), reset password, and remove from the sign-in list.
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
  late final _controller = AccountsAdminController(widget.database);
  AccountsAdminData? _data;
  String? _error;
  bool _busy = false;
  bool get _ar => widget.arabic;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final data = await _controller.load();
      if (mounted) {
        setState(() => (_data = data, _error = null));
      }
    } on Exception catch (e) {
      debugPrint('Accounts load failed (${e.runtimeType}).');
      if (mounted) {
        setState(() => _error = AdminStrings.accountsLoadError(_ar));
      }
    }
  }

  /// Runs [action] with a busy flag, mapping failures to a localized message.
  Future<void> _run(Future<void> Function() action, String failure) async {
    setState(() => (_busy = true, _error = null));
    try {
      await action();
      await _reload();
    } on LastManagerException catch (_) {
      if (mounted) setState(() => _error = AdminStrings.lastManagerError(_ar));
    } on AuthConflictException catch (_) {
      if (mounted) {
        setState(() => _error = AdminStrings.accountConflictError(_ar));
      }
    } on Object catch (e) {
      debugPrint('Account action failed (${e.runtimeType}).');
      if (mounted) setState(() => _error = failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _import() => _run(() async {
    final preview = await _controller.pickImport();
    if (preview == null || !mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AdminStrings.importReviewTitle(_ar)),
        content: Text(
          AdminStrings.importReviewBody(
            _ar,
            preview.rows.length,
            preview.supervisorCount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel(_ar)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AdminStrings.importConfirm(_ar)),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    final r = await _controller.commitImport(preview);
    if (mounted) {
      _toast(
        AdminStrings.importDone(_ar, r.added, r.updated, r.accountsCreated),
      );
    }
  }, AdminStrings.importFailed(_ar));

  AccountFormDialog _dialog(
    AccountsAdminData d, [
    LocalAccount? initial,
  ]) => AccountFormDialog(
    arabic: _ar,
    initial: initial,
    employees: [
      for (final e in d.employees)
        (e.employeeUid, _ar ? e.fullNameAr : (e.fullNameEn ?? e.fullNameAr)),
    ],
    teams: [for (final t in d.teams) (t.teamId, _label(t.nameAr, t.nameEn))],
    housings: [
      for (final h in d.housings) (h.housingId, _label(h.nameAr, h.nameEn)),
    ],
  );

  Future<void> _add() async {
    final data = _data;
    if (data == null || data.employees.isEmpty) return;
    final form = await AccountFormDialog.show(context, _dialog(data));
    if (form == null) return;
    await _run(
      () => _controller.create(form),
      AdminStrings.accountCreateError(_ar),
    );
  }

  Future<void> _onAction(LocalAccount account, String action) async {
    final data = _data;
    if (data == null) return;
    switch (action) {
      case 'edit':
        final form = await AccountFormDialog.show(
          context,
          _dialog(data, account),
        );
        if (form == null) return;
        await _run(
          () => _controller.update(account, form),
          AdminStrings.accountUpdateError(_ar),
        );
      case 'reset_pin':
        await _run(() async {
          await _controller.resetPassword(account.id);
          if (mounted) {
            _toast(
              AdminStrings.resetPasswordDone(
                _ar,
                AuthConstants.temporaryPassword,
              ),
            );
          }
        }, AdminStrings.accountUpdateError(_ar));
      case 'remove':
        if (await _confirmRemove(account) != true) return;
        await _run(
          () => _controller.remove(account),
          AdminStrings.accountUpdateError(_ar),
        );
    }
  }

  Future<bool?> _confirmRemove(LocalAccount account) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(AdminStrings.deleteUserConfirm(_ar, account.displayName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(AppStrings.cancel(_ar)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(AdminStrings.deleteUser(_ar)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      appBar: AppBar(
        title: Text(AdminStrings.userAccountsTitle(_ar)),
        actions: [
          TextButton.icon(
            key: const ValueKey('import_names_button'),
            onPressed: _busy ? null : _import,
            style: TextButton.styleFrom(foregroundColor: AppTokens.onPrimary),
            icon: const Icon(Icons.upload_file),
            label: Text(AdminStrings.importNamesAction(_ar)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy || (data?.employees.isEmpty ?? true) ? null : _add,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(AdminStrings.addUser(_ar)),
      ),
      body: data == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Text(_error!),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.space16,
                AppTokens.space16,
                AppTokens.space16,
                100,
              ),
              children: [
                if (_busy) const LinearProgressIndicator(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.space8),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppTokens.statusUnknown),
                    ),
                  ),
                if (!data.hasSupervisors)
                  Card(
                    color: AppTokens.primarySoft,
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.space12),
                      child: Text(AdminStrings.noNamesHint(_ar)),
                    ),
                  ),
                for (final account in data.accounts) _card(account),
              ],
            ),
    );
  }

  Widget _card(LocalAccount account) => Card(
    child: ListTile(
      leading: const Icon(
        Icons.account_circle_outlined,
        color: AppTokens.primary,
      ),
      title: Text(account.displayName),
      subtitle: Text('${account.role.label(arabic: _ar)} · ${_scope(account)}'),
      trailing: PopupMenuButton<String>(
        key: ValueKey('account_menu_${account.id}'),
        enabled: !_busy,
        onSelected: (action) => _onAction(account, action),
        itemBuilder: (context) => [
          PopupMenuItem(value: 'edit', child: Text(AdminStrings.editUser(_ar))),
          PopupMenuItem(
            value: 'reset_pin',
            child: Text(AdminStrings.resetPasswordAction(_ar)),
          ),
          PopupMenuItem(
            value: 'remove',
            child: Text(AdminStrings.deleteUser(_ar)),
          ),
        ],
      ),
    ),
  );

  String _label(String ar, String? en) => _ar ? ar : (en ?? ar);

  String _scope(LocalAccount a) => switch (a.role) {
    AuthRole.housingSupervisor => AdminStrings.scopeHousingCount(
      _ar,
      a.housingIds.length,
    ),
    AuthRole.siteSupervisor => AdminStrings.scopeTeamsCount(
      _ar,
      a.teamIds.length,
    ),
    _ => AdminStrings.scopeFullApp(_ar),
  };
}
