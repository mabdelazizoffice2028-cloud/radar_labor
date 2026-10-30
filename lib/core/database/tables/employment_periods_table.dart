import 'package:drift/drift.dart';

@TableIndex(
  name: 'employment_period_iqama_start',
  columns: {#iqamaNo, #startDate},
)
class EmploymentPeriods extends Table {
  TextColumn get periodId => text()();
  TextColumn get iqamaNo => text()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {periodId};
}
