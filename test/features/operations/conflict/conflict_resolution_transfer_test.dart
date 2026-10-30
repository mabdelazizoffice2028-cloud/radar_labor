import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'conflict_test_fixture.dart';

void main() {
  final fixture = ConflictTestFixture();
  setUp(fixture.setUp);
  tearDown(fixture.tearDown);

  test('transferDuringDay retains worker in both teams with movedDuringDay event', () async {
    // 1. Team B registers w3
    await fixture.saveTeamBWithW3();

    // 2. Team A claims w3 as guest -> Conflict detected!
    final prepA = await fixture.prepareTeamAWithGuestW3();
    expect(prepA.conflicts.length, 1);
    expect(prepA.conflicts.single.worker.id, 'w3');
    expect(prepA.conflicts.single.otherTeamId, 'team-b');

    // Saving without resolutions throws OperationException
    expect(
      () => fixture.repo.save(
        actor: ConflictTestFixture.actor1, scope: ConflictTestFixture.scopeA,
        prepared: prepA, resolutions: const {}, arabic: true,
      ),
      throwsA(isA<OperationException>()),
    );

    // 3. Resolve with transferDuringDay
    await fixture.repo.save(
      actor: ConflictTestFixture.actor1, scope: ConflictTestFixture.scopeA,
      prepared: prepA, resolutions: const {'w3': ConflictResolutionChoice.transferDuringDay}, arabic: true,
    );

    // Verify worker is present in BOTH teams and resolution event emitted
    final events = await fixture.events.readBusinessDate('2026-04-20');
    final ledger = AttendanceLedger(events);
    expect(ledger.presentWorkerIdsForTeam('team-a'), {'w1', 'w3'});
    expect(ledger.presentWorkerIdsForTeam('team-b'), {'w3'});

    final resEvent = events.where((e) => e.type == EventType.resolution && e.employeeUid == 'w3').firstOrNull;
    expect(resEvent, isNotNull);
    expect(resEvent?.resolutionKind, ResolutionKind.movedDuringDay);
  });
}
