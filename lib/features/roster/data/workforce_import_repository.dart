import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/roster/domain/workforce_import_result.dart';
import 'package:radar_labor/features/roster/domain/workforce_import_validator.dart';
import 'package:radar_labor/features/roster/domain/workforce_row.dart';
import 'package:uuid/uuid.dart';

export 'package:radar_labor/features/roster/domain/workforce_import_result.dart';

final class WorkforceImportRepository {
  const WorkforceImportRepository(this._database, {this.clock = const SystemClock()});
  final AppDatabase _database;
  final Clock clock;

  Future<WorkforceImportResult> commit(List<WorkforceRow> rows) async {
    WorkforceImportValidator.validate(rows);
    var added = 0, updated = 0;
    return _database.transaction(() async {
      final existingRows = await _database.select(_database.employees).get();
      final byCode = {for (final e in existingRows) e.iqamaNo: e};
      const uuid = Uuid();
      final now = clock.nowUtc();

      for (final row in rows) {
        final iqama = row.code.trim();
        final existing = byCode[iqama];
        final cat = row.designation.isEmpty ? 'direct_labor' : row.designation;
        final empType = row.employmentType == 'rental' ? 'rental' : 'company';
        final rentalComp = row.supplier.trim().isEmpty ? null : row.supplier.trim();

        if (existing == null) {
          await _database.into(_database.employees).insert(EmployeesCompanion.insert(
            iqamaNo: iqama, fullNameAr: row.name, fullNameEn: Value(row.name),
            jobTitle: Value(cat), jobCategory: Value(cat),
            employmentType: Value(empType), rentalCompany: Value(rentalComp),
          ));
          await _database.into(_database.workerHistory).insert(WorkerHistoryCompanion.insert(
            historyId: uuid.v4(), iqamaNo: iqama, action: 'imported_create',
            details: Value('Workforce import: ${row.name}'), createdAt: now,
          ));
          added++;
        } else {
          await (_database.update(_database.employees)..where((e) => e.iqamaNo.equals(iqama))).write(
            EmployeesCompanion(
              fullNameAr: Value(row.name), fullNameEn: Value(row.name), jobTitle: Value(cat),
              rentalCompany: Value(rentalComp), employmentType: Value(empType),
              archivedAt: const Value(null), rowVersion: Value(existing.rowVersion + 1),
            ),
          );
          await _database.into(_database.workerHistory).insert(WorkerHistoryCompanion.insert(
            historyId: uuid.v4(), iqamaNo: iqama, action: 'imported_update',
            details: Value('Workforce import update: ${row.name}'), createdAt: now,
          ));
          updated++;
        }
      }
      return WorkforceImportResult(added: added, updated: updated);
    });
  }
}
