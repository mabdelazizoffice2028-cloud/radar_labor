import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/login/login_flow_state.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';

export 'login_flow_state.dart';

final class LoginFlowNotifier {
  LoginFlowNotifier([List<LocalAccount> initial = const []])
      : _state = LoginFlowState(accounts: List.unmodifiable(initial));

  final _controller = StreamController<LoginFlowState>.broadcast();
  LoginFlowState _state;

  LoginFlowState get state => _state;
  Stream<LoginFlowState> get stream => _controller.stream;

  void _emit(LoginFlowState next) {
    _state = next;
    if (!_controller.isClosed) _controller.add(next);
  }

  void setAccounts(List<LocalAccount> accounts, {String? rememberedAccountId}) {
    final valid = rememberedAccountId != null &&
        accounts.any((a) => a.id == rememberedAccountId && a.active);
    final next = _state.copyWith(
      accounts: List.unmodifiable(accounts),
      rememberedAccountId: () => valid ? rememberedAccountId : null,
      isRememberedMode: valid,
    );
    final role = next.selectedRole;
    if (role == null) {
      _emit(next);
      return;
    }
    _emit(_applyRoleSelection(next, role));
  }

  void switchAccount() => _emit(_state.copyWith(
        isRememberedMode: false,
        rememberedAccountId: () => null,
      ));

  void selectRole(AuthRole role) => _emit(_applyRoleSelection(_state, role));

  void clearRole() => _emit(_state.copyWith(
        selectedRole: () => null,
        selectedAccountId: () => null,
      ));

  void selectAccount(String? accountId) {
    final valid = _state.accountsForRole.any((a) => a.id == accountId);
    _emit(_state.copyWith(selectedAccountId: () => valid ? accountId : null));
  }

  void dispose() => _controller.close();

  LoginFlowState _applyRoleSelection(LoginFlowState base, AuthRole role) {
    final withRole = base.copyWith(selectedRole: () => role);
    final roleAccounts = withRole.accountsForRole;
    if (roleAccounts.isEmpty) {
      return withRole.copyWith(selectedAccountId: () => null);
    }
    return withRole.copyWith(selectedAccountId: () => roleAccounts.first.id);
  }
}

final loginFlowNotifierProvider =
    Provider.autoDispose<LoginFlowNotifier>((ref) {
  final notifier = LoginFlowNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});
