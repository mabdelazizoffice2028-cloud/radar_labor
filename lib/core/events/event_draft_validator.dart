import 'package:radar_labor/core/events/event_draft.dart';
import 'package:radar_labor/core/status/status_models.dart';

abstract final class EventDraftValidator {
  static void validate(EventDraft draft) {
    if (!isValidDate(draft.businessDate)) {
      throw ArgumentError.value(
        draft.businessDate,
        'businessDate',
        'must be a real YYYY-MM-DD date',
      );
    }
    final isValid = switch (draft.type) {
      EventType.housingCheck =>
        draft.housingId != null && draft.housingId!.isNotEmpty,
      EventType.housingAbsent =>
        draft.employeeUid != null && draft.housingId != null,
      EventType.sitePresent =>
        draft.employeeUid != null && draft.teamId != null,
      EventType.siteSubmitted => draft.teamId != null,
      EventType.justification ||
      EventType.resolution => draft.employeeUid != null,
    };
    if (!isValid) {
      throw ArgumentError.value(
        draft.type,
        'type',
        'does not contain the required employee, team, or housing key',
      );
    }
  }

  static bool isValidDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return false;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime.utc(year, month, day);
    return date.year == year && date.month == month && date.day == day;
  }
}
