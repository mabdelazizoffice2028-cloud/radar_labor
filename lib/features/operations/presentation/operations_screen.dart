import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:radar_labor/features/operations/presentation/housing_check_screen.dart';
import 'package:radar_labor/features/operations/presentation/site_attendance_screen.dart';

/// Local daily check-in workflows for housing and site supervisors.
final class OperationsScreen extends StatelessWidget {
  const OperationsScreen({
    required this.repository,
    required this.arabic,
    super.key,
  });

  final OperationsRepository repository;
  final bool arabic;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.apartment_outlined),
                text: arabic ? 'فحص السكن' : 'Housing check',
              ),
              Tab(
                icon: const Icon(Icons.location_on_outlined),
                text: arabic ? 'تسجيل الموقع' : 'Site attendance',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              HousingCheckScreen(repository: repository, arabic: arabic),
              SiteAttendanceScreen(repository: repository, arabic: arabic),
            ],
          ),
        ),
      ],
    ),
  );
}
