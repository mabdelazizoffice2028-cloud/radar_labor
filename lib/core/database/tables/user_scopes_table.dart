import 'package:drift/drift.dart';

/// Normalized scopes (teams or housings) assigned to users.
class UserScopes extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get scopeType => text()(); // 'team' or 'housing'
  TextColumn get scopeId => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
