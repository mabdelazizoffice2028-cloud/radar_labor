import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/preferences_wipe_dialog.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/features/operations/data/operations_dev_tools.dart';
import '../../support/fixed_clock.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = Directory.systemTemp.createTempSync('wipe_test_');

    // Seed employees, teams, settings, events, drafts
    await db.into(db.employees).insert(
      EmployeesCompanion.insert(
        iqamaNo: '2345678901',
        fullNameAr: 'عامل تجربة',
      ),
    );
    await db.into(db.teams).insert(
      TeamsCompanion.insert(
        teamId: 'team_alpha',
        nameAr: 'فريق ألفا',
      ),
    );
    await db.into(db.settings).insert(
      SettingsCompanion.insert(
        key: AppSettingKeys.deviceSequence,
        value: '42',
      ),
    );
    await db.into(db.settings).insert(
      SettingsCompanion.insert(
        key: '${AppSettingKeys.draftSiteAttendancePrefix}team_alpha_2026-11-06',
        value: '{"workers":[]}',
      ),
    );
    await db.into(db.events).insert(
      EventsCompanion.insert(
        eventId: 'evt_1',
        deviceId: 'dev_1',
        deviceSeq: 1,
        type: 'site_submitted',
        action: 'SUBMIT',
        businessDate: '2026-11-06',
        deviceTime: DateTime.utc(2026, 11, 6, 8),
      ),
    );
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('OperationsDevTools wipes events and drafts while preserving employees and deviceSequence', () async {
    final result = await OperationsDevTools.clearTestData(
      db,
      userId: 'admin_1',
      backupDir: tempDir,
      clock: FixedClock(DateTime.utc(2026, 11, 6, 9, 30)),
    );

    expect(result.wipedEventsCount, 1);
    expect(result.wipedDraftsCount, 1);
    expect(result.backupFilePath, contains('backup_test_data_2026-11-06_09-30-00.json'));

    // Events are wiped
    final eventsAfter = await db.select(db.events).get();
    expect(eventsAfter, isEmpty);

    // Draft settings are wiped
    final draftSettings = await (db.select(db.settings)
          ..where((s) => s.key.like('${AppSettingKeys.draftSiteAttendancePrefix}%')))
        .get();
    expect(draftSettings, isEmpty);

    // Employees are preserved
    final employeesAfter = await db.select(db.employees).get();
    expect(employeesAfter.length, 1);
    expect(employeesAfter.first.iqamaNo, '2345678901');

    // Teams are preserved
    final teamsAfter = await db.select(db.teams).get();
    expect(teamsAfter.length, 1);
    expect(teamsAfter.first.teamId, 'team_alpha');

    // deviceSequence is preserved
    final seqSetting = await (db.select(db.settings)
          ..where((s) => s.key.equals(AppSettingKeys.deviceSequence)))
        .getSingle();
    expect(seqSetting.value, '42');

    // Backup file exists on disk with valid data
    final backupFile = File(result.backupFilePath);
    expect(backupFile.existsSync(), isTrue);
    final backupJson = jsonDecode(backupFile.readAsStringSync()) as Map<String, dynamic>;
    expect(backupJson['eventsCount'], 1);
    expect(backupJson['draftsCount'], 1);
    expect((backupJson['events'] as List).first['eventId'], 'evt_1');

    // Audit log records the wipe
    final auditLogs = await db.select(db.auditLogs).get();
    expect(auditLogs.length, 1);
    expect(auditLogs.first.action, 'test_data_wiped');
    expect(auditLogs.first.entityType, 'events');
    expect(auditLogs.first.userId, 'admin_1');
    expect(auditLogs.first.entityId, contains('count:1'));
  });

  testWidgets('PreferencesWipeDialog requires exact confirmation in Arabic and English', (tester) async {
    bool? dialogResult;

    // Test Arabic
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                dialogResult = await showDialog<bool>(
                  context: ctx,
                  builder: (_) => const PreferencesWipeDialog(arabic: true),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final confirmBtnFinder = find.widgetWithText(FilledButton, 'مسح البيانات');
    expect(tester.widget<FilledButton>(confirmBtnFinder).enabled, isFalse);

    await tester.enterText(find.byType(TextField), 'مسح');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirmBtnFinder).enabled, isFalse);

    await tester.enterText(find.byType(TextField), 'مسح بيانات التجربة');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirmBtnFinder).enabled, isTrue);

    await tester.tap(confirmBtnFinder);
    await tester.pumpAndSettle();
    expect(dialogResult, isTrue);

    // Test English
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                dialogResult = await showDialog<bool>(
                  context: ctx,
                  builder: (_) => const PreferencesWipeDialog(arabic: false),
                );
              },
              child: const Text('Open En'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open En'));
    await tester.pumpAndSettle();

    final confirmBtnEnFinder = find.widgetWithText(FilledButton, 'Clear Data');
    expect(tester.widget<FilledButton>(confirmBtnEnFinder).enabled, isFalse);

    await tester.enterText(find.byType(TextField), 'clear test data');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirmBtnEnFinder).enabled, isTrue);

    await tester.tap(confirmBtnEnFinder);
    await tester.pumpAndSettle();
    expect(dialogResult, isTrue);
  });
}
