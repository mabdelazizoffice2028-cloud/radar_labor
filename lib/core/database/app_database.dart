import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/tables/app_users_table.dart';
import 'package:radar_labor/core/database/tables/employees_table.dart';
import 'package:radar_labor/core/database/tables/employment_periods_table.dart';
import 'package:radar_labor/core/database/tables/events_table.dart';
import 'package:radar_labor/core/database/tables/housings_table.dart';
import 'package:radar_labor/core/database/tables/settings_table.dart';
import 'package:radar_labor/core/database/tables/teams_table.dart';
import 'package:radar_labor/core/database/tables/user_scopes_table.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

/// Local encrypted source of truth for roster, employment, settings, accounts, and events.
@DriftDatabase(
  tables: [
    Settings,
    Employees,
    Teams,
    Housings,
    EmploymentPeriods,
    Events,
    AppUsers,
    UserScopes,
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
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(employees);
        await migrator.createTable(teams);
        await migrator.createTable(housings);
        await migrator.createTable(employmentPeriods);
        await migrator.createTable(events);
      }
      if (from >= 2 && from < 3) {
        await migrator.addColumn(employees, employees.supplier);
      }
      if (from < 4) {
        await migrator.createTable(appUsers);
        await migrator.createTable(userScopes);
        await _migrateLegacyJsonAccounts();
      }
    },
  );

  Future<void> _migrateLegacyJsonAccounts() async {
    try {
      final row = await (select(settings)
            ..where((s) => s.key.equals('local_accounts_v1')))
          .getSingleOrNull();
      if (row == null || row.value.isEmpty) return;

      final decoded = jsonDecode(row.value) as List<Object?>;
      const uuid = Uuid();
      final baseDate = DateTime.utc(2026, 10, 23);

      for (final item in decoded) {
        if (item is! Map<String, Object?>) continue;
        final id = item['id'] as String? ?? uuid.v4();
        final employeeUid = item['employeeUid'] as String? ?? '';
        final displayName = item['displayName'] as String? ?? 'User';
        final role = item['role'] as String? ?? 'viewer';
        final salt = item['salt'] as String? ?? '';
        final passwordHash = item['passwordHash'] as String? ?? '';
        final mustChange = item['mustChangePassword'] as bool? ?? true;
        final teamIds = (item['teamIds'] as List<Object?>?)?.map((e) => e.toString()).toList() ?? const [];
        final housingIds = (item['housingIds'] as List<Object?>?)?.map((e) => e.toString()).toList() ?? const [];

        await into(appUsers).insert(
          AppUsersCompanion.insert(
            id: id,
            employeeUid: employeeUid,
            displayName: displayName,
            role: role,
            pwHash: passwordHash,
            pwSalt: salt,
            kdfParams: '{"m":19456,"t":2,"p":1}',
            mustChange: Value(mustChange),
            failedAttempts: const Value(0),
            createdAt: baseDate,
          ),
          mode: InsertMode.insertOrReplace,
        );

        for (final tid in teamIds) {
          await into(userScopes).insert(
            UserScopesCompanion.insert(
              id: uuid.v4(),
              userId: id,
              scopeType: 'team',
              scopeId: tid,
            ),
          );
        }

        for (final hid in housingIds) {
          await into(userScopes).insert(
            UserScopesCompanion.insert(
              id: uuid.v4(),
              userId: id,
              scopeType: 'housing',
              scopeId: hid,
            ),
          );
        }
      }

      await (delete(settings)..where((s) => s.key.equals('local_accounts_v1'))).go();
    } catch (_) {}
  }
}
