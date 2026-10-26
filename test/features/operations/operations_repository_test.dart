import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

import '../../support/fixed_clock.dart';

const _date = '2026-10-23';

void main() {
  late AppDatabase database;
  late OperationsRepository repository;
  late EventRepository events;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    events = EventRepository(
      database: database,
      deviceId: 'test-device',
      clock: FixedClock(DateTime.utc(2026, 10, 23, 8)),
    );
    repository = OperationsRepository(database: database, events: events);
  });

  tearDown(() => database.close());

  test(
    'housingCheck_setsAndClearsAbsencesAndUndoRestoresPreviousStateWithUserId',
    () async {
      const housing = EntityOption(id: 'housing-1', nameAr: 'سكن 1');
      await repository.saveHousingCheck(
        date: _date,
        housing: housing,
        absentIds: const {'worker-1'},
        actorUserId: 'user-housing-1',
      );
      final firstRows = await events.readBusinessDate(_date);
      expect(firstRows, hasLength(2));
      expect(firstRows.every((e) => e.userId == 'user-housing-1'), isTrue);

      final second = await repository.saveHousingCheck(
        date: _date,
        housing: housing,
        absentIds: const {},
        actorUserId: 'user-housing-1',
      );
      var rows = await events.readBusinessDate(_date);
      expect(rows.last.action, EventAction.clear);

      await repository.undoHousingCheck(second, actorUserId: 'user-housing-1');
      rows = await events.readBusinessDate(_date);
      final latestAbsence = rows.lastWhere(
        (event) => event.type == EventType.housingAbsent,
      );
      expect(latestAbsence.action, EventAction.set);
      expect(latestAbsence.userId, 'user-housing-1');
    },
  );

  test('siteAttendance_recordsZeroPresentAndUndoAsNewEvents', () async {
    const team = EntityOption(id: 'team-1', nameAr: 'فريق 1');
    final undo = await repository.saveSiteAttendance(
      date: _date,
      team: team,
      presentIds: const {},
      actorUserId: 'user-site-1',
    );
    var rows = await events.readBusinessDate(_date);
    expect(rows.single.type, EventType.siteSubmitted);
    expect(rows.single.action, EventAction.set);
    expect(rows.single.userId, 'user-site-1');

    await repository.undoSiteAttendance(undo, actorUserId: 'user-site-1');
    rows = await events.readBusinessDate(_date);
    expect(rows.last.type, EventType.siteSubmitted);
    expect(rows.last.action, EventAction.clear);
    expect(rows.last.userId, 'user-site-1');
  });

  test('appendBatch_validatesBeforeWritingAnyEvent', () async {
    await expectLater(
      events.appendBatch([
        const EventDraft(
          type: EventType.housingCheck,
          action: EventAction.set,
          businessDate: _date,
          housingId: 'housing-1',
        ),
        const EventDraft(
          type: EventType.sitePresent,
          action: EventAction.set,
          businessDate: _date,
          employeeUid: 'worker-1',
        ),
      ]),
      throwsArgumentError,
    );
    expect(await events.readBusinessDate(_date), isEmpty);
  });
}
