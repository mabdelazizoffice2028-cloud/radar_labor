import 'package:drift/drift.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/tables/employees_table.dart';
import 'package:radar_labor/core/database/tables/employment_periods_table.dart';
import 'package:radar_labor/core/database/tables/events_table.dart';
import 'package:radar_labor/core/database/tables/housings_table.dart';
import 'package:radar_labor/core/database/tables/settings_table.dart';
import 'package:radar_labor/core/database/tables/teams_table.dart';

part 'app_database.g.dart';

/// Local encrypted source of truth for roster, employment, settings, and events.
@DriftDatabase(
  tables: [Settings, Employees, Teams, Housings, EmploymentPeriods, Events],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => DatabaseConstants.schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(employees);
        await migrator.createTable(teams);
        await migrator.createTable(housings);
        await migrator.createTable(employmentPeriods);
        await migrator.createTable(events);
      }
    },
  );
}
