import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';

/// Low-frequency site attendance actions, kept out of the visual foreground.
enum SiteAttendanceMenuAction { clearAll, addFromAnotherTeam, editTeam }

/// Overflow menu for secondary site attendance actions.
final class SiteAttendanceMoreMenu extends StatelessWidget {
  const SiteAttendanceMoreMenu({
    required this.arabic,
    required this.canEditTeam,
    required this.onSelected,
    super.key,
  });

  final bool arabic;
  final bool canEditTeam;
  final ValueChanged<SiteAttendanceMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SiteAttendanceMenuAction>(
      key: const ValueKey('site_more_menu'),
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SiteAttendanceMenuAction.addFromAnotherTeam,
          child: Text(OperationsStrings.addFromAnotherTeam(arabic)),
        ),
        PopupMenuItem(
          value: SiteAttendanceMenuAction.clearAll,
          child: Text(OperationsStrings.clearAll(arabic)),
        ),
        if (canEditTeam)
          PopupMenuItem(
            value: SiteAttendanceMenuAction.editTeam,
            child: Text(OperationsStrings.editTeam(arabic)),
          ),
      ],
    );
  }
}
