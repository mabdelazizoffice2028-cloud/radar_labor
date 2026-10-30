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
