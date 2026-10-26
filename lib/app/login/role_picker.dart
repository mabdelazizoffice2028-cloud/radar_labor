import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Step 1 of the Part B login flow: large role selection cards (PRD §17.4, §23.2).
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AuthFlowStrings.chooseRoleTitle(arabic),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        for (final role in orderedRoles) ...[
          _RoleCard(
            key: ValueKey('role_card_${role.name}'),
            role: role,
            selected: selectedRole == role,
            arabic: arabic,
            onTap: () => onRoleSelected(role),
          ),
          const SizedBox(height: AppTokens.space8),
        ],
      ],
    );
  }
}

final class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.arabic,
    required this.onTap,
    super.key,
  });

  final AuthRole role;
  final bool selected;
  final bool arabic;
  final VoidCallback onTap;

  IconData _iconForRole(AuthRole role) => switch (role) {
    AuthRole.projectManager => Icons.manage_accounts_outlined,
    AuthRole.hr => Icons.badge_outlined,
    AuthRole.housingSupervisor => Icons.home_work_outlined,
    AuthRole.siteSupervisor => Icons.engineering_outlined,
    AuthRole.viewer => Icons.visibility_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: role.label(arabic: arabic),
      child: Material(
        color: selected ? AppTokens.primarySoft : AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radius12),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppTokens.minRowHeight,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space16,
              vertical: AppTokens.space12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTokens.radius12),
              border: Border.all(
                color: selected ? AppTokens.primary : AppTokens.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _iconForRole(role),
                  color: selected ? AppTokens.primary : AppTokens.textSecondary,
                  size: 28,
                ),
                const SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Text(
                    role.label(arabic: arabic),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.arrow_forward_ios_outlined,
                  size: selected ? 22 : 16,
                  color: selected ? AppTokens.primary : AppTokens.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
