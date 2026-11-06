import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/legacy_accounts_migration.dart';
import 'package:radar_labor/core/database/schema_v6_migration.dart';

/// Central database upgrade handler across all schema versions.
Future<void> handleDatabaseUpgrade({
  required Migrator migrator,
  required int from,
  required int to,
  required AppDatabase database,
}) async {
  if (from < 2) {
    await migrator.createTable(database.employees);
    await migrator.createTable(database.teams);
    await migrator.createTable(database.employmentPeriods);
    await migrator.createTable(database.events);
  }
  if (from >= 2 && from < 3) {
    // Legacy supplier column handled in v3
  }
  if (from < 4) {
    await migrator.createTable(database.appUsers);
    await migrator.createTable(database.userScopes);
    await migrateLegacyJsonAccounts(database);
  }
  if (from < 5) {
    await migrator.createTable(database.auditLogs);
    if (from == 4) {
      await migrator.alterTable(TableMigration(database.appUsers));
    }
  }
  if (from < 6) {
    await migrateToSchemaV6(migrator: migrator, database: database);
  }
}

/// Ensures performance indexes exist on present tables without failing partial test schemas.
Future<void> ensureDatabaseIndexes(AppDatabase database) async {
  final tables = (await database.customSelect(
    "SELECT name FROM sqlite_master WHERE type = 'table'",
  ).get()).map((r) => r.read<String>('name')).toSet();

  if (tables.contains('events')) {
    await database.customStatement('CREATE INDEX IF NOT EXISTS idx_events_date_seq ON events(business_date, device_seq)');
    await database.customStatement('CREATE INDEX IF NOT EXISTS idx_events_sync_seq ON events(sync_status, device_seq)');
    await database.customStatement('CREATE INDEX IF NOT EXISTS idx_events_emp_uid ON events(employee_uid)');
  }
  if (tables.contains('employees')) {
    await database.customStatement('CREATE INDEX IF NOT EXISTS idx_employees_team ON employees(current_team_id)');
    await database.customStatement('CREATE INDEX IF NOT EXISTS idx_employees_archived ON employees(archived_at)');
  }
  if (tables.contains('user_scopes')) {
    await database.customStatement('CREATE INDEX IF NOT EXISTS idx_user_scopes_user ON user_scopes(user_id)');
  }
  if (tables.contains('audit_log')) {
    await database.customStatement('CREATE INDEX IF NOT EXISTS idx_audit_sync_time ON audit_log(sync_status, device_time)');
  }
}
