import 'package:drift/drift.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

final class AuditLogReader {
  const AuditLogReader(this.database);
  final AppDatabase database;

  Future<List<ResolvedAuditEntry>> readForAdmin({
    required ActorContext actor,
    required bool arabic,
    String? filterUserId,
    String? filterEntityType,
  }) async {
    if (!actor.capabilities.canViewAuditLog) {
      throw const OperationException(PermissionDenied());
    }
    final rows = await (database.select(database.auditLogs)
          ..orderBy([(r) => OrderingTerm.desc(r.deviceTime)]))
        .get();
    final users = await database.select(database.appUsers).get();
    final employees = await database.select(database.employees).get();
    final teams = await database.select(database.teams).get();

    final usersById = {for (final u in users) u.id: u.displayName};
    final employeesById = {
      for (final e in employees)
        e.iqamaNo: arabic ? e.fullNameAr : (e.fullNameEn ?? e.fullNameAr),
    };
    final teamsById = {
      for (final t in teams) t.teamId: arabic ? t.nameAr : (t.nameEn ?? t.nameAr),
    };
    final housingsById = {
      HousingConstants.defaultHousingId: arabic
          ? HousingConstants.defaultHousingNameAr
          : HousingConstants.defaultHousingName,
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
          : (usersById[row.userId!] ?? HistoryStrings.historyUnknownActor(arabic));
      final entityName = switch (row.entityType) {
        'employee' => employeesById[row.entityId],
        'team' => teamsById[row.entityId],
        'housing' => housingsById[row.entityId],
        'account' => usersById[row.entityId],
        _ => null,
      };
      result.add(ResolvedAuditEntry(
        entry: entry,
        actorDisplayName: actorName,
        entityDisplayName: entityName,
      ));
    }
    return List.unmodifiable(result);
  }
}
