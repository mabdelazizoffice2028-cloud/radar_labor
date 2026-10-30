import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/status/status_engine.dart';
import 'package:radar_labor/core/status/status_models.dart';

void main() {
  group('StatusEngine with Staff and Leaves', () {
    const engine = StatusEngine();
    final now = DateTime.utc(2026, 10, 26, 10, 0); // Monday

    test('Staff is auto-present on site on regular day without events', () {
      const staff = WorkerProfile(
        employeeUid: 'e-1', code: 'W1', fullName: 'Engineer Ali',
        employmentPeriods: [], jobCategory: 'Site Engineer',
      );
      final snapshot = engine.evaluate(
        workers: [staff], events: [], businessDate: '2026-10-26', nowUtc: now, slaMinutes: 120,
      );
      expect(snapshot.workers.single.status, WorkerStatus.onSite);
      expect(snapshot.workers.single.isEligible, isTrue);
    });

    test('Staff with housingAbsent event becomes unknown unless justified', () {
      const staff = WorkerProfile(
        employeeUid: 'e-1', code: 'W1', fullName: 'Engineer Ali',
        employmentPeriods: [], jobCategory: 'Safety Officer',
      );
      const absentEvt = LocalEvent(
        eventId: 'ev-1', type: EventType.housingAbsent, action: EventAction.set,
        businessDate: '2026-10-26', deviceSeq: 1, employeeUid: 'e-1',
      );
      final res1 = engine.evaluate(
        workers: [staff], events: [absentEvt], businessDate: '2026-10-26', nowUtc: now, slaMinutes: 120,
      );
      expect(res1.workers.single.status, WorkerStatus.unknown);

      const justEvt = LocalEvent(
        eventId: 'ev-2', type: EventType.justification, action: EventAction.set,
        businessDate: '2026-10-26', deviceSeq: 2, employeeUid: 'e-1',
      );
      final res2 = engine.evaluate(
        workers: [staff], events: [absentEvt, justEvt], businessDate: '2026-10-26', nowUtc: now, slaMinutes: 120,
      );
      expect(res2.workers.single.status, WorkerStatus.justified);
    });

    test('Worker on leave is not eligible and excluded from absences', () {
      const onLeave = WorkerProfile(
        employeeUid: 'e-2', code: 'W2', fullName: 'Vacation Worker',
        employmentPeriods: [], isOnLeave: true,
      );
      final snapshot = engine.evaluate(
        workers: [onLeave], events: [], businessDate: '2026-10-26', nowUtc: now, slaMinutes: 120,
      );
      expect(snapshot.workers.single.isEligible, isFalse);
      expect(snapshot.workers.single.status, WorkerStatus.notRecorded);
      expect(snapshot.count(WorkerStatus.unknown), 0);
    });
  });
}
