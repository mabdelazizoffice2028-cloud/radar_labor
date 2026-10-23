import 'package:drift/drift.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/tables/settings_table.dart';

part 'app_database.g.dart';

/// Local encrypted source of truth. S1 adds the events/employees tables.
@DriftDatabase(tables: [Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => DatabaseConstants.schemaVersion;
}
