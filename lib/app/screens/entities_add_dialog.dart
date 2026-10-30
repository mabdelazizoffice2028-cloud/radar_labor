import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

/// Dialog to input a single English name for a new team.
Future<String?> showAddTeamDialog({
  required BuildContext context,
  required bool arabic,
}) async {
  final nameCtrl = TextEditingController();
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppStrings.addTeam(arabic)),
      content: TextField(
        controller: nameCtrl,
        decoration: InputDecoration(
          labelText: arabic ? 'اسم الفريق (بالإنجليزية)' : 'Team name (English)',
        ),
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
  if (saved != true || nameCtrl.text.trim().isEmpty) return null;
  return nameCtrl.text.trim();
}
