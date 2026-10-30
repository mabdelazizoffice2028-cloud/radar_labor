import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/leaves/leave_repository.dart';
import 'package:radar_labor/core/leaves/worker_leave.dart';

void main() {
  group('LeaveRepository & Retroactive Leaves', () {
    late AppDatabase db;
    late LocalSettingsRepository settings;
    late AuditLogRepository audit;
    late LeaveRepository leavesRepo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      settings = LocalSettingsRepository(db);
      audit = AuditLogRepository(database: db);
      leavesRepo = LeaveRepository(settings: settings, audit: audit);
    });

    tearDown(() => db.close());

    test('addLeave, onLeaveWorkerIdsForDate, and deleteLeave', () async {
      const leave = WorkerLeave(
        leaveId: 'leave-1', employeeUid: 'emp-99',
        startDate: '2026-10-20', endDate: '2026-10-25',
        createdByUserId: 'admin-1', note: 'Annual vacation',
      );

      await leavesRepo.addLeave(leave);

      final all = await leavesRepo.readAll();
      expect(all.length, 1);
      expect(all.first.employeeUid, 'emp-99');

      // Date inside leave window
      final onLeaveMid = await leavesRepo.onLeaveWorkerIdsForDate('2026-10-22');
      expect(onLeaveMid, contains('emp-99'));

      // Date outside leave window
      final onLeaveAfter = await leavesRepo.onLeaveWorkerIdsForDate('2026-10-26');
      expect(onLeaveAfter, isNot(contains('emp-99')));

      // Deleting leave
      await leavesRepo.deleteLeave('leave-1', actorUserId: 'admin-1');
      final remaining = await leavesRepo.readAll();
      expect(remaining, isEmpty);
    });

    test('addLeave rejects invalid date range', () async {
      const invalidLeave = WorkerLeave(
        leaveId: 'bad-1', employeeUid: 'emp-1',
        startDate: '2026-10-25', endDate: '2026-10-20',
      );
      expect(() => leavesRepo.addLeave(invalidLeave), throwsArgumentError);
    });
  });
}
