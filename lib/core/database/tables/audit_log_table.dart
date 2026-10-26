import 'package:drift/drift.dart';

/// Append-only audit log table for administrative and supervisory reference changes (PRD §23.5, D-26).
class AuditLogs extends Table {
  @override
  String get tableName => 'audit_log';

  TextColumn get auditId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get deviceId => text()();
  DateTimeColumn get deviceTime => dateTime()();
  DateTimeColumn get receivedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {auditId};
}
