import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';

/// Immutable state for the 3-step Role -> Name -> Password login flow (PRD §23.2, D-20).
final class LoginFlowState {
  const LoginFlowState({
    this.accounts = const <LocalAccount>[],
    this.selectedRole,
    this.selectedAccountId,
    this.rememberedAccountId,
    this.isRememberedMode = false,
  });

  final List<LocalAccount> accounts;
  final AuthRole? selectedRole;
  final String? selectedAccountId;
  final String? rememberedAccountId;
  final bool isRememberedMode;

  LocalAccount? get rememberedAccount {
    final id = rememberedAccountId;
    if (id == null) return null;
    for (final account in accounts) {
      if (account.id == id && account.active) return account;
    }
    return null;
  }

  bool get isSupervisorRole =>
      selectedRole == AuthRole.siteSupervisor ||
      selectedRole == AuthRole.housingSupervisor;

  /// Active accounts matching [selectedRole] sorted deterministically by name.
  List<LocalAccount> get accountsForRole {
    final role = selectedRole;
    if (role == null) return const <LocalAccount>[];
    final filtered = [
      for (final account in accounts)
        if (account.active && account.role == role) account,
    ];
    filtered.sort(
      (a, b) =>
          NameCollation.sortKey(a.displayName)
              .compareTo(NameCollation.sortKey(b.displayName)),
    );
    return List.unmodifiable(filtered);
  }

  /// Supervisors always see a name picker; non-supervisors only see it when >1 account exists (PRD §23.2).
  bool get showNameDropdown {
    if (selectedRole == null) return false;
    final list = accountsForRole;
    if (list.isEmpty) return false;
    if (isSupervisorRole) return true;
    return list.length > 1;
  }

  LocalAccount? get selectedAccount {
    final id = selectedAccountId;
    if (id == null) return null;
    for (final account in accountsForRole) {
      if (account.id == id) return account;
    }
    return null;
  }

  LoginFlowState copyWith({
    List<LocalAccount>? accounts,
    AuthRole? Function()? selectedRole,
    String? Function()? selectedAccountId,
    String? Function()? rememberedAccountId,
    bool? isRememberedMode,
  }) => LoginFlowState(
    accounts: accounts ?? this.accounts,
    selectedRole: selectedRole != null ? selectedRole() : this.selectedRole,
    selectedAccountId: selectedAccountId != null
        ? selectedAccountId()
        : this.selectedAccountId,
    rememberedAccountId: rememberedAccountId != null
        ? rememberedAccountId()
        : this.rememberedAccountId,
    isRememberedMode: isRememberedMode ?? this.isRememberedMode,
  );
}

/// Controller for the Role -> Name -> Password login flow (PRD §17.4, §23.2).
final class LoginFlowNotifier {
  LoginFlowNotifier([List<LocalAccount> initialAccounts = const []])
    : _state = LoginFlowState(accounts: List.unmodifiable(initialAccounts));

  final StreamController<LoginFlowState> _controller =
      StreamController<LoginFlowState>.broadcast();
  LoginFlowState _state;

  LoginFlowState get state => _state;
  Stream<LoginFlowState> get stream => _controller.stream;

  void _emit(LoginFlowState next) {
    _state = next;
    if (!_controller.isClosed) {
      _controller.add(next);
    }
  }

  void setAccounts(List<LocalAccount> accounts, {String? rememberedAccountId}) {
    final validRemembered =
        rememberedAccountId != null &&
        accounts.any((a) => a.id == rememberedAccountId && a.active);
    final next = _state.copyWith(
      accounts: List.unmodifiable(accounts),
      rememberedAccountId: () => validRemembered ? rememberedAccountId : null,
      isRememberedMode: validRemembered,
    );
    final role = next.selectedRole;
    if (role == null) {
      _emit(next);
      return;
    }
    _emit(_applyRoleSelection(next, role));
  }

  void switchAccount() {
    _emit(
      _state.copyWith(isRememberedMode: false, rememberedAccountId: () => null),
    );
  }

  void selectRole(AuthRole role) {
    _emit(_applyRoleSelection(_state, role));
  }

  void clearRole() {
    _emit(
      _state.copyWith(selectedRole: () => null, selectedAccountId: () => null),
    );
  }

  void selectAccount(String? accountId) {
    final valid = _state.accountsForRole.any((a) => a.id == accountId);
    _emit(_state.copyWith(selectedAccountId: () => valid ? accountId : null));
  }

  void dispose() {
    _controller.close();
  }

  LoginFlowState _applyRoleSelection(LoginFlowState base, AuthRole role) {
    final withRole = base.copyWith(selectedRole: () => role);
    final roleAccounts = withRole.accountsForRole;
    if (roleAccounts.isEmpty) {
      return withRole.copyWith(selectedAccountId: () => null);
    }
    return withRole.copyWith(selectedAccountId: () => roleAccounts.first.id);
  }
}

final loginFlowNotifierProvider = Provider.autoDispose<LoginFlowNotifier>((
  ref,
) {
  final notifier = LoginFlowNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});
