import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';

import '../../support/fixed_clock.dart';

const _date = '2026-10-23';
const _yesterday = '2026-10-22';

void main() {
  late AppDatabase database;
  late EventRepository repository;
  final fixedNow = DateTime.utc(2026, 10, 23, 10, 0, 0);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = EventRepository(
      database: database,
      deviceId: 'device-test-01',
      clock: FixedClock(fixedNow),
    );
  });

  tearDown(() => database.close());

  group('EventRepository characterization', () {
    test('append_singleDraft_createsEventAndIncrementsSequence', () async {
      const draft = EventDraft(
        type: EventType.housingCheck,
        action: EventAction.set,
        businessDate: _date,
        housingId: 'house-101',
        userId: 'admin-1',
      );

      final event = await repository.append(draft);

      expect(event.deviceSeq, 1);
      expect(event.type, EventType.housingCheck);
      expect(event.action, EventAction.set);
      expect(event.businessDate, _date);
      expect(event.housingId, 'house-101');
      expect(event.isLate, isFalse);
      expect(event.deviceTimeUtc, fixedNow);

      final seqRow = await (database.select(database.settings)
            ..where((s) => s.key.equals(AppSettingKeys.deviceSequence)))
          .getSingle();
      expect(seqRow.value, '1');

      final stored = await repository.readBusinessDate(_date);
      expect(stored, hasLength(1));
      expect(stored.single.eventId, event.eventId);
    });

    test('append_marksLate_whenBusinessDateDiffersFromCurrentCutoff', () async {
      const draft = EventDraft(
        type: EventType.housingCheck,
        action: EventAction.set,
        businessDate: _yesterday,
        housingId: 'house-101',
      );

      final event = await repository.append(draft);
      expect(event.isLate, isTrue);
    });

    test('appendBatch_atomicallyAssignsIncreasingSequence', () async {
      final drafts = [
        const EventDraft(
          type: EventType.housingCheck,
          action: EventAction.set,
          businessDate: _date,
          housingId: 'house-1',
        ),
        const EventDraft(
          type: EventType.housingAbsent,
          action: EventAction.set,
          businessDate: _date,
          employeeUid: 'emp-1',
          housingId: 'house-1',
        ),
        const EventDraft(
          type: EventType.sitePresent,
          action: EventAction.set,
          businessDate: _date,
          employeeUid: 'emp-1',
          teamId: 'team-a',
        ),
      ];

      final events = await repository.appendBatch(drafts);

      expect(events, hasLength(3));
      expect(events.map((e) => e.deviceSeq), [1, 2, 3]);

      final seqRow = await (database.select(database.settings)
            ..where((s) => s.key.equals(AppSettingKeys.deviceSequence)))
          .getSingle();
      expect(seqRow.value, '3');
    });

    test('appendBatch_rollsBackEntirelyIfAnyDraftIsInvalid', () async {
      final drafts = [
        const EventDraft(
          type: EventType.housingCheck,
          action: EventAction.set,
          businessDate: _date,
          housingId: 'house-1',
        ),
        const EventDraft(
          type: EventType.sitePresent,
          action: EventAction.set,
          businessDate: _date,
          employeeUid: 'emp-1',
          // Missing teamId!
        ),
      ];

      await expectLater(
        repository.appendBatch(drafts),
        throwsArgumentError,
      );

      final stored = await repository.readBusinessDate(_date);
      expect(stored, isEmpty);

      final seqRow = await (database.select(database.settings)
            ..where((s) => s.key.equals(AppSettingKeys.deviceSequence)))
          .getSingleOrNull();
      expect(seqRow, isNull);
    });

    test('resumesSequenceFromExistingSettings', () async {
      await database.into(database.settings).insert(
            SettingsCompanion.insert(
              key: AppSettingKeys.deviceSequence,
              value: '10',
            ),
          );

      final event = await repository.append(
        const EventDraft(
          type: EventType.housingCheck,
          action: EventAction.set,
          businessDate: _date,
          housingId: 'house-1',
        ),
      );

      expect(event.deviceSeq, 11);
    });

    test('throwsStateErrorIfSequenceSettingIsCorrupted', () async {
      await database.into(database.settings).insert(
            SettingsCompanion.insert(
              key: AppSettingKeys.deviceSequence,
              value: 'corrupted_string',
            ),
          );

      await expectLater(
        repository.append(
          const EventDraft(
            type: EventType.housingCheck,
            action: EventAction.set,
            businessDate: _date,
            housingId: 'house-1',
          ),
        ),
        throwsStateError,
      );
    });

    test('validatesDateStringFormat', () async {
      await expectLater(
        repository.append(
          const EventDraft(
            type: EventType.housingCheck,
            action: EventAction.set,
            businessDate: '2026-13-45', // invalid date
            housingId: 'house-1',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('parsesResolutionKindFromPayload', () async {
      final event = await repository.append(
        const EventDraft(
          type: EventType.resolution,
          action: EventAction.set,
          businessDate: _date,
          employeeUid: 'emp-1',
          payload: {'kind': 'housing_error'},
        ),
      );

      expect(event.resolutionKind, ResolutionKind.housingError);
    });

    test('watchBusinessDate_streamsUpdatesForGivenDateOnly', () async {
      final stream = repository.watchBusinessDate(_date);

      final initial = await stream.first;
      expect(initial, isEmpty);

      await repository.append(
        const EventDraft(
          type: EventType.housingCheck,
          action: EventAction.set,
          businessDate: _date,
          housingId: 'house-1',
        ),
      );
      await repository.append(
        const EventDraft(
          type: EventType.housingCheck,
          action: EventAction.set,
          businessDate: _yesterday,
          housingId: 'house-yesterday',
        ),
      );

      final updated = await repository.readBusinessDate(_date);
      expect(updated, hasLength(1));
      expect(updated.single.housingId, 'house-1');

      final yesterdayEvents = await repository.readBusinessDate(_yesterday);
      expect(yesterdayEvents, hasLength(1));
      expect(yesterdayEvents.single.housingId, 'house-yesterday');
    });
  });
}
