import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/auth_gate_service.dart';
import 'package:radar_labor/app/auth_sign_in_handler.dart';
import 'package:radar_labor/app/login/login_flow_notifier.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';

final class AuthGateController extends ChangeNotifier {
  AuthGateController(AppDatabase database) : _service = AuthGateService(database);

  final AuthGateService _service;
  final flowNotifier = LoginFlowNotifier();
  LocalAccount? activeAccount;
  String? error;
  bool loading = true, busy = false;

  Future<void> load(bool isAr) async {
    loading = true;
    notifyListeners();
    try {
      final (accounts, rememberedId) = await _service.loadAccounts();
      flowNotifier.setAccounts(accounts, rememberedAccountId: rememberedId);
      loading = false;
      error = null;
    } on Object catch (e) {
      debugPrint('AuthGate load accounts failed (${e.runtimeType}).');
      loading = false;
      error = AuthFlowStrings.loadFailed(isAr);
    }
    notifyListeners();
  }

  Future<void> signIn(BuildContext context, AuthRole role, String id, String pass, bool isAr) async {
    busy = true;
    error = null;
    notifyListeners();
    final (acc, err) = await AuthSignInHandler.handleSignIn(
      context: context, service: _service, role: role, id: id, password: pass, isArabic: isAr,
    );
    busy = false;
    activeAccount = acc;
    error = err;
    notifyListeners();
  }

  void switchAccount() {
    _service.forgetRememberedAccount();
    flowNotifier.switchAccount();
    error = null;
    notifyListeners();
  }

  void logout(bool isAr) {
    flowNotifier.clearRole();
    activeAccount = null;
    load(isAr);
  }

  @override
  void dispose() {
    flowNotifier.dispose();
    super.dispose();
  }
}
