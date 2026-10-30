import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/status/status_engine.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/status/worker_summary_calculator.dart';
import 'package:radar_labor/core/time/friday_resolver.dart';

void main() {
  const friday = '2026-10-23'; // Friday
  WorkerProfile worker(String id, {String cat = 'direct_labor', String? housingId = 'h1'}) => WorkerProfile(
    employeeUid: id, code: id, fullName: 'Worker $id', jobCategory: cat, housingId: housingId,
    employmentPeriods: const [EmploymentPeriod('2026-01-01')],
  );

  test('FridayResolver correctly detects Fridays', () {
    expect(FridayResolver.isFriday('2026-10-23'), isTrue);
    expect(FridayResolver.isFriday('2026-10-24'), isFalse);
    expect(FridayResolver.isFriday('invalid'), isFalse);
  });

  test('StatusEngine on Friday enforces Zero-Absence and Overtime rules', () {
    const engine = StatusEngine();
    final events = [
      const LocalEvent(eventId: 'e1', type: EventType.sitePresent, action: EventAction.set, businessDate: friday, deviceSeq: 1, employeeUid: 'w1', teamId: 't1'),
      const LocalEvent(eventId: 'e2', type: EventType.housingAbsent, action: EventAction.set, businessDate: friday, deviceSeq: 2, employeeUid: 'w2', housingId: 'h1'),
    ];

    final snapshot = engine.evaluate(
      workers: [worker('w1'), worker('w2'), worker('s1', cat: 'Site Engineer')],
      events: events, businessDate: friday,
      nowUtc: DateTime.utc(2026, 10, 23, 15, 0), slaMinutes: 60,
    );

    expect(snapshot.workers.firstWhere((r) => r.worker.employeeUid == 'w1').status, WorkerStatus.onSite);
    expect(snapshot.workers.firstWhere((r) => r.worker.employeeUid == 'w2').status, WorkerStatus.notRecorded);
    expect(snapshot.workers.firstWhere((r) => r.worker.employeeUid == 's1').status, WorkerStatus.notRecorded);
    expect(snapshot.count(WorkerStatus.unknown), 0);
    expect(snapshot.count(WorkerStatus.housingOnly), 0);
    expect(snapshot.workers.any((r) => r.isSlaBreached), isFalse);
  });

  test('WorkerSummaryCalculator counts Friday overtime as worked with 0 absences', () {
    final events = [
      const LocalEvent(eventId: 'e1', type: EventType.sitePresent, action: EventAction.set, businessDate: friday, deviceSeq: 1, employeeUid: 'w1', teamId: 't1'),
      const LocalEvent(eventId: 'e2', type: EventType.housingAbsent, action: EventAction.set, businessDate: friday, deviceSeq: 2, employeeUid: 'w2'),
    ];

    final sumW1 = WorkerSummaryCalculator.calculate(
      employeeUid: 'w1', jobCategory: 'direct_labor', allEvents: events, leaves: [], teamNamesById: {'t1': 'Team A'},
    );
    expect(sumW1.totalDaysWorked, 1);
    expect(sumW1.totalDaysAbsent, 0);

    final sumW2 = WorkerSummaryCalculator.calculate(
      employeeUid: 'w2', jobCategory: 'direct_labor', allEvents: events, leaves: [], teamNamesById: {},
    );
    expect(sumW2.totalDaysWorked, 0);
    expect(sumW2.totalDaysAbsent, 0);
  });
}
