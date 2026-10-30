import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'conflict_test_fixture.dart';

void main() {
  final fixture = ConflictTestFixture();
  setUp(fixture.setUp);
  tearDown(fixture.tearDown);

  test('removeFromOtherTeam clears previous team and sets new team', () async {
    await fixture.saveTeamBWithW3();

    final prepA = await fixture.prepareTeamAWithGuestW3();
    await fixture.repo.save(
      actor: ConflictTestFixture.actor1, scope: ConflictTestFixture.scopeA,
      prepared: prepA, resolutions: const {'w3': ConflictResolutionChoice.removeFromOtherTeam}, arabic: true,
    );

    final events = await fixture.events.readBusinessDate('2026-04-20');
    final ledger = AttendanceLedger(events);
    expect(ledger.presentWorkerIdsForTeam('team-a'), {'w1', 'w3'});
    expect(ledger.presentWorkerIdsForTeam('team-b'), isEmpty);

    final clearEvent = events.where(
      (e) => e.employeeUid == 'w3' && e.teamId == 'team-b' && e.action == EventAction.clear,
    ).firstOrNull;
    expect(clearEvent, isNotNull);
  });

  test('skipWorker retains worker in original team and excludes from second team', () async {
    await fixture.saveTeamBWithW3();

    final prepA = await fixture.prepareTeamAWithGuestW3();
    await fixture.repo.save(
      actor: ConflictTestFixture.actor1, scope: ConflictTestFixture.scopeA,
      prepared: prepA, resolutions: const {'w3': ConflictResolutionChoice.skipWorker}, arabic: true,
    );

    final events = await fixture.events.readBusinessDate('2026-04-20');
    final ledger = AttendanceLedger(events);
    expect(ledger.presentWorkerIdsForTeam('team-b'), {'w3'});
    expect(ledger.presentWorkerIdsForTeam('team-a'), {'w1'});
  });
}
