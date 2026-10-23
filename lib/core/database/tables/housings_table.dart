import 'package:drift/drift.dart';

class Housings extends Table {
  TextColumn get housingId => text()();
  TextColumn get nameAr => text()();
  TextColumn get nameEn => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {housingId};
}
