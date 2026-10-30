import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';

final class DashboardDateSelector extends StatelessWidget {
  const DashboardDateSelector({
    required this.date,
    required this.arabic,
    required this.onPressed,
    super.key,
  });

  final String date;
  final bool arabic;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.calendar_month_outlined),
      title: Text(DashboardStrings.businessDate(arabic)),
      subtitle: Text(date),
      trailing: const Icon(Icons.edit_calendar_outlined),
      onTap: onPressed,
    ),
  );
}
