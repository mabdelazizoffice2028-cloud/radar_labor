import 'package:radar_labor/core/status/status_models.dart';

final class EventDraft {
  const EventDraft({
    required this.type,
    required this.action,
    required this.businessDate,
    this.employeeUid,
    this.teamId,
    this.housingId,
    this.userId,
    this.payload = const {},
  });

  final EventType type;
  final EventAction action;
  final String businessDate;
  final String? employeeUid;
  final String? teamId;
  final String? housingId;
  final String? userId;
  final Map<String, Object?> payload;
}
