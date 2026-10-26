import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:uuid/uuid.dart';

/// Repository for writing and reading append-only audit log entries (PRD §17.4, §23.5, D-26).
final class AuditLogRepository {
  AuditLogRepository({
    required this.database,
    this.clock = const SystemClock(),
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase database;
  final Clock clock;
  final Uuid _uuid;

  /// Appends an audit row inside the caller's active transaction (or standalone if none).
  Future<AuditEntry> record({
    required String? userId,
    required String action,
    required String entityType,
    required String entityId,
  }) async {
    final deviceId = await _resolveDeviceId();
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
    await database
        .into(database.auditLogs)
        .insert(
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

  /// Reads audit entries with resolved actor/entity names; restricted to admins (PRD §23.5).
  Future<List<ResolvedAuditEntry>> readForAdmin({
    required ActorContext actor,
    required bool arabic,
    String? filterUserId,
    String? filterEntityType,
  }) async {
    if (!actor.capabilities.canViewAuditLog) {
      throw const OperationException(PermissionDenied());
    }

    final rows = await (database.select(
      database.auditLogs,
    )..orderBy([(r) => OrderingTerm.desc(r.deviceTime)])).get();
    final users = await database.select(database.appUsers).get();
    final employees = await database.select(database.employees).get();
    final teams = await database.select(database.teams).get();
    final housings = await database.select(database.housings).get();

    final usersById = {for (final u in users) u.id: u.displayName};
    final employeesById = {
      for (final e in employees)
        e.employeeUid: arabic ? e.fullNameAr : (e.fullNameEn ?? e.fullNameAr),
    };
    final teamsById = {
      for (final t in teams)
        t.teamId: arabic ? t.nameAr : (t.nameEn ?? t.nameAr),
    };
    final housingsById = {
      for (final h in housings)
        h.housingId: arabic ? h.nameAr : (h.nameEn ?? h.nameAr),
    };

    final result = <ResolvedAuditEntry>[];
    for (final row in rows) {
      if (filterUserId != null && row.userId != filterUserId) continue;
      if (filterEntityType != null && row.entityType != filterEntityType) {
        continue;
      }
      final entry = AuditEntry(
        auditId: row.auditId,
        userId: row.userId,
        action: row.action,
        entityType: row.entityType,
        entityId: row.entityId,
        deviceId: row.deviceId,
        deviceTime: row.deviceTime,
        receivedAt: row.receivedAt,
        syncStatus: row.syncStatus,
      );
      final actorName = row.userId == null
          ? HistoryStrings.historyUnknownActor(arabic)
          : (usersById[row.userId!] ??
                HistoryStrings.historyUnknownActor(arabic));
      final entityName = switch (row.entityType) {
        'employee' => employeesById[row.entityId],
        'team' => teamsById[row.entityId],
        'housing' => housingsById[row.entityId],
        'account' => usersById[row.entityId],
        _ => null,
      };
      result.add(
        ResolvedAuditEntry(
          entry: entry,
          actorDisplayName: actorName,
          entityDisplayName: entityName,
        ),
      );
    }
    return List.unmodifiable(result);
  }

  Future<String> _resolveDeviceId() async {
    final row = await (database.select(
      database.settings,
    )..where((s) => s.key.equals(AppSettingKeys.deviceId))).getSingleOrNull();
    if (row != null && row.value.isNotEmpty) return row.value;
    final generated = _uuid.v4();
    await database
        .into(database.settings)
        .insert(
          SettingsCompanion.insert(
            key: AppSettingKeys.deviceId,
            value: generated,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return generated;
  }
}
