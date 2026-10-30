import 'dart:convert';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/leaves/worker_leave.dart';

final class LeaveRepository {
  const LeaveRepository({
    required this.settings,
    required this.audit,
  });

  final LocalSettingsRepository settings;
  final AuditLogRepository audit;

  Future<List<WorkerLeave>> readAll() async => _parse(await settings.read(AppSettingKeys.workerLeaves));

  Stream<List<WorkerLeave>> watchAll() =>
      settings.watch(AppSettingKeys.workerLeaves).map(_parse);

  Future<Set<String>> onLeaveWorkerIdsForDate(String businessDate) async {
    final all = await readAll();
    return all.where((l) => l.coversDate(businessDate)).map((l) => l.employeeUid).toSet();
  }

  Future<void> addLeave(WorkerLeave leave) async {
    if (leave.endDate.compareTo(leave.startDate) < 0) {
      throw ArgumentError('endDate cannot be before startDate');
    }
    final cur = await readAll();
    final updated = [...cur.where((l) => l.leaveId != leave.leaveId), leave];
    await settings.write(
      AppSettingKeys.workerLeaves,
      jsonEncode(updated.map((l) => l.toJson()).toList()),
    );
    await audit.record(
      userId: leave.createdByUserId,
      action: 'leave_created',
      entityType: 'leave',
      entityId: leave.leaveId,
    );
  }

  Future<void> deleteLeave(String leaveId, {required String actorUserId}) async {
    final cur = await readAll();
    final updated = cur.where((l) => l.leaveId != leaveId).toList();
    await settings.write(
      AppSettingKeys.workerLeaves,
      jsonEncode(updated.map((l) => l.toJson()).toList()),
    );
    await audit.record(
      userId: actorUserId,
      action: 'leave_deleted',
      entityType: 'leave',
      entityId: leaveId,
    );
  }

  static List<WorkerLeave> _parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => WorkerLeave.fromJson(e as Map<String, dynamic>)).toList();
    } on Exception {
      return const [];
    }
  }
}
