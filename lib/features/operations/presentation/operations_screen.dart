import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/housing_check_screen.dart';
import 'package:radar_labor/features/operations/presentation/site_attendance_screen.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/widgets/supervisor_task_banner.dart';

/// Local daily check-in workflows for housing and site supervisors (BC-1).
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
    final showHousing = capabilities.canRecordHousing;
    final showSite = capabilities.canRecordSite;
    final children = [
      if (showHousing)
        HousingCheckScreen(controller: controller, arabic: arabic),
      if (showSite)
        SiteAttendanceScreen(
          controller: controller,
          arabic: arabic,
          teamSetupStore: teamSetupStore,
          actor: actor,
          scope: scope,
        ),
    ];
    if (children.isEmpty) {
      return Center(child: Text(OperationsStrings.errPermissionDenied(arabic)));
    }

    final Widget content;
    if (children.length == 1) {
      content = Expanded(child: children.single);
    } else {
      content = Expanded(
        child: DefaultTabController(
          length: children.length,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  tabs: [
                    if (showHousing)
                      Tab(
                        icon: const Icon(Icons.apartment_outlined),
                        text: OperationsStrings.housingCheckTab(arabic),
                      ),
                    if (showSite)
                      Tab(
                        icon: const Icon(Icons.location_on_outlined),
                        text: OperationsStrings.siteAttendanceTab(arabic),
                      ),
                  ],
                ),
              ),
              Expanded(child: TabBarView(children: children)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SupervisorTaskBanner(
          arabic: arabic,
          role: role,
          controller: controller,
        ),
        content,
      ],
    );
  }
}
