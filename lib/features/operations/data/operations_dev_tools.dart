import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/operations_dev_tools_backup.dart';
import 'package:radar_labor/features/operations/domain/test_data_wipe_result.dart';

final class OperationsDevTools {
  const OperationsDevTools._();

  static Future<TestDataWipeResult> clearTestData(
    AppDatabase database, {
    String? userId,
    Directory? backupDir,
    AuditLogRepository? auditRepo,
    Clock clock = const SystemClock(),
  }) async {
    final now = clock.nowUtc();
    final events = await database.select(database.events).get();
    final drafts = await (database.select(database.settings)
          ..where((s) =>
              s.key.like('${AppSettingKeys.draftSiteAttendancePrefix}%') |
              s.key.like('${AppSettingKeys.draftHousingCheckPrefix}%')))
        .get();

    final targetDir = await OperationsDevToolsBackup.resolveDir(backupDir);
    if (!targetDir.existsSync()) targetDir.createSync(recursive: true);
    final fileName = OperationsDevToolsBackup.formatFileName(now);
    final backupFile = File(p.join(targetDir.path, fileName));
    final payload = jsonEncode({
      'version': 1,
      'createdAt': now.toIso8601String(),
      'actorUserId': userId,
      'eventsCount': events.length,
      'draftsCount': drafts.length,
      'events': [for (final e in events) e.toJson()],
      'drafts': [for (final d in drafts) d.toJson()],
    });
    backupFile.writeAsStringSync(payload, flush: true);

    await database.transaction(() async {
      await database.customStatement('DELETE FROM events');
      await database.customStatement(
        "DELETE FROM settings WHERE key LIKE '${AppSettingKeys.draftSiteAttendancePrefix}%' OR key LIKE '${AppSettingKeys.draftHousingCheckPrefix}%'",
      );
    });

    final audit =
        auditRepo ?? AuditLogRepository(database: database, clock: clock);
    await audit.record(
      userId: userId,
      action: 'test_data_wiped',
      entityType: 'events',
      entityId: 'count:${events.length}|backup:${backupFile.path}',
    );

    return TestDataWipeResult(
      wipedEventsCount: events.length,
      wipedDraftsCount: drafts.length,
      backupFilePath: backupFile.path,
      wipedAt: now,
    );
  }
}
