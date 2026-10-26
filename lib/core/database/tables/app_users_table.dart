import 'package:drift/drift.dart';

/// Local authenticated users stored in the encrypted database (BC-7: employeeUid is nullable for viewer).
class AppUsers extends Table {
  TextColumn get id => text()();
  TextColumn get employeeUid => text().nullable()();
  TextColumn get displayName => text()();
  TextColumn get role => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get pwHash => text()();
  TextColumn get pwSalt => text()();
  TextColumn get kdfParams => text()();
  BoolColumn get mustChange => boolean().withDefault(const Constant(true))();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedUntil => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
