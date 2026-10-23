import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/features/operations/presentation/housing_check_screen.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/site_attendance_screen.dart';

/// Local daily check-in workflows for housing and site supervisors.
final class OperationsScreen extends StatelessWidget {
  const OperationsScreen({
    required this.controller,
    required this.arabic,
    required this.role,
    super.key,
  });

  final OperationsController controller;
  final bool arabic;
  final AuthRole role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == AuthRole.projectManager || role == AuthRole.hr;
    final showHousing = isAdmin || role == AuthRole.housingSupervisor;
    final showSite = isAdmin || role == AuthRole.siteSupervisor;
    final children = [
      if (showHousing)
        HousingCheckScreen(controller: controller, arabic: arabic),
      if (showSite)
        SiteAttendanceScreen(controller: controller, arabic: arabic),
    ];
    if (children.length == 1) return children.single;
    return DefaultTabController(
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
                    text: arabic ? 'فحص السكن' : 'Housing check',
                  ),
                if (showSite)
                  Tab(
                    icon: const Icon(Icons.location_on_outlined),
                    text: arabic ? 'تسجيل الموقع' : 'Site attendance',
                  ),
              ],
            ),
          ),
          Expanded(child: TabBarView(children: children)),
        ],
      ),
    );
  }
}
