import 'package:drift/drift.dart';

class Teams extends Table {
  TextColumn get teamId => text()();
  TextColumn get nameAr => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get supervisorUserId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {teamId};
}
