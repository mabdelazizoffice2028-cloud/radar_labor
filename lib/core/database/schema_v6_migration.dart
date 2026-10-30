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
    final supplierCol = hasSupplier ? 'supplier' : 'NULL';
    final empTypeCol = hasSupplier
        ? "CASE WHEN supplier IS NOT NULL AND supplier != '' THEN 'rental' ELSE 'company' END"
        : "'company'";

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
        CASE 
          WHEN length(employee_code) >= 10 THEN substr(employee_code, 1, 10)
          ELSE printf('%010d', CAST(employee_code AS INTEGER))
        END,
        full_name_ar,
        full_name_en,
        category,
        'direct_labor',
        $empTypeCol,
        $supplierCol,
        current_team_id,
        CASE WHEN is_active = 0 THEN CAST(strftime('%s', 'now') AS INTEGER) * 1000 ELSE NULL END,
        row_version
      FROM employees
    ''');

    await database.customStatement('DROP TABLE employees');
    await database.customStatement('ALTER TABLE employees_v6 RENAME TO employees');
  }

  await migrator.createTable(database.workerHistory);
}
