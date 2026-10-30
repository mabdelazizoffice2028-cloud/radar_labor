import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/app/accounts/local_accounts_ops.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';

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
          if (context.mounted) AppSnackBar.show(context, message: msg);
        },
      );
    } on Exception catch (e) {
      debugPrint('Import workforce error: $e');
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: arabic ? 'تعذر استيراد الملف' : 'Could not import the file',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.upload_file_outlined),
      title: Text(
        arabic
            ? 'استيراد ملف العمال (Excel / CSV)'
            : 'Import Workforce (Excel / CSV)',
      ),
      subtitle: Text(
        arabic
            ? 'تحديث بيانات العمال وتفعيل المشرفين'
            : 'Update workers and activate supervisors',
      ),
      onTap: () => _handleTap(context),
    ),
  );
}
