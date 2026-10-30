import 'package:radar_labor/app/accounts/accounts_admin_models.dart';
import 'package:radar_labor/features/roster/data/workforce_file_picker.dart';
import 'package:radar_labor/features/roster/domain/supervisor_role_resolver.dart';
import 'package:radar_labor/features/roster/domain/workforce_import_parser.dart';

/// Helper to pick and parse workforce roster for accounts admin.
final class AccountsAdminImportPicker {
  const AccountsAdminImportPicker();

  Future<ImportPreview?> pick() async {
    final file = await WorkforceFilePicker().pick();
    if (file == null) return null;
    final rows = const WorkforceImportParser().parse(
      filename: file.name,
      bytes: file.bytes,
    );
    const resolver = SupervisorRoleResolver();
    final count = rows.where((r) => resolver.resolve(r) != null).length;
    return ImportPreview(rows: rows, supervisorCount: count);
  }
}
