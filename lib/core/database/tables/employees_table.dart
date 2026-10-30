import 'package:drift/drift.dart';

/// Workforce registry table with 10-digit Iqama as primary key (V2 schema).
class Employees extends Table {
  TextColumn get iqamaNo => text()();
  TextColumn get fullNameAr => text()();
  TextColumn get fullNameEn => text().nullable()();
  TextColumn get jobTitle => text().nullable()();
  TextColumn get jobCategory =>
      text().withDefault(const Constant('direct_labor'))();
  TextColumn get employmentType =>
      text().withDefault(const Constant('company'))();
  TextColumn get rentalCompany => text().nullable()();
  DateTimeColumn get iqamaExpiry => dateTime().nullable()();
  TextColumn get currentTeamId => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  IntColumn get rowVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {iqamaNo};
}
