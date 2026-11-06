import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/backup/database_backup_models.dart';
import 'package:radar_labor/features/operations/data/backup/database_backup_service.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

final class _TestClock implements Clock {
  const _TestClock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 11, 6, 9);
}

void main() {
  late AppDatabase db;
  late AuditLogRepository audit;
  late DatabaseBackupService service;
  const clock = _TestClock();

  final adminActor = ActorContext(
    userId: 'admin_1',
    role: AuthRole.projectManager,
  );

  final viewerActor = ActorContext(
    userId: 'viewer_1',
    role: AuthRole.viewer,
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    audit = AuditLogRepository(database: db, clock: clock);
    service = DatabaseBackupService(database: db, audit: audit);

    // Seed test data
    await db.into(db.settings).insert(
      SettingsCompanion.insert(key: AppSettingKeys.deviceSequence, value: '42'),
    );
    await db.into(db.teams).insert(
      TeamsCompanion.insert(teamId: 'team_alpha', nameAr: 'فريق ألفا'),
    );
    await db.into(db.employees).insert(
      EmployeesCompanion.insert(
        iqamaNo: '1000000001',
        fullNameAr: 'أحمد علي',
        currentTeamId: const Value('team_alpha'),
      ),
    );
    await db.into(db.appUsers).insert(
      AppUsersCompanion.insert(
        id: 'u1',
        displayName: 'User 1',
        role: 'housingSupervisor',
        pwHash: 'hash',
        pwSalt: 'salt',
        kdfParams: '{}',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    await db.into(db.userScopes).insert(
      UserScopesCompanion.insert(
        id: 'scope_1',
        userId: 'u1',
        scopeType: 'housing',
        scopeId: 'main_housing',
      ),
    );
    await db.into(db.events).insert(
      EventsCompanion.insert(
        eventId: 'ev_1',
        deviceId: 'dev_1',
        deviceSeq: 1,
        type: 'sitePresent',
        action: 'set',
        businessDate: '2026-11-06',
        deviceTime: DateTime.utc(2026, 11, 6, 8),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('DatabaseBackupService', () {
    test('exports comprehensive JSON with schema version and all tables', () async {
      final jsonStr = await service.exportBackupJson(actor: adminActor);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded['formatVersion'], 1);
      expect(decoded['dbSchemaVersion'], db.schemaVersion);
      expect(decoded['timestamp'], isNotEmpty);
      expect(decoded['settings'], hasLength(1));
      expect(decoded['teams'], hasLength(1));
      expect(decoded['employees'], hasLength(1));
      expect(decoded['appUsers'], hasLength(1));
      expect(decoded['userScopes'], hasLength(1));
      expect(decoded['events'], hasLength(1));
    });

    test('denies export and restore to unauthorized actors', () async {
      expect(
        () => service.exportBackupJson(actor: viewerActor),
        throwsA(isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<PermissionDenied>(),
        )),
      );

      expect(
        () => service.restoreBackupJson(
          actor: viewerActor,
          jsonStr: '{}',
          confirmationText: 'استعادة نسخة احتياطية',
        ),
        throwsA(isA<OperationException>().having(
          (e) => e.failure,
          'failure',
          isA<PermissionDenied>(),
        )),
      );
    });

    test('validates pre-restore JSON schema and confirmation text', () async {
      final jsonStr = await service.exportBackupJson(actor: adminActor);

      // Invalid confirmation text
      expect(
        () => service.restoreBackupJson(
          actor: adminActor,
          jsonStr: jsonStr,
          confirmationText: 'wrong text',
        ),
        throwsA(isA<BackupValidationException>()),
      );

      // Corrupted JSON
      expect(
        () => service.restoreBackupJson(
          actor: adminActor,
          jsonStr: 'not a json',
          confirmationText: 'استعادة نسخة احتياطية',
        ),
        throwsA(isA<BackupValidationException>()),
      );

      // Missing formatVersion
      final badPayload = jsonEncode({'dbSchemaVersion': 6, 'settings': []});
      expect(
        () => service.restoreBackupJson(
          actor: adminActor,
          jsonStr: badPayload,
          confirmationText: 'استعادة نسخة احتياطية',
        ),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('restores data atomically with relational integrity', () async {
      final jsonStr = await service.exportBackupJson(actor: adminActor);

      // Now mutate/wipe DB
      await db.delete(db.events).go();
      await db.delete(db.userScopes).go();
      await db.delete(db.appUsers).go();
      await db.delete(db.employees).go();
      await db.delete(db.teams).go();
      await db.delete(db.settings).go();

      expect(await db.select(db.employees).get(), isEmpty);
      expect(await db.select(db.events).get(), isEmpty);

      // Restore
      await service.restoreBackupJson(
        actor: adminActor,
        jsonStr: jsonStr,
        confirmationText: 'استعادة نسخة احتياطية',
      );

      // Verify restored content
      final employees = await db.select(db.employees).get();
      expect(employees, hasLength(1));
      expect(employees.single.iqamaNo, '1000000001');
      expect(employees.single.currentTeamId, 'team_alpha');

      final events = await db.select(db.events).get();
      expect(events, hasLength(1));
      expect(events.single.eventId, 'ev_1');

      final settings = await db.select(db.settings).get();
      final seqSetting = settings.firstWhere((s) => s.key == AppSettingKeys.deviceSequence);
      expect(seqSetting.value, '42');
    });
  });
}
