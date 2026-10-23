import 'package:drift/drift.dart';

@TableIndex.sql(
  'CREATE UNIQUE INDEX employees_employee_code ON employees(employee_code COLLATE NOCASE)',
)
class Employees extends Table {
  TextColumn get employeeUid => text()();
  TextColumn get employeeCode => text()();
  TextColumn get fullNameAr => text()();
  TextColumn get fullNameEn => text().nullable()();
  TextColumn get category => text()();
  TextColumn get supplier => text().nullable()();
  TextColumn get currentTeamId => text().nullable()();
  TextColumn get housingId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get rowVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {employeeUid};
}
