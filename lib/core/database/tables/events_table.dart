import 'package:drift/drift.dart';

@TableIndex(
  name: 'events_device_sequence_unique',
  columns: {#deviceId, #deviceSeq},
  unique: true,
)
@TableIndex(name: 'events_business_date', columns: {#businessDate})
@TableIndex(
  name: 'events_employee_business_date',
  columns: {#employeeUid, #businessDate},
)
@TableIndex(
  name: 'events_sync_sequence',
  columns: {#syncStatus, #deviceSeq},
)
class Events extends Table {
  TextColumn get eventId => text()();
  TextColumn get deviceId => text()();
  IntColumn get deviceSeq => integer()();
  TextColumn get type => text()();
  TextColumn get action => text()();
  TextColumn get businessDate => text()();
  TextColumn get employeeUid => text().nullable()();
  TextColumn get teamId => text().nullable()();
  TextColumn get housingId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  DateTimeColumn get deviceTime => dateTime()();
  DateTimeColumn get receivedAt => dateTime().nullable()();
  IntColumn get serverSeq => integer().nullable()();
  BoolColumn get late => boolean().withDefault(const Constant(false))();
  IntColumn get eventSchemaVersion =>
      integer().withDefault(const Constant(1))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get rejectReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}
