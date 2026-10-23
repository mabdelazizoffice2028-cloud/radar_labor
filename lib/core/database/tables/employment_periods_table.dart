import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/tables/employees_table.dart';

@TableIndex(
  name: 'employment_period_employee_start',
  columns: {#employeeUid, #startDate},
)
class EmploymentPeriods extends Table {
  TextColumn get periodId => text()();
  TextColumn get employeeUid =>
      text().references(Employees, #employeeUid, onDelete: KeyAction.cascade)();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {periodId};
}
