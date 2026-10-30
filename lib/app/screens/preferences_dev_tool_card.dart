import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/features/operations/data/operations_dev_tools.dart';

final class PreferencesDevToolCard extends StatelessWidget {
  const PreferencesDevToolCard({
    required this.database,
    required this.arabic,
    super.key,
  });

  final AppDatabase database;
  final bool arabic;

  Future<void> _confirmAndClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(arabic ? 'تأكيد مسح البيانات' : 'Confirm Data Clear'),
        content: Text(
          arabic
              ? 'هل أنت متأكد من مسح جميع أحداث الحضور والتسجيل التجريبية؟ لن يتم حذف العمال أو الفرق، فقط الحركات.'
              : 'Are you sure you want to clear all test attendance and registration events? Workers and teams will not be deleted, only ledger entries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(arabic ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(arabic ? 'مسح البيانات' : 'Clear Data'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    try {
      await OperationsDevTools.clearTestData(database);
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: arabic ? 'تم مسح بيانات التجارب بنجاح' : 'Test data cleared successfully',
        backgroundColor: Colors.green.shade700,
      );
    } on Object catch (error) {
      debugPrint('Clear test data failed (${error.runtimeType}).');
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: arabic ? 'فشل مسح البيانات' : 'Failed to clear test data',
        backgroundColor: Colors.red.shade700,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.red.shade50,
    child: ListTile(
      leading: Icon(Icons.delete_forever_outlined, color: Colors.red.shade700),
      title: Text(
        arabic ? 'مسح بيانات التجارب' : 'Clear Test Data',
        style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        arabic ? 'تصفير الحركات اليومية وإعادة ضبط اللوحة' : 'Reset daily entries and dashboard',
        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
      ),
      onTap: () => _confirmAndClear(context),
    ),
  );
}
