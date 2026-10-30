import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/notifications_coverage_tile.dart';
import 'package:radar_labor/core/l10n/notifications_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/dashboard/domain/dashboard_coverage_models.dart';

final class NotificationsCoverageSection extends StatelessWidget {
  const NotificationsCoverageSection({
    required this.coverage,
    required this.arabic,
    super.key,
  });

  final DashboardCoverage coverage;
  final bool arabic;

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppTokens.space8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final teams = coverage.missingTeams;
    final housings = coverage.missingHousings;
    if (teams.isEmpty && housings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (teams.isNotEmpty) ...[
          _header(NotificationsStrings.unrecordedTeams(arabic, teams.length)),
          for (final t in teams)
            NotificationsCoverageTile(
              icon: Icons.groups_outlined,
              title: arabic ? t.nameAr : (t.nameEn ?? t.nameAr),
              supervisors: t.supervisorNames.join(', '),
              arabic: arabic,
            ),
        ],
        if (housings.isNotEmpty) ...[
          _header(
            NotificationsStrings.unrecordedHousings(arabic, housings.length),
          ),
          for (final h in housings)
            NotificationsCoverageTile(
              icon: Icons.apartment_outlined,
              title: arabic ? h.nameAr : (h.nameEn ?? h.nameAr),
              supervisors: h.supervisorNames.join(', '),
              arabic: arabic,
            ),
        ],
      ],
    );
  }
}
