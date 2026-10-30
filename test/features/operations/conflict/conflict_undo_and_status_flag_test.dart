import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/status/status_engine.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'conflict_test_fixture.dart';

void main() {
  final fixture = ConflictTestFixture();
  setUp(fixture.setUp);
  tearDown(fixture.tearDown);

  test('Undo restores exact previous ledger state without orphaned events', () async {
    await fixture.saveTeamBWithW3();

    final prepA = await fixture.prepareTeamAWithGuestW3();
    final savedA = await fixture.repo.save(
      actor: ConflictTestFixture.actor1, scope: ConflictTestFixture.scopeA,
      prepared: prepA, resolutions: const {'w3': ConflictResolutionChoice.removeFromOtherTeam}, arabic: true,
    );

    // Now undo team A save
    await fixture.repo.undo(
      actor: ConflictTestFixture.actor1, scope: ConflictTestFixture.scopeA,
      teamId: 'team-a', plan: savedA.undoPlan,
    );

    final events = await fixture.events.readBusinessDate('2026-04-20');
    final ledger = AttendanceLedger(events);
    expect(ledger.presentWorkerIdsForTeam('team-a'), isEmpty);
    expect(ledger.isSiteSubmitted('team-a'), isFalse);
    expect(ledger.presentWorkerIdsForTeam('team-b'), {'w3'});
  });

  test('Unresolved multiple team attendance flags worker with multipleSiteTeams', () {
    const engine = StatusEngine();
    final worker = WorkerProfile(
      employeeUid: 'w1', code: '101', fullName: 'Worker 1',
      employmentPeriods: const [EmploymentPeriod('2026-01-01')],
    );

    final events = [
      const LocalEvent(eventId: 'e1', type: EventType.sitePresent, action: EventAction.set, businessDate: '2026-04-20', deviceSeq: 1, employeeUid: 'w1', teamId: 'team-a'),
      const LocalEvent(eventId: 'e2', type: EventType.sitePresent, action: EventAction.set, businessDate: '2026-04-20', deviceSeq: 2, employeeUid: 'w1', teamId: 'team-b'),
    ];

    final snapshot = engine.evaluate(
      workers: [worker], events: events, businessDate: '2026-04-20',
      nowUtc: DateTime.utc(2026, 4, 20, 15), slaMinutes: 60,
    );

    final result = snapshot.workers.single;
    expect(result.status, WorkerStatus.onSite);
    expect(result.flags, contains(StatusFlag.multipleSiteTeams));
    expect(snapshot.count(WorkerStatus.onSite), 1);
  });
}
