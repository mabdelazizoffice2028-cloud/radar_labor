import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/housing_check_screen.dart';
import 'package:radar_labor/features/operations/presentation/site_attendance_screen.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/widgets/supervisor_task_banner.dart';

/// Clean launcher hub for daily operations (housing check & site attendance).
final class OperationsScreen extends StatelessWidget {
  const OperationsScreen({
    required this.controller,
    required this.arabic,
    required this.role,
    this.teamSetupStore,
    this.actor,
    this.scope,
    super.key,
  });

  final OperationsController controller;
  final bool arabic;
  final AuthRole role;
  final TeamSetupStore? teamSetupStore;
  final ActorContext? actor;
  final ScopeSnapshot? scope;

  @override
  Widget build(BuildContext context) {
    final capabilities = role.capabilities;
    final canHousing = capabilities.canRecordHousing;
    final canSite = capabilities.canRecordSite;

    if (!canHousing && !canSite) {
      return Center(child: Text(OperationsStrings.errPermissionDenied(arabic)));
    }

    return Column(
      children: [
        SupervisorTaskBanner(
          arabic: arabic,
          role: role,
          controller: controller,
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppTokens.space16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (canHousing)
                    _buildLauncherCard(
                      context: context,
                      key: const ValueKey('launch_campus_check_card'),
                      icon: Icons.apartment_outlined,
                      title: OperationsStrings.startCampusCheckAction(arabic),
                      subtitle: OperationsStrings.selectAbsentWorkersHint(
                        arabic,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HousingCheckScreen(
                              controller: controller,
                              arabic: arabic,
                              actor: actor,
                              scope: scope,
                            ),
                          ),
                        );
                      },
                    ),
                  if (canSite)
                    _buildLauncherCard(
                      context: context,
                      key: const ValueKey('launch_site_attendance_card'),
                      icon: Icons.engineering_outlined,
                      title: OperationsStrings.startSiteAttendanceAction(
                        arabic,
                      ),
                      subtitle: OperationsStrings.selectPresentWorkersHint(
                        arabic,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SiteAttendanceScreen(
                              controller: controller,
                              arabic: arabic,
                              teamSetupStore: teamSetupStore,
                              actor: actor,
                              scope: scope,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLauncherCard({
    required BuildContext context,
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      key: key,
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        side: const BorderSide(color: AppTokens.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 80),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.space16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    icon,
                    size: 30,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTokens.space8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTokens.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
