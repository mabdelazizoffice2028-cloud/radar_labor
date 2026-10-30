import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/app/auth_gate_controller.dart';
import 'package:radar_labor/app/widgets/auth_login_content.dart';
import 'package:radar_labor/app/widgets/auth_login_scaffold.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/database/app_database.dart';

typedef AuthenticatedBuilder = Widget Function(LocalAccount account, VoidCallback onLogout);

final class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({required this.database, required this.builder, super.key});
  final AppDatabase database;
  final AuthenticatedBuilder builder;

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

final class _AuthGateState extends ConsumerState<AuthGate> {
  late final _ctl = AuthGateController(widget.database);

  bool get _isAr => ref.watch(appLocaleProvider) == 'ar';

  @override
  void initState() {
    super.initState();
    _ctl.addListener(_onChanged);
    _ctl.load(ref.read(appLocaleProvider) == 'ar');
  }

  @override
  void dispose() {
    _ctl.removeListener(_onChanged);
    _ctl.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final acc = _ctl.activeAccount;
    if (acc != null) return widget.builder(acc, () => _ctl.logout(_isAr));
    return AuthLoginScaffold(
      arabic: _isAr,
      child: AuthLoginContent(
        flowNotifier: _ctl.flowNotifier,
        loading: _ctl.loading,
        busy: _ctl.busy,
        error: _ctl.error,
        arabic: _isAr,
        onSignIn: (role, id, pass) => _ctl.signIn(context, role, id, pass, _isAr),
        onSwitchAccount: _ctl.switchAccount,
      ),
    );
  }
}
