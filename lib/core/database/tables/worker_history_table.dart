import 'package:drift/drift.dart';

/// Append-only movement history tracking worker changes (V2).
@TableIndex(name: 'worker_history_iqama_idx', columns: {#iqamaNo})
@TableIndex(name: 'worker_history_created_at_idx', columns: {#createdAt})
class WorkerHistory extends Table {
  TextColumn get historyId => text()();
  TextColumn get iqamaNo => text()();
  TextColumn get action => text()();
  TextColumn get details => text().withDefault(const Constant('{}'))();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {historyId};
}
