import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/dev_tools_strings.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/data/operations_dev_tools.dart';

final class PreferencesDevToolCard extends StatelessWidget {
  const PreferencesDevToolCard({required this.database, required this.arabic, super.key});
  final AppDatabase database;
  final bool arabic;

  Future<void> _confirmAndClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(DevToolsStrings.confirmClearTitle(arabic)),
        content: Text(DevToolsStrings.confirmClearBody(arabic)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(DevToolsStrings.cancel(arabic))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.statusUnknown),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(DevToolsStrings.clearData(arabic)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await OperationsDevTools.clearTestData(database);
      unawaited(FieldHaptics.success());
      if (!context.mounted) return;
      AppSnackBar.showSuccess(context, message: DevToolsStrings.clearSuccess(arabic));
    } on Object catch (error) {
      unawaited(FieldHaptics.error());
      debugPrint('Clear test data failed (${error.runtimeType}).');
      if (!context.mounted) return;
      AppSnackBar.showError(context, message: DevToolsStrings.clearFailed(arabic));
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    color: AppTokens.statusUnknownSoft,
    child: ListTile(
      leading: const Icon(Icons.delete_forever_outlined, color: AppTokens.statusUnknown),
      title: Text(
        DevToolsStrings.clearTitle(arabic),
        style: const TextStyle(color: AppTokens.statusUnknown, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        DevToolsStrings.clearSubtitle(arabic),
        style: const TextStyle(color: AppTokens.statusUnknown, fontSize: AppTokens.space12),
      ),
      onTap: () => _confirmAndClear(context),
    ),
  );
}
