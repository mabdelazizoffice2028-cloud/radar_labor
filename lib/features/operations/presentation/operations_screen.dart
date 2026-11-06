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
import 'package:radar_labor/features/operations/presentation/widgets/operations_launcher_card.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_supervisor_teams_gate.dart';
import 'package:radar_labor/features/operations/presentation/widgets/supervisor_task_banner.dart';

/// Clean launcher hub for daily operations (housing check & site attendance).
final class OperationsScreen extends StatelessWidget {
  const OperationsScreen({
    required this.controller, required this.arabic, required this.role,
    this.teamSetupStore, this.actor, this.scope, super.key,
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

    final launcher = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canHousing)
              OperationsLauncherCard(
                cardKey: const ValueKey('launch_campus_check_card'),
                icon: Icons.apartment_outlined,
                title: OperationsStrings.startCampusCheckAction(arabic),
                subtitle: OperationsStrings.selectAbsentWorkersHint(arabic),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HousingCheckScreen(
                      controller: controller, arabic: arabic, actor: actor, scope: scope,
                    ),
                  ),
                ),
              ),
            if (canSite)
              OperationsLauncherCard(
                cardKey: const ValueKey('launch_site_attendance_card'),
                icon: Icons.engineering_outlined,
                title: OperationsStrings.startSiteAttendanceAction(arabic),
                subtitle: OperationsStrings.selectPresentWorkersHint(arabic),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SiteAttendanceScreen(
                      controller: controller, arabic: arabic,
                      teamSetupStore: teamSetupStore, actor: actor, scope: scope,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Column(
      children: [
        SupervisorTaskBanner(arabic: arabic, role: role, controller: controller),
        Expanded(
          child: role == AuthRole.siteSupervisor
              ? SiteSupervisorTeamsGate(
                  controller: controller, arabic: arabic,
                  teamSetupStore: teamSetupStore, actor: actor, scope: scope, child: launcher,
                )
              : launcher,
        ),
      ],
    );
  }
}
