import 'package:radar_labor/core/l10n/attendance_message_strings.dart';

import 'operations_models.dart';

/// Ready-to-display confirmation and copy text for a daily roster submission.
final class AttendanceSummary {
  const AttendanceSummary({
    required this.workerCount,
    required this.workerIds,
    required this.confirmationText,
    required this.messageText,
  });

  final int workerCount;
  final Set<String> workerIds;
  final String confirmationText;
  final String messageText;

  factory AttendanceSummary.housingCheck({
    required EntityOption housing,
    required String date,
    required Iterable<WorkerOption> workers,
    required Set<String> absentIds,
    required bool arabic,
    required AttendanceMessageStrings strings,
  }) {
    final selectedWorkers = _selectedWorkers(workers, absentIds, arabic);
    return _create(
      entityName: housing.displayName(arabic: arabic),
      date: date,
      countLabel: strings.absenceCount,
      selectedWorkers: selectedWorkers,
      emptyMessage: strings.noAbsences,
      emptyConfirmation: strings.confirmNoAbsences,
    );
  }

  factory AttendanceSummary.siteAttendance({
    required EntityOption team,
    required String date,
    required Iterable<WorkerOption> workers,
    required Set<String> presentIds,
    required bool arabic,
    required AttendanceMessageStrings strings,
  }) {
    final selectedWorkers = _selectedWorkers(workers, presentIds, arabic);
    return _create(
      entityName: team.displayName(arabic: arabic),
      date: date,
      countLabel: strings.presenceCount,
      selectedWorkers: selectedWorkers,
      emptyMessage: strings.noPresence,
      emptyConfirmation: strings.confirmNoPresence,
    );
  }

  static AttendanceSummary _create({
    required String entityName,
    required String date,
    required String countLabel,
    required List<({String id, String label})> selectedWorkers,
    required String emptyMessage,
    required String emptyConfirmation,
  }) {
    final workerLabels = selectedWorkers.map((worker) => worker.label).toList();
    final confirmation = workerLabels.isEmpty
        ? emptyConfirmation
        : workerLabels.join('\n');
    final messageBody = workerLabels.isEmpty
        ? emptyMessage
        : workerLabels.join('\n');
    final message =
        '$entityName\n$date\n$countLabel: ${workerLabels.length}\n$messageBody';
    return AttendanceSummary(
      workerCount: workerLabels.length,
      workerIds: Set.unmodifiable(selectedWorkers.map((worker) => worker.id)),
      confirmationText: confirmation,
      messageText: message,
    );
  }

  static List<({String id, String label})> _selectedWorkers(
    Iterable<WorkerOption> workers,
    Set<String> selectedIds,
    bool arabic,
  ) => [
    for (final worker in workers)
      if (selectedIds.contains(worker.id))
        (
          id: worker.id,
          label: '${worker.displayName(arabic: arabic)} (${worker.code})',
        ),
  ];
}
