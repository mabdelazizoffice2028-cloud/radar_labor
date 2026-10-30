import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/notifications_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class NotificationsCoverageTile extends StatelessWidget {
  const NotificationsCoverageTile({
    required this.icon,
    required this.title,
    required this.supervisors,
    required this.arabic,
    super.key,
  });

  final IconData icon;
  final String title;
  final String supervisors;
  final bool arabic;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: AppTokens.space8),
    child: ListTile(
      dense: true,
      leading: Icon(icon, color: AppTokens.statusHousingOnly),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: supervisors.isNotEmpty
          ? Text(
              '${NotificationsStrings.supervisorPrefix(arabic)}$supervisors',
              style: const TextStyle(
                fontSize: 11,
                color: AppTokens.textSecondary,
              ),
            )
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space8,
          vertical: AppTokens.space4,
        ),
        decoration: BoxDecoration(
          color: AppTokens.statusHousingOnlySoft,
          borderRadius: BorderRadius.circular(AppTokens.radius8),
        ),
        child: Text(
          NotificationsStrings.missingBadge(arabic),
          style: const TextStyle(
            fontSize: 11,
            color: AppTokens.statusHousingOnly,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
