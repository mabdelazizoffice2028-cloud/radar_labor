import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';

/// Performs migration to schema version 6 (V2 workforce & decryption).
Future<void> migrateToSchemaV6({
  required Migrator migrator,
  required AppDatabase database,
}) async {
  await database.customStatement('DROP TABLE IF EXISTS housings');

  final info = await database.customSelect('PRAGMA table_info(employees)').get();
  final hasIqama = info.any((r) => r.read<String>('name') == 'iqama_no');

  if (!hasIqama) {
    final hasSupplier = info.any((r) => r.read<String>('name') == 'supplier');
    final hasEmpUid = info.any((r) => r.read<String>('name') == 'employee_uid');
    final supplierCol = hasSupplier ? 'supplier' : 'NULL';
    final empTypeCol = hasSupplier
        ? "CASE WHEN supplier IS NOT NULL AND supplier != '' THEN 'rental' ELSE 'company' END"
        : "'company'";
    const iqamaExpr = '''
      CASE
        WHEN length(employee_code) >= 10 THEN substr(employee_code, 1, 10)
        WHEN CAST(employee_code AS INTEGER) > 0 THEN printf('%010d', CAST(employee_code AS INTEGER))
        ELSE printf('%010d', rowid)
      END
    ''';

    await database.customStatement('''
      CREATE TABLE employees_v6 (
        iqama_no TEXT NOT NULL PRIMARY KEY,
        full_name_ar TEXT NOT NULL,
        full_name_en TEXT,
        job_title TEXT,
        job_category TEXT NOT NULL DEFAULT 'direct_labor',
        employment_type TEXT NOT NULL DEFAULT 'company',
        rental_company TEXT,
        iqama_expiry INTEGER,
        current_team_id TEXT,
        archived_at INTEGER,
        row_version INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await database.customStatement('''
      INSERT OR IGNORE INTO employees_v6 (
        iqama_no, full_name_ar, full_name_en, job_title, job_category,
        employment_type, rental_company, current_team_id, archived_at, row_version
      )
      SELECT
        $iqamaExpr, full_name_ar, full_name_en, category, 'direct_labor',
        $empTypeCol, $supplierCol, current_team_id,
        CASE WHEN is_active = 0 THEN CAST(strftime('%s', 'now') AS INTEGER) * 1000 ELSE NULL END,
        row_version
      FROM employees
    ''');

    final tables = (await database.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    ).get()).map((r) => r.read<String>('name')).toSet();

    if (hasEmpUid && tables.contains('events')) {
      await database.customStatement('''
        UPDATE events SET employee_uid = (
          SELECT $iqamaExpr FROM employees WHERE employees.employee_uid = events.employee_uid
        ) WHERE employee_uid IN (SELECT employee_uid FROM employees)
      ''');
    }
    if (hasEmpUid && tables.contains('app_users')) {
      await database.customStatement('''
        UPDATE app_users SET employee_uid = (
          SELECT $iqamaExpr FROM employees WHERE employees.employee_uid = app_users.employee_uid
        ) WHERE employee_uid IN (SELECT employee_uid FROM employees)
      ''');
    }

    await database.customStatement('DROP TABLE employees');
    await database.customStatement('ALTER TABLE employees_v6 RENAME TO employees');
  }

  final epInfo = await database.customSelect('PRAGMA table_info(employment_periods)').get();
  if (epInfo.isNotEmpty && !epInfo.any((r) => r.read<String>('name') == 'iqama_no')) {
    await database.customStatement('DROP TABLE employment_periods');
    await migrator.createTable(database.employmentPeriods);
  }

  await migrator.createTable(database.workerHistory);
}
