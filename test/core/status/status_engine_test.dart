import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/status/status_engine.dart';
import 'package:radar_labor/core/status/status_models.dart';

const _day = '2026-10-22';
final _now = DateTime.utc(2026, 10, 22, 12);

WorkerProfile _worker({
  String id = 'worker-1',
  bool active = true,
  List<EmploymentPeriod>? periods,
  String? housingId = 'house-1',
}) => WorkerProfile(
  employeeUid: id,
  code: '001',
  fullName: 'Worker',
  isActive: active,
  housingId: housingId,
  employmentPeriods: periods ?? [const EmploymentPeriod('2026-01-01')],
);

LocalEvent _event(
  EventType type, {
  String id = 'e1',
  String workerId = 'worker-1',
  EventAction action = EventAction.set,
  String date = _day,
  String? teamId,
  String? housingId,
  int seq = 1,
  DateTime? receivedAt,
  EventDelivery delivery = EventDelivery.pending,
  bool late = false,
  ResolutionKind? resolutionKind,
}) => LocalEvent(
  eventId: id,
  employeeUid: workerId,
  type: type,
  action: action,
  businessDate: date,
  teamId: teamId,
  housingId: housingId,
  deviceSeq: seq,
  receivedAtUtc: receivedAt ?? _now,
  delivery: delivery,
  isLate: late,
  resolutionKind: resolutionKind,
);

WorkerStatusResult _evaluate(
  List<LocalEvent> events, {
  WorkerProfile? worker,
  String date = _day,
  DateTime? now,
  int slaMinutes = 120,
}) => StatusEngine()
    .evaluate(
      workers: [worker ?? _worker()],
      events: events,
      businessDate: date,
      nowUtc: now ?? _now,
      slaMinutes: slaMinutes,
    )
    .workers
    .single;

