import 'package:radar_labor/core/status/local_event.dart';
import 'package:radar_labor/core/status/worker_profile.dart';

enum WorkerStatus { onSite, housingOnly, unknown, justified, notRecorded }

final class WorkerStatusResult {
  const WorkerStatusResult({
    required this.worker,
    required this.status,
    required this.isEligible,
    required this.flags,
    required this.isSlaBreached,
    this.teamId,
    this.housingId,
    this.housingCheckAtUtc,
  });

  final WorkerProfile worker;
  final WorkerStatus status;
  final bool isEligible;
  final Set<StatusFlag> flags;
  final bool isSlaBreached;
  final String? teamId;
  final String? housingId;
  final DateTime? housingCheckAtUtc;
}

final class StatusSnapshot {
  const StatusSnapshot({required this.businessDate, required this.workers});

  final String businessDate;
  final List<WorkerStatusResult> workers;

  int count(WorkerStatus status) => workers
      .where((worker) => worker.isEligible && worker.status == status)
      .length;

  int get eligibleCount => workers.where((worker) => worker.isEligible).length;
}
