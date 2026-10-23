import 'package:drift/drift.dart';

/// Key/value app settings (SLA minutes, day cutoff) — PRD §5.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
