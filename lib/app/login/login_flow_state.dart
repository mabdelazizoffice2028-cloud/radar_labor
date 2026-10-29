import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';

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
    return accounts.where((a) => a.id == id && a.active).firstOrNull;
  }

  bool get isSupervisorRole =>
      selectedRole == AuthRole.siteSupervisor ||
      selectedRole == AuthRole.housingSupervisor;

  bool get isAdminRole =>
      selectedRole == AuthRole.projectManager ||
      selectedRole == AuthRole.hr;

  List<LocalAccount> get accountsForRole {
    final role = selectedRole;
    if (role == null) return const <LocalAccount>[];
    final list = [for (final a in accounts) if (a.active && a.role == role) a];
    list.sort((a, b) => NameCollation.sortKey(a.displayName)
        .compareTo(NameCollation.sortKey(b.displayName)));
    return List.unmodifiable(list);
  }

  bool get showNameDropdown => isSupervisorRole && accountsForRole.isNotEmpty;

  LocalAccount? get selectedAccount {
    final id = selectedAccountId;
    if (id == null) return null;
    return accountsForRole.where((a) => a.id == id).firstOrNull;
  }

  LoginFlowState copyWith({
    List<LocalAccount>? accounts,
    AuthRole? Function()? selectedRole,
    String? Function()? selectedAccountId,
    String? Function()? rememberedAccountId,
    bool? isRememberedMode,
  }) =>
      LoginFlowState(
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
