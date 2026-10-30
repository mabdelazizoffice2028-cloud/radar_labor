import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/app/accounts/local_accounts_ops.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/dev_tools_strings.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';

final class PreferencesImportCard extends StatelessWidget {
  const PreferencesImportCard({
    required this.database,
    required this.arabic,
    super.key,
  });

  final AppDatabase database;
  final bool arabic;

  Future<void> _handleTap(BuildContext context) async {
    try {
      await LocalAccountsOps.importRoster(
        context: context,
        controller: AccountsAdminController(database),
        arabic: arabic,
        toast: (msg) {
          if (context.mounted) {
            FieldHaptics.success();
            AppSnackBar.showSuccess(context, message: msg);
          }
        },
      );
    } on Exception catch (e) {
      await FieldHaptics.error();
      debugPrint('Import workforce error: $e');
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          message: DevToolsStrings.importFailed(arabic),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.upload_file_outlined),
      title: Text(DevToolsStrings.importCardTitle(arabic)),
      subtitle: Text(DevToolsStrings.importCardSubtitle(arabic)),
      onTap: () => _handleTap(context),
    ),
  );
}
