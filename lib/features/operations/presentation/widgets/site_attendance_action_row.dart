import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

class SiteAttendanceActionRow extends StatelessWidget {
  const SiteAttendanceActionRow({
    required this.arabic,
    required this.onSelectAll,
    required this.onSelectDefaultCrew,
    super.key,
  });

  final bool arabic;
  final ValueChanged<bool> onSelectAll;
  final VoidCallback onSelectDefaultCrew;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTokens.space8,
      runSpacing: AppTokens.space8,
      children: [
        OutlinedButton.icon(
          onPressed: () => onSelectAll(true),
          icon: const Icon(Icons.done_all, size: 18),
          label: Text(OperationsStrings.selectAll(arabic)),
        ),
        FilledButton.tonalIcon(
          onPressed: onSelectDefaultCrew,
          icon: const Icon(Icons.groups_2_outlined, size: 18),
          label: Text(OperationsStrings.selectDefaultCrew(arabic)),
        ),
      ],
    );
  }
}
