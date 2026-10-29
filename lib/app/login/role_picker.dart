import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';

/// Step 1 of the login flow: a compact localized role dropdown.
final class RolePicker extends StatelessWidget {
  const RolePicker({
    required this.onRoleSelected,
    required this.arabic,
    this.selectedRole,
    super.key,
  });

  final AuthRole? selectedRole;
  final ValueChanged<AuthRole> onRoleSelected;
  final bool arabic;

  static const List<AuthRole> orderedRoles = <AuthRole>[
    AuthRole.projectManager,
    AuthRole.hr,
    AuthRole.housingSupervisor,
    AuthRole.siteSupervisor,
    AuthRole.viewer,
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AuthRole>(
      key: const ValueKey('role_dropdown'),
      initialValue: selectedRole,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: AuthFlowStrings.chooseRoleTitle(arabic),
        prefixIcon: const Icon(Icons.badge_outlined),
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final role in orderedRoles)
          DropdownMenuItem(
            key: ValueKey('role_option_${role.name}'),
            value: role,
            child: Text(role.label(arabic: arabic)),
          ),
      ],
      onChanged: (role) {
        if (role != null) onRoleSelected(role);
      },
    );
  }
}
