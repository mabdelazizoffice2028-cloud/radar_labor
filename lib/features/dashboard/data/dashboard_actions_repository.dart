import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';

/// Writes administrator explanations and conflict resolutions as new events.
final class DashboardActionsRepository {
  const DashboardActionsRepository(this.events);

  final EventRepository events;

  Future<void> justify({
    required String employeeUid,
    required String businessDate,
    required String actorUserId,
    String? quickReason,
    String? note,
  }) => events.append(
    EventDraft(
      type: EventType.justification,
      action: EventAction.set,
      businessDate: businessDate,
      employeeUid: employeeUid,
      userId: actorUserId,
      payload: {
        if (quickReason?.isNotEmpty ?? false) 'quick': quickReason,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    ),
  );

  Future<void> resolve({
    required String employeeUid,
    required String businessDate,
    required ResolutionKind kind,
    required String actorUserId,
    String? note,
  }) => events.append(
    EventDraft(
      type: EventType.resolution,
      action: EventAction.set,
      businessDate: businessDate,
      employeeUid: employeeUid,
      userId: actorUserId,
      payload: {
        'kind': kind.key,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    ),
  );
}
