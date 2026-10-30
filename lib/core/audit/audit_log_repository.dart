import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/audit/audit_log_reader.dart';
import 'package:radar_labor/core/audit/device_id_resolver.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:uuid/uuid.dart';

final class AuditLogRepository {
  AuditLogRepository({
    required this.database,
    this.clock = const SystemClock(),
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        _reader = AuditLogReader(database);

  final AppDatabase database;
  final Clock clock;
  final Uuid _uuid;
  final AuditLogReader _reader;

  Future<AuditEntry> record({
    required String? userId,
    required String action,
    required String entityType,
    required String entityId,
  }) async {
    final deviceId = await DeviceIdResolver(database, _uuid).resolve();
    final now = clock.nowUtc();
    final entry = AuditEntry(
      auditId: _uuid.v4(),
      userId: userId,
      action: action,
      entityType: entityType,
      entityId: entityId,
      deviceId: deviceId,
      deviceTime: now,
    );
    await database.into(database.auditLogs).insert(
      AuditLogsCompanion.insert(
        auditId: entry.auditId,
        userId: Value(entry.userId),
        action: entry.action,
        entityType: entry.entityType,
        entityId: entry.entityId,
        deviceId: entry.deviceId,
        deviceTime: entry.deviceTime,
        receivedAt: Value(entry.receivedAt),
        syncStatus: Value(entry.syncStatus),
      ),
    );
    return entry;
  }

  Future<List<ResolvedAuditEntry>> readForAdmin({
    required ActorContext actor,
    required bool arabic,
    String? filterUserId,
    String? filterEntityType,
  }) =>
      _reader.readForAdmin(
        actor: actor,
        arabic: arabic,
        filterUserId: filterUserId,
        filterEntityType: filterEntityType,
      );
}
