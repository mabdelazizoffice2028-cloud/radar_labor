import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

/// Dialog to input Arabic and English name for a new team.
Future<String?> showAddTeamDialog({
  required BuildContext context,
  required bool arabic,
}) async {
  final ar = TextEditingController();
  final en = TextEditingController();
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppStrings.addTeam(arabic)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: ar,
            decoration: InputDecoration(
              labelText: AppStrings.arabicName(arabic),
            ),
          ),
          TextField(
            controller: en,
            decoration: InputDecoration(
              labelText: AppStrings.englishName(arabic),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppStrings.cancel(arabic)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(AppStrings.save(arabic)),
        ),
      ],
    ),
  );
  if (saved != true || ar.text.trim().isEmpty) return null;
  return ar.text.trim();
}
