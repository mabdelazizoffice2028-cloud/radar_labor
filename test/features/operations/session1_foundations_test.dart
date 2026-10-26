import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/bidi.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/time_format.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

import '../../support/fixed_clock.dart';

void main() {
  group('NameCollation & Bidi & RiyadhTimeFormat (§8.7, §9.2, §12.3)', () {
    test(
      'nameCollation_normalizesArabicVariantsAndDiacriticsAndBreaksTies',
      () {
        expect(
          NameCollation.sortKey('أَحْمَدُ إِبْرَاهِيم آدَم'),
          NameCollation.sortKey('احمد ابراهيم ادم'),
        );
        expect(
          NameCollation.sortKey('مُصْطَفَى عَطِيَّة'),
          NameCollation.sortKey('مصطفي عطيه'),
        );
        expect(
          NameCollation.sortKey('عَبْدُ اللّٰـهِ'),
          NameCollation.sortKey('عبد الله'),
        );
        expect(
          NameCollation.compareWorkers(
            nameA: 'أحمد',
            codeA: 'W-02',
            idA: 'id-2',
            nameB: 'احمد',
            codeB: 'W-01',
            idB: 'id-1',
          ),
          greaterThan(0),
        );
      },
    );

    test('riyadhTimeFormat_convertsUtcToRiyadhWithLatinDigits', () {
      expect(RiyadhTimeFormat.hhMm(DateTime.utc(2026, 10, 23, 5, 7)), '08:07');
      expect(
        RiyadhTimeFormat.hhMm(DateTime.utc(2026, 10, 23, 22, 30)),
        '01:30',
      );
    });

    test('pluralWorkersSelected_andBidiDiffFormatting', () {
      expect(
        OperationsStrings.workersSelected(true, 0),
        'لم يتم اختيار أي عامل',
      );
      expect(OperationsStrings.workersSelected(true, 1), 'تم اختيار عامل واحد');
      expect(OperationsStrings.workersSelected(true, 2), 'تم اختيار عاملين');
      expect(OperationsStrings.workersSelected(true, 5), 'تم اختيار 5 عمال');
      expect(
        OperationsStrings.workersSelected(true, 11),
        'تم اختيار 11 عاملًا',
      );
      expect(
        OperationsStrings.preSaveDiffTotal(true, 20, 2, 1),
        'الإجمالي: 20 (زيادة: ${Bidi.lri}+2${Bidi.pdi}، نقص: ${Bidi.lri}-1${Bidi.pdi})',
      );
    });
  });

  group('AttendanceLedger & LedgerUndoPlan (§6.1 & §6.3)', () {
    late AppDatabase database;
    late EventRepository events;
    late OperationsRepository repo;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      events = EventRepository(
        database: database,
        deviceId: 'dev-1',
        clock: FixedClock(DateTime.utc(2026, 10, 23, 8)),
      );
      repo = OperationsRepository(database: database, events: events);
    });

    tearDown(() => database.close());

    test(
      'ledger_tracksSetClearReSetAndCrossTeamPresenceAndUndoRestoresAll',
      () async {
        const date = '2026-10-23';
        await events.appendBatch([
          const EventDraft(
            type: EventType.sitePresent,
            action: EventAction.set,
            businessDate: date,
            employeeUid: 'w-1',
            teamId: 'team-a',
            userId: 'sup-a',
          ),
          const EventDraft(
            type: EventType.sitePresent,
            action: EventAction.set,
            businessDate: date,
            employeeUid: 'w-2',
            teamId: 'team-a',
            userId: 'sup-a',
          ),
          const EventDraft(
            type: EventType.resolution,
            action: EventAction.set,
            businessDate: date,
            employeeUid: 'w-1',
            userId: 'admin-1',
            payload: {'kind': 'official_errand'},
          ),
          const EventDraft(
            type: EventType.siteSubmitted,
            action: EventAction.set,
            businessDate: date,
            teamId: 'team-a',
            userId: 'sup-a',
          ),
        ]);

        final beforeEvents = await events.readBusinessDate(date);
        final beforeLedger = AttendanceLedger(beforeEvents);
        expect(beforeLedger.presentWorkerIdsForTeam('team-a'), {'w-1', 'w-2'});
        expect(beforeLedger.isSiteSubmitted('team-a'), isTrue);
        expect(
          beforeLedger.otherTeamPresencesForWorker(
            employeeUid: 'w-1',
            excludeTeamId: 'team-b',
          ),
          hasLength(1),
        );

        final undoPlan = LedgerUndoPlan.capture(
          businessDate: date,
          ledger: beforeLedger,
          touchedKeys: const [
            LedgerKey(
              type: EventType.sitePresent,
              employeeUid: 'w-1',
              teamId: 'team-a',
            ),
            LedgerKey(
              type: EventType.sitePresent,
              employeeUid: 'w-1',
              teamId: 'team-b',
            ),
            LedgerKey(type: EventType.resolution, employeeUid: 'w-1'),
            LedgerKey(type: EventType.siteSubmitted, teamId: 'team-b'),
          ],
        );

        await events.appendBatch([
          const EventDraft(
            type: EventType.sitePresent,
            action: EventAction.clear,
            businessDate: date,
            employeeUid: 'w-1',
            teamId: 'team-a',
            userId: 'sup-b',
            payload: {'reason': 'conflict_correction'},
          ),
          const EventDraft(
            type: EventType.sitePresent,
            action: EventAction.set,
            businessDate: date,
            employeeUid: 'w-1',
            teamId: 'team-b',
            userId: 'sup-b',
          ),
          const EventDraft(
            type: EventType.resolution,
            action: EventAction.set,
            businessDate: date,
            employeeUid: 'w-1',
            userId: 'sup-b',
            payload: {'kind': 'moved_during_day'},
          ),
          const EventDraft(
            type: EventType.siteSubmitted,
            action: EventAction.set,
            businessDate: date,
            teamId: 'team-b',
            userId: 'sup-b',
          ),
        ]);

        final midLedger = AttendanceLedger(await events.readBusinessDate(date));
        expect(midLedger.presentWorkerIdsForTeam('team-a'), {'w-2'});
        expect(midLedger.presentWorkerIdsForTeam('team-b'), {'w-1'});
        expect(midLedger.isSiteSubmitted('team-b'), isTrue);

        await repo.executeUndoPlan(undoPlan, actorUserId: 'sup-b');

        final afterLedger = AttendanceLedger(
          await events.readBusinessDate(date),
        );
        expect(afterLedger.presentWorkerIdsForTeam('team-a'), {'w-1', 'w-2'});
        expect(afterLedger.presentWorkerIdsForTeam('team-b'), isEmpty);
        expect(afterLedger.isSiteSubmitted('team-b'), isFalse);
        final restoredRes = afterLedger.activeEventFor(
          const LedgerKey(type: EventType.resolution, employeeUid: 'w-1'),
        );
        expect(restoredRes?.resolutionKind, ResolutionKind.officialErrand);
      },
    );
  });

  group('LocalSettingsRepository & OperationsController BC-3', () {
    late AppDatabase database;
    late LocalSettingsRepository settings;
    late EventRepository events;
    late OperationsRepository repo;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      settings = LocalSettingsRepository(database);
      events = EventRepository(
        database: database,
        deviceId: 'dev-1',
        clock: FixedClock(DateTime.utc(2026, 10, 23, 8)),
      );
      repo = OperationsRepository(database: database, events: events);
    });

    tearDown(() => database.close());

    test('settings_supportsDeleteAndReadKeysForDrafts', () async {
      final k1 = AppSettingKeys.draftSiteAttendance('t-1', '2026-10-23');
      final k2 = AppSettingKeys.draftSiteAttendance('t-2', '2026-10-22');
      await settings.write(k1, '{"v":1}');
      await settings.write(k2, '{"v":1}');

      final keys = await settings.readKeys();
      expect(keys, containsAll([k1, k2]));

      await settings.delete(k1);
      expect(await settings.read(k1), isNull);
      expect(await settings.readKeys(), isNot(contains(k1)));
    });

    test('operationsController_forbidsAdminAndWrongRolesFromSaving', () async {
      const team = EntityOption(id: 'team-1', nameAr: 'فريق 1');
      final adminController = OperationsController(
        store: repo,
        clock: FixedClock(DateTime.utc(2026, 10, 23, 8)),
        actorUserId: 'admin-1',
        capabilities: AuthRole.projectManager.capabilities,
        allowedTeamIds: const ['team-1'],
      );

      await expectLater(
        adminController.prepareSiteAttendance(
          team: team,
          presentIds: const {},
          arabic: true,
        ),
        throwsA(
          isA<OperationException>().having(
            (e) => e.failure,
            'failure',
            isA<PermissionDenied>(),
          ),
        ),
      );
      expect(await events.readBusinessDate('2026-10-23'), isEmpty);
    });
  });
}
