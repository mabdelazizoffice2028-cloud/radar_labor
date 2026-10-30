import 'package:drift/drift.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/database_migrations.dart';
import 'package:radar_labor/core/database/tables/app_users_table.dart';
import 'package:radar_labor/core/database/tables/audit_log_table.dart';
import 'package:radar_labor/core/database/tables/employees_table.dart';
import 'package:radar_labor/core/database/tables/employment_periods_table.dart';
import 'package:radar_labor/core/database/tables/events_table.dart';
import 'package:radar_labor/core/database/tables/settings_table.dart';
import 'package:radar_labor/core/database/tables/teams_table.dart';
import 'package:radar_labor/core/database/tables/user_scopes_table.dart';
import 'package:radar_labor/core/database/tables/worker_history_table.dart';

export 'package:radar_labor/core/database/tables/employee_compat_extensions.dart';

part 'app_database.g.dart';

/// Local source of truth for workforce roster, accounts, events, and audit logs.
@DriftDatabase(
  tables: [
    Settings,
    Employees,
    Teams,
    EmploymentPeriods,
    Events,
    AppUsers,
    UserScopes,
    AuditLogs,
    WorkerHistory,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => DatabaseConstants.schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) => handleDatabaseUpgrade(
      migrator: migrator,
      from: from,
      to: to,
      database: this,
    ),
  );
}
