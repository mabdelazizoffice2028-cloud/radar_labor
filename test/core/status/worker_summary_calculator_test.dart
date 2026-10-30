import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/leaves/worker_leave.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/status/worker_summary_calculator.dart';

void main() {
  group('WorkerSummaryCalculator', () {
    test('counts justified absences inside totalDaysWorked and NOT totalDaysAbsent', () {
      final events = [
        const LocalEvent(eventId: '1', type: EventType.housingAbsent, action: EventAction.set, businessDate: '2026-10-26', deviceSeq: 1, employeeUid: 'w1'),
        const LocalEvent(eventId: '2', type: EventType.justification, action: EventAction.set, businessDate: '2026-10-26', deviceSeq: 2, employeeUid: 'w1'),
        const LocalEvent(eventId: '3', type: EventType.housingAbsent, action: EventAction.set, businessDate: '2026-10-27', deviceSeq: 3, employeeUid: 'w1'),
        const LocalEvent(eventId: '4', type: EventType.sitePresent, action: EventAction.set, businessDate: '2026-10-28', deviceSeq: 4, employeeUid: 'w1', teamId: 't1'),
      ];

      final summary = WorkerSummaryCalculator.calculate(
        employeeUid: 'w1', jobCategory: 'direct_labor', allEvents: events, leaves: [], teamNamesById: {'t1': 'Concrete Team'},
      );

      expect(summary.totalDaysWorked, 2); // 2026-10-26 (justified) + 2026-10-28 (sitePresent)
      expect(summary.totalDaysAbsent, 1); // 2026-10-27 (unexcused absent)
      expect(summary.teamHistory.single.teamName, 'Concrete Team');
      expect(summary.teamHistory.single.days, 1);
    });

    test('excludes business dates covered by WorkerLeave', () {
      final events = [
        const LocalEvent(eventId: '1', type: EventType.housingAbsent, action: EventAction.set, businessDate: '2026-10-26', deviceSeq: 1, employeeUid: 'w1'),
        const LocalEvent(eventId: '2', type: EventType.sitePresent, action: EventAction.set, businessDate: '2026-10-27', deviceSeq: 2, employeeUid: 'w1', teamId: 't1'),
      ];
      final leave = const WorkerLeave(leaveId: 'l1', employeeUid: 'w1', startDate: '2026-10-26', endDate: '2026-10-26');

      final summary = WorkerSummaryCalculator.calculate(
        employeeUid: 'w1', jobCategory: 'direct_labor', allEvents: events, leaves: [leave], teamNamesById: {'t1': 'Concrete Team'},
      );

      expect(summary.totalDaysAbsent, 0); // Oct 26 covered by leave, so absence excluded!
      expect(summary.totalDaysWorked, 1); // Oct 27 worked
      expect(summary.activeLeaves.single.leaveId, 'l1');
    });

    test('auto-present Staff counts as worked when no absence event exists', () {
      final summary = WorkerSummaryCalculator.calculate(
        employeeUid: 's1', jobCategory: 'Site Engineer',
        allEvents: [
          const LocalEvent(eventId: '1', type: EventType.housingCheck, action: EventAction.set, businessDate: '2026-10-26', deviceSeq: 1),
        ],
        leaves: [], teamNamesById: {},
      );

      expect(summary.totalDaysWorked, 1);
      expect(summary.totalDaysAbsent, 0);
    });
  });
}
