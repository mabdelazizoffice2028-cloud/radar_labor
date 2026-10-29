import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/login/login_flow_state.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';

/// Account name step: dropdown when a supervisor selects their account name.
final class LoginAccountPicker extends StatelessWidget {
  const LoginAccountPicker({
    required this.state,
    required this.arabic,
    required this.busy,
    required this.onAccountChanged,
    super.key,
  });

  final LoginFlowState state;
  final bool arabic;
  final bool busy;
  final ValueChanged<String?> onAccountChanged;

  @override
  Widget build(BuildContext context) {
    final role = state.selectedRole;
    if (!state.showNameDropdown || role == null) {
      return const SizedBox.shrink();
    }
    return DropdownButtonFormField<String>(
      key: ValueKey('account_dropdown_${role.name}'),
      initialValue: state.selectedAccountId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: AuthFlowStrings.chooseNameLabel(arabic),
        prefixIcon: const Icon(Icons.person_outline),
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final account in state.accountsForRole)
          DropdownMenuItem(
            value: account.id,
            child: Text(account.displayName),
          ),
      ],
      onChanged: busy ? null : onAccountChanged,
    );
  }
}
