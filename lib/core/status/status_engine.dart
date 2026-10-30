import 'package:radar_labor/core/status/status_engine_events.dart';
import 'package:radar_labor/core/status/status_engine_worker_evaluator.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';

final RegExp _isoDatePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// Pure Dart evaluator for the worker status rules in PRD §6.
final class StatusEngine {
  const StatusEngine();

  StatusSnapshot evaluate({
    required Iterable<WorkerProfile> workers,
    required Iterable<LocalEvent> events,
    required String businessDate,
    required DateTime nowUtc,
    required int slaMinutes,
  }) {
    if (!_isoDatePattern.hasMatch(businessDate) ||
        DateTime.tryParse(businessDate) == null) {
      throw ArgumentError.value(businessDate, 'businessDate', 'must be YYYY-MM-DD');
    }
    if (slaMinutes < 0) {
      throw ArgumentError.value(slaMinutes, 'slaMinutes', 'cannot be negative');
    }

    final isFriday = isFridayBusinessDate(businessDate);
    final dayEvents = events
        .where((event) => event.businessDate == businessDate)
        .toList(growable: false);
    final effectiveEvents = StatusEngineEvents.effectiveEvents(dayEvents);
    final results = <WorkerStatusResult>[];

    for (final worker in workers) {
      results.add(
        StatusEngineWorkerEvaluator.evaluateWorker(
          worker: worker,
          dayEvents: dayEvents,
          effectiveEvents: effectiveEvents,
          businessDate: businessDate,
          nowUtc: nowUtc,
          slaMinutes: slaMinutes,
          isFriday: isFriday,
        ),
      );
    }

    return StatusSnapshot(
      businessDate: businessDate,
      workers: List.unmodifiable(results),
    );
  }
}
