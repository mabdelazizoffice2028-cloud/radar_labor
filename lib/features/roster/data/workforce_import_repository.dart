import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/roster/domain/workforce_row.dart';
import 'package:uuid/uuid.dart';

final class WorkforceImportResult {
  const WorkforceImportResult({required this.added, required this.updated});
  final int added;
  final int updated;
}

/// Imports the reviewed roster atomically and preserves existing assignments.
final class WorkforceImportRepository {
  const WorkforceImportRepository(this._database);
  final AppDatabase _database;

  Future<WorkforceImportResult> commit(List<WorkforceRow> rows) async {
    var added = 0;
    var updated = 0;
    await _database.transaction(() async {
      final existingRows = await _database.select(_database.employees).get();
      final byCode = {
        for (final employee in existingRows)
          employee.employeeCode.toLowerCase(): employee,
      };
      for (final row in rows) {
        final existing = byCode[row.code.toLowerCase()];
        final category = row.designation.isEmpty ? 'Worker' : row.designation;
        if (existing == null) {
          final employeeUid = const Uuid().v4();
          await _database
              .into(_database.employees)
              .insert(
                EmployeesCompanion.insert(
                  employeeUid: employeeUid,
                  employeeCode: row.code,
                  fullNameAr: row.name,
                  fullNameEn: Value(row.name),
                  category: category,
                  supplier: Value(row.supplier.isEmpty ? null : row.supplier),
                ),
              );
          added++;
          byCode[row.code.toLowerCase()] = Employee(
            employeeUid: employeeUid,
            employeeCode: row.code,
            fullNameAr: row.name,
            fullNameEn: row.name,
            category: category,
            supplier: row.supplier.isEmpty ? null : row.supplier,
            currentTeamId: null,
            housingId: null,
            isActive: true,
            rowVersion: 1,
          );
          continue;
        }
        await (_database.update(_database.employees)..where(
              (employee) => employee.employeeUid.equals(existing.employeeUid),
            ))
            .write(
              EmployeesCompanion(
                fullNameAr: Value(row.name),
                fullNameEn: Value(row.name),
                category: Value(category),
                supplier: Value(row.supplier.isEmpty ? null : row.supplier),
                isActive: const Value(true),
                rowVersion: Value(existing.rowVersion + 1),
              ),
            );
        updated++;
      }
    });
    return WorkforceImportResult(added: added, updated: updated);
  }
}
