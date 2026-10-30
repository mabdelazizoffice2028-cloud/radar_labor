import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_actions_repository.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_coverage_repository.dart';

import '../../support/fixed_clock.dart';

const _date = '2026-10-23';

void main() {
  late AppDatabase database;
  late EventRepository events;
  late DashboardCoverageRepository coverage;
  late DashboardActionsRepository actions;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    events = EventRepository(
      database: database,
      deviceId: 'dashboard-test-device',
      clock: FixedClock(DateTime.utc(2026, 10, 23, 8)),
    );
    coverage = DashboardCoverageRepository(database: database, events: events);
    actions = DashboardActionsRepository(events);
  });

  tearDown(() => database.close());

  test('coverage_warnsUntilHousingAndTeamSubmitForTheSelectedDate', () async {
    await database
        .into(database.teams)
        .insert(
          TeamsCompanion.insert(
            teamId: 'team-1',
            nameAr: 'فريق ١',
            nameEn: const Value('Team 1'),
          ),
        );

    var snapshot = await coverage.watch(_date).first;
    expect(snapshot.missingHousings.single.id, HousingConstants.defaultHousingId);
    expect(snapshot.missingTeams.single.id, 'team-1');

    await events.appendBatch([
      const EventDraft(
        type: EventType.housingCheck,
        action: EventAction.set,
        businessDate: _date,
        housingId: HousingConstants.defaultHousingId,
      ),
      const EventDraft(
        type: EventType.siteSubmitted,
        action: EventAction.set,
        businessDate: _date,
        teamId: 'team-1',
      ),
    ]);
    snapshot = await coverage.watch(_date).first;
    expect(snapshot.missingHousings, isEmpty);
    expect(snapshot.missingTeams, isEmpty);

    await events.appendBatch([
      const EventDraft(
        type: EventType.housingCheck,
        action: EventAction.clear,
        businessDate: _date,
        housingId: HousingConstants.defaultHousingId,
      ),
      const EventDraft(
        type: EventType.siteSubmitted,
        action: EventAction.clear,
        businessDate: _date,
        teamId: 'team-1',
      ),
    ]);
    snapshot = await coverage.watch(_date).first;
    expect(snapshot.missingHousings, hasLength(1));
    expect(snapshot.missingTeams, hasLength(1));
  });

  test('actionsPersistTypedResolutionAndJustificationLocally', () async {
    await actions.resolve(
      employeeUid: 'worker-1',
      businessDate: _date,
      kind: ResolutionKind.movedDuringDay,
      actorUserId: 'admin-1',
      note: 'Changed work site',
    );
    await actions.justify(
      employeeUid: 'worker-1',
      businessDate: _date,
      actorUserId: 'admin-2',
      quickReason: 'official_errand',
      note: 'Site visit',
    );

    final rows = await events.readBusinessDate(_date);
    expect(rows, hasLength(2));
    expect(rows.first.type, EventType.resolution);
    expect(rows.first.resolutionKind, ResolutionKind.movedDuringDay);
    expect(rows.first.userId, 'admin-1');
    expect(rows.last.type, EventType.justification);
    expect(rows.last.userId, 'admin-2');
  });
}