void main() {
  group('worker status rules', () {
    test('noEvents_isNotRecorded', () {
      expect(_evaluate([]).status, WorkerStatus.notRecorded);
    });

    test('sitePresent_isOnSite', () {
      final result = _evaluate([
        _event(EventType.sitePresent, teamId: 'team-a'),
      ]);
      expect(result.status, WorkerStatus.onSite);
      expect(result.teamId, 'team-a');
    });

    test('housingCheck_isHousingOnly', () {
      expect(
        _evaluate([_event(EventType.housingCheck, housingId: 'house-1')])
            .status,
        WorkerStatus.housingOnly,
      );
    });

    test('housingAbsent_isUnknown', () {
      expect(
        _evaluate([_event(EventType.housingAbsent, housingId: 'house-1')])
            .status,
        WorkerStatus.unknown,
      );
    });

    test('housingAbsentWithJustification_isJustified', () {
      expect(
        _evaluate([
          _event(EventType.housingAbsent, housingId: 'house-1'),
          _event(EventType.justification, id: 'e2', seq: 2),
        ]).status,
        WorkerStatus.justified,
      );
    });

    test('sitePresentWinsAndFlagsHousingConflict', () {
      final result = _evaluate([
        _event(EventType.housingAbsent, housingId: 'house-1'),
        _event(EventType.sitePresent, id: 'e2', teamId: 'team-a', seq: 2),
      ]);
      expect(result.status, WorkerStatus.onSite);
      expect(result.flags, contains(StatusFlag.housingSiteConflict));
    });

    test('multipleActiveTeams_flagContradictionAndChooseLatest', () {
      final result = _evaluate([
        _event(EventType.sitePresent, teamId: 'team-a'),
        _event(
          EventType.sitePresent,
          id: 'e2',
          teamId: 'team-b',
          seq: 2,
          receivedAt: _now.add(const Duration(minutes: 1)),
        ),
      ]);
      expect(result.status, WorkerStatus.onSite);
      expect(result.teamId, 'team-b');
      expect(result.flags, contains(StatusFlag.multipleSiteTeams));
    });

    test('activeResolution_clearsConflictFlagWithoutChangingStatus', () {
      final result = _evaluate([
        _event(EventType.housingAbsent, housingId: 'house-1'),
        _event(EventType.sitePresent, id: 'e2', teamId: 'team-a', seq: 2),
        _event(
          EventType.resolution,
          id: 'e3',
          seq: 3,
          resolutionKind: ResolutionKind.housingError,
        ),
      ]);
      expect(result.status, WorkerStatus.onSite);
      expect(result.flags, isNot(contains(StatusFlag.housingSiteConflict)));
    });

    test('movedDuringDayResolution_clearsMultipleTeamFlag', () {
      final result = _evaluate([
        _event(EventType.sitePresent, teamId: 'team-a'),
        _event(EventType.sitePresent, id: 'e2', teamId: 'team-b', seq: 2),
        _event(
          EventType.resolution,
          id: 'e3',
          seq: 3,
          resolutionKind: ResolutionKind.movedDuringDay,
        ),
      ]);
      expect(result.status, WorkerStatus.onSite);
      expect(result.flags, isNot(contains(StatusFlag.multipleSiteTeams)));
    });

    test('clearedResolution_restoresConflictFlag', () {
      final result = _evaluate([
        _event(EventType.housingAbsent, housingId: 'house-1'),
        _event(EventType.sitePresent, id: 'e2', teamId: 'team-a', seq: 2),
        _event(
          EventType.resolution,
          id: 'e3',
          seq: 3,
          resolutionKind: ResolutionKind.housingError,
        ),
        _event(
          EventType.resolution,
          id: 'e4',
          action: EventAction.clear,
          seq: 4,
          resolutionKind: ResolutionKind.housingError,
        ),
      ]);
      expect(result.flags, contains(StatusFlag.housingSiteConflict));
    });

    test('clearedSitePresence_doesNotRemainOnSite', () {
      final result = _evaluate([
        _event(EventType.sitePresent, teamId: 'team-a'),
        _event(
          EventType.sitePresent,
          id: 'e2',
          action: EventAction.clear,
          teamId: 'team-a',
          seq: 2,
        ),
      ]);
      expect(result.status, WorkerStatus.notRecorded);
    });

    test('clearedAbsence_fallsBackToHousingCheck', () {
      expect(
        _evaluate([
          _event(EventType.housingCheck, housingId: 'house-1'),
          _event(EventType.housingAbsent, housingId: 'house-1'),
          _event(
            EventType.housingAbsent,
            id: 'e3',
            action: EventAction.clear,
            housingId: 'house-1',
            seq: 3,
          ),
        ]).status,
        WorkerStatus.housingOnly,
      );
    });

    test('clearedHousingCheck_doesNotCountAsHousingOnly', () {
      expect(
        _evaluate([
          _event(EventType.housingCheck, housingId: 'house-1'),
          _event(
            EventType.housingCheck,
            id: 'e2',
            action: EventAction.clear,
            housingId: 'house-1',
            seq: 2,
          ),
        ]).status,
        WorkerStatus.notRecorded,
      );
    });

    test('clearedJustification_returnsToUnknown', () {
      expect(
        _evaluate([
          _event(EventType.housingAbsent, housingId: 'house-1'),
          _event(EventType.justification, id: 'e2', seq: 2),
          _event(
            EventType.justification,
            id: 'e3',
            action: EventAction.clear,
            seq: 3,
          ),
        ]).status,
        WorkerStatus.unknown,
      );
    });

    test('newerSetReactivatesAKeyAfterClear', () {
      expect(
        _evaluate([
          _event(EventType.sitePresent, teamId: 'team-a'),
          _event(
            EventType.sitePresent,
            id: 'e2',
            action: EventAction.clear,
            teamId: 'team-a',
            seq: 2,
          ),
          _event(EventType.sitePresent, id: 'e3', teamId: 'team-a', seq: 3),
        ]).status,
        WorkerStatus.onSite,
      );
    });

    test('newerClearWinsOverPriorSet', () {
      expect(
        _evaluate([
          _event(EventType.sitePresent, teamId: 'team-a'),
          _event(
            EventType.sitePresent,
            id: 'e2',
            action: EventAction.clear,
            teamId: 'team-a',
            seq: 2,
          ),
        ]).status,
        WorkerStatus.notRecorded,
      );
    });

    test('receivedAtOrdersBeforeSequence', () {
      final later = _event(
        EventType.sitePresent,
        id: 'later',
        teamId: 'team-b',
        seq: 1,
        receivedAt: _now.add(const Duration(minutes: 2)),
        delivery: EventDelivery.acked,
      );
      final earlier = _event(
        EventType.sitePresent,
        id: 'earlier',
        teamId: 'team-a',
        seq: 99,
        receivedAt: _now,
        delivery: EventDelivery.acked,
      );
      expect(_evaluate([later, earlier]).teamId, 'team-b');
    });

    test('deviceSequenceBreaksReceivedAtTie', () {
      expect(
        _evaluate([
          _event(EventType.sitePresent, teamId: 'team-a', seq: 1),
          _event(EventType.sitePresent, id: 'e2', teamId: 'team-b', seq: 2),
        ]).teamId,
        'team-b',
      );
    });

    test('localPendingEventOrdersAfterAcknowledgedEvent', () {
      expect(
        _evaluate([
          _event(
            EventType.sitePresent,
            teamId: 'team-a',
            seq: 99,
            delivery: EventDelivery.acked,
          ),
          _event(
            EventType.sitePresent,
            id: 'e2',
            teamId: 'team-b',
            seq: 1,
            delivery: EventDelivery.pending,
          ),
        ]).teamId,
        'team-b',
      );
    });

    test('otherHousingCheck_doesNotApplyToWorker', () {
      expect(
        _evaluate([_event(EventType.housingCheck, housingId: 'house-2')])
            .status,
        WorkerStatus.notRecorded,
      );
    });

    test('absenceForOtherHousing_doesNotApplyToWorker', () {
      expect(
        _evaluate([_event(EventType.housingAbsent, housingId: 'house-2')])
            .status,
        WorkerStatus.notRecorded,
      );
    });

    test('slaBreach_requiresUnknownAndElapsedBeyondLimit', () {
      final checkedAt = _now.subtract(const Duration(minutes: 121));
      final result = _evaluate([
        _event(
          EventType.housingCheck,
          housingId: 'house-1',
          receivedAt: checkedAt,
        ),
        _event(EventType.housingAbsent, housingId: 'house-1', id: 'e2'),
      ], now: _now);
      expect(result.status, WorkerStatus.unknown);
      expect(result.isSlaBreached, isTrue);
    });

    test('slaAtExactLimit_isNotBreached', () {
      final result = _evaluate([
        _event(
          EventType.housingCheck,
          housingId: 'house-1',
          receivedAt: _now.subtract(const Duration(minutes: 120)),
        ),
        _event(EventType.housingAbsent, housingId: 'house-1', id: 'e2'),
      ]);
      expect(result.isSlaBreached, isFalse);
    });

    test('futureHousingCheck_doesNotBreachSla', () {
      final result = _evaluate([
        _event(
          EventType.housingCheck,
          housingId: 'house-1',
          receivedAt: _now.add(const Duration(minutes: 5)),
        ),
        _event(EventType.housingAbsent, housingId: 'house-1', id: 'e2'),
      ]);
      expect(result.isSlaBreached, isFalse);
    });

    test('unknownWithoutHousingCheck_hasNoSlaTimer', () {
      final result = _evaluate([
        _event(EventType.housingAbsent, housingId: 'house-1'),
      ]);
      expect(result.status, WorkerStatus.unknown);
      expect(result.isSlaBreached, isFalse);
    });

    test('inactiveRosterEntry_isExcludedFromCounts', () {
      final result = _evaluate([], worker: _worker(active: false));
      expect(result.isEligible, isFalse);
      expect(result.status, WorkerStatus.notRecorded);
    });

    test('inactiveWorkerWithEvent_isFlagged', () {
      final result = _evaluate([
        _event(EventType.sitePresent, teamId: 'team-a'),
      ], worker: _worker(active: false));
      expect(result.flags, contains(StatusFlag.inactiveWorkerEvent));
      expect(result.isEligible, isFalse);
    });

    test('outsideEmploymentPeriod_isExcluded', () {
      final result = _evaluate(
        [],
        worker: _worker(periods: [const EmploymentPeriod('2026-10-24')]),
      );
      expect(result.isEligible, isFalse);
    });

    test('eventBeforeEmployment_isFlagged', () {
      final result = _evaluate([
        _event(EventType.sitePresent, teamId: 'team-a'),
      ], worker: _worker(periods: [const EmploymentPeriod('2026-10-24')]));
      expect(result.flags, contains(StatusFlag.eventOutsideEmployment));
    });

    test('secondEmploymentPeriod_isEligible', () {
      final result = _evaluate(
        [],
        worker: _worker(
          periods: [
            const EmploymentPeriod('2026-01-01', endDate: '2026-06-30'),
            const EmploymentPeriod('2026-10-01'),
          ],
        ),
      );
      expect(result.isEligible, isTrue);
    });

    test('otherEmployeeEvents_areIgnored', () {
      expect(
        _evaluate([
          _event(EventType.sitePresent, workerId: 'worker-2', teamId: 'team-a'),
        ]).status,
        WorkerStatus.notRecorded,
      );
    });

    test('otherBusinessDateEvents_areIgnored', () {
      expect(
        _evaluate([
          _event(EventType.sitePresent, date: '2026-10-21', teamId: 'team-a'),
        ]).status,
        WorkerStatus.notRecorded,
      );
    });

    test('lateEvent_isFlagged', () {
      final result = _evaluate([
        _event(EventType.sitePresent, teamId: 'team-a', late: true),
      ]);
      expect(result.flags, contains(StatusFlag.lateEvent));
    });

    test('rejectedEvent_isFlaggedAndNotApplied', () {
      final result = _evaluate([
        _event(
          EventType.sitePresent,
          teamId: 'team-a',
          delivery: EventDelivery.rejected,
        ),
      ]);
      expect(result.status, WorkerStatus.notRecorded);
      expect(result.flags, contains(StatusFlag.rejectedEvent));
    });

    test('siteSubmissionWithoutEmployee_doesNotCreateWorkerStatus', () {
      final result = _evaluate([
        LocalEvent(
          eventId: 'submit',
          type: EventType.siteSubmitted,
          action: EventAction.set,
          businessDate: _day,
          teamId: 'team-a',
          deviceSeq: 1,
          receivedAtUtc: _now,
        ),
      ]);
      expect(result.status, WorkerStatus.notRecorded);
    });

    test('clearedStatusEventForUnknownDate_doesNotLeakIntoCurrentDate', () {
      expect(
        _evaluate([
          _event(EventType.sitePresent, date: '2026-10-21', teamId: 'team-a'),
          _event(
            EventType.sitePresent,
            id: 'clear',
            action: EventAction.clear,
            date: _day,
            teamId: 'team-a',
          ),
        ]).status,
        WorkerStatus.notRecorded,
      );
    });

    test('resultsRemainInRosterOrder', () {
      final snapshot = StatusEngine().evaluate(
        workers: [
          _worker(id: 'second'),
          _worker(id: 'first'),
        ],
        events: const [],
        businessDate: _day,
        nowUtc: _now,
        slaMinutes: 120,
      );
      expect(snapshot.workers.map((result) => result.worker.employeeUid), [
        'second',
        'first',
      ]);
    });

    test('businessDateMustUseIsoFormat', () {
      expect(
        () => StatusEngine().evaluate(
          workers: const [],
          events: const [],
          businessDate: '23/10/2026',
          nowUtc: _now,
          slaMinutes: 120,
        ),
        throwsArgumentError,
      );
    });
  });
}
