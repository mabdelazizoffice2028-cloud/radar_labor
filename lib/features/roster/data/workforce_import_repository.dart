import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/account_provisioning_repository.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/roster/domain/supervisor_role_resolver.dart';
import 'package:radar_labor/features/roster/domain/workforce_row.dart';
import 'package:uuid/uuid.dart';

final class WorkforceImportResult {
  const WorkforceImportResult({
    required this.added,
    required this.updated,
    this.accountsCreated = 0,
  });
  final int added;
  final int updated;

  /// Supervisor login accounts created automatically by this import.
  final int accountsCreated;
}

/// Imports the reviewed roster atomically and preserves existing assignments.
/// Supervisors found in the file get a login account linked to their scope.
final class WorkforceImportRepository {
  const WorkforceImportRepository(this._database);
  final AppDatabase _database;

  Future<WorkforceImportResult> commit(List<WorkforceRow> rows) async {
    var added = 0;
    var updated = 0;
    var accountsCreated = 0;
    await _database.transaction(() async {
      final existingRows = await _database.select(_database.employees).get();
      final byCode = {
        for (final employee in existingRows)
          employee.employeeCode.toLowerCase(): employee,
      };
      for (final row in rows) {
        final existing = byCode[row.code.toLowerCase()];
        final category = row.designation.isEmpty ? 'Worker' : row.designation;
        final housingId = row.campus.trim().isEmpty
            ? AppConstants.defaultHousingId
            : null;
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
                  housingId: Value(housingId),
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
            housingId: housingId,
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
                housingId:
                    row.campus.trim().isEmpty && existing.housingId == null
                    ? const Value(AppConstants.defaultHousingId)
                    : const Value.absent(),
                isActive: const Value(true),
                rowVersion: Value(existing.rowVersion + 1),
              ),
            );
        updated++;
      }
      accountsCreated = await AccountProvisioningRepository(_database)
          .provisionSupervisors(_supervisorSeeds(rows, byCode));
    });
    return WorkforceImportResult(
      added: added,
      updated: updated,
      accountsCreated: accountsCreated,
    );
  }

  List<SupervisorSeed> _supervisorSeeds(
    List<WorkforceRow> rows,
    Map<String, Employee> byCode,
  ) {
    const resolver = SupervisorRoleResolver();
    return [
      for (final row in rows)
        if ((resolver.resolve(row), byCode[row.code.toLowerCase()]) case (
          final role?,
          final employee?,
        ))
          SupervisorSeed(
            employeeUid: employee.employeeUid,
            displayName: row.name,
            role: role,
            teamName: row.team,
            campusName: row.campus,
          ),
    ];
  }
}
