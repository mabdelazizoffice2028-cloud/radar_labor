import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/status/status_engine.dart';
import 'package:radar_labor/core/status/status_models.dart';

const _day = '2026-10-23';
final _now = DateTime.utc(2026, 10, 23, 14, 0, 0);

WorkerProfile _makeWorker({
  String id = 'w-1',
  String code = '101',
  bool active = true,
  String? housingId = 'h-1',
  List<EmploymentPeriod>? periods,
}) => WorkerProfile(
  employeeUid: id,
  code: code,
  fullName: 'Worker $id',
  isActive: active,
  housingId: housingId,
  employmentPeriods: periods ?? [const EmploymentPeriod('2026-01-01')],
);

LocalEvent _makeEvent({
  required EventType type,
  String id = 'ev-1',
  String? workerId = 'w-1',
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

void main() {
  group('StatusEngine additional characterization', () {
    const engine = StatusEngine();

    test('multi-worker evaluation retains exact order and isolates states', () {
      final workers = [
        _makeWorker(id: 'w-1', housingId: 'h-1'),
        _makeWorker(id: 'w-2', housingId: 'h-1'),
        _makeWorker(id: 'w-3', housingId: 'h-2'),
      ];

      final events = [
        _makeEvent(
          type: EventType.housingCheck,
          housingId: 'h-1',
          workerId: null,
          id: 'e-chk',
        ),
        _makeEvent(
          type: EventType.housingAbsent,
          housingId: 'h-1',
          workerId: 'w-1',
          id: 'e-abs',
          seq: 2,
        ),
        _makeEvent(
          type: EventType.sitePresent,
          teamId: 't-site',
          workerId: 'w-2',
          id: 'e-pres',
          seq: 3,
        ),
      ];

      final snapshot = engine.evaluate(
        workers: workers,
        events: events,
        businessDate: _day,
        nowUtc: _now,
        slaMinutes: 120,
      );

      expect(snapshot.workers.map((r) => r.worker.employeeUid).toList(), [
        'w-1',
        'w-2',
        'w-3',
      ]);

      expect(snapshot.workers[0].status, WorkerStatus.unknown);
      expect(snapshot.workers[1].status, WorkerStatus.onSite);
      expect(snapshot.workers[2].status, WorkerStatus.notRecorded);
    });

    test('housingCheck only applies to worker if housingId matches exactly', () {
      final worker = _makeWorker(id: 'w-1', housingId: 'h-correct');
      final events = [
        _makeEvent(
          type: EventType.housingCheck,
          housingId: 'h-different',
          workerId: null,
        ),
      ];

      final snapshot = engine.evaluate(
        workers: [worker],
        events: events,
        businessDate: _day,
        nowUtc: _now,
        slaMinutes: 120,
      );

      expect(snapshot.workers.single.status, WorkerStatus.notRecorded);
    });

    test('housingAbsent only applies if housingId matches worker assignment', () {
      final worker = _makeWorker(id: 'w-1', housingId: 'h-correct');
      final events = [
        _makeEvent(
          type: EventType.housingAbsent,
          housingId: 'h-different',
          workerId: 'w-1',
        ),
      ];

      final snapshot = engine.evaluate(
        workers: [worker],
        events: events,
        businessDate: _day,
        nowUtc: _now,
        slaMinutes: 120,
      );

      expect(snapshot.workers.single.status, WorkerStatus.notRecorded);
    });

    test('worker without housingId ignores housingCheck and housingAbsent', () {
      final worker = _makeWorker(id: 'w-1', housingId: null);
      final events = [
        _makeEvent(
          type: EventType.housingCheck,
          housingId: 'h-1',
          workerId: null,
        ),
        _makeEvent(
          type: EventType.housingAbsent,
          housingId: 'h-1',
          workerId: 'w-1',
          seq: 2,
        ),
      ];

      final snapshot = engine.evaluate(
        workers: [worker],
        events: events,
        businessDate: _day,
        nowUtc: _now,
        slaMinutes: 120,
      );

      expect(snapshot.workers.single.status, WorkerStatus.notRecorded);
    });

    test('employment periods boundaries characterization', () {
      final pastOnly = _makeWorker(
        id: 'w-past',
        periods: [
          const EmploymentPeriod('2026-01-01', endDate: '2026-10-22'),
        ],
      );
      final futureOnly = _makeWorker(
        id: 'w-future',
        periods: [
          const EmploymentPeriod('2026-10-24'),
        ],
      );
      final spanning = _makeWorker(
        id: 'w-active',
        periods: [
          const EmploymentPeriod('2026-10-01', endDate: '2026-10-31'),
        ],
      );

      final snapshot = engine.evaluate(
        workers: [pastOnly, futureOnly, spanning],
        events: const [],
        businessDate: _day,
        nowUtc: _now,
        slaMinutes: 120,
      );

      expect(snapshot.workers[0].isEligible, isFalse);
      expect(snapshot.workers[1].isEligible, isFalse);
      expect(snapshot.workers[2].isEligible, isTrue);
    });

    test('sla with zero minutes breaches immediately if time elapsed', () {
      final checkAt = _now.subtract(const Duration(seconds: 1));
      final worker = _makeWorker(id: 'w-1', housingId: 'h-1');
      final events = [
        _makeEvent(
          type: EventType.housingCheck,
          housingId: 'h-1',
          receivedAt: checkAt,
          workerId: null,
        ),
        _makeEvent(
          type: EventType.housingAbsent,
          housingId: 'h-1',
          workerId: 'w-1',
          seq: 2,
        ),
      ];

      final snapshot = engine.evaluate(
        workers: [worker],
        events: events,
        businessDate: _day,
        nowUtc: _now,
        slaMinutes: 0,
      );

      expect(snapshot.workers.single.status, WorkerStatus.unknown);
      expect(snapshot.workers.single.isSlaBreached, isTrue);
    });

    test('resolutionKind other also clears housingSiteConflict flag', () {
      final worker = _makeWorker(id: 'w-1', housingId: 'h-1');
      final events = [
        _makeEvent(
          type: EventType.housingAbsent,
          housingId: 'h-1',
          workerId: 'w-1',
          id: 'e-1',
          seq: 1,
        ),
        _makeEvent(
          type: EventType.sitePresent,
          teamId: 'team-a',
          workerId: 'w-1',
          id: 'e-2',
          seq: 2,
        ),
        _makeEvent(
          type: EventType.resolution,
          workerId: 'w-1',
          id: 'e-3',
          seq: 3,
          resolutionKind: ResolutionKind.siteError,
        ),
      ];

      final snapshot = engine.evaluate(
        workers: [worker],
        events: events,
        businessDate: _day,
        nowUtc: _now,
        slaMinutes: 120,
      );

      expect(snapshot.workers.single.status, WorkerStatus.onSite);
      expect(
        snapshot.workers.single.flags,
        isNot(contains(StatusFlag.housingSiteConflict)),
      );
    });
  });
}
