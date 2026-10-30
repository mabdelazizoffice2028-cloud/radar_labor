import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary_creator.dart';
import 'package:radar_labor/features/operations/domain/attendance_worker_selector.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_template_engine.dart';

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
    String? supervisorName,
  }) {
    final sel = AttendanceWorkerSelector.select(
      workers: workers,
      selectedIds: absentIds,
      arabic: arabic,
    );
    return AttendanceSummaryCreator.create(
      kind: WhatsappMessageKind.housing,
      entityName: housing.displayName(arabic: arabic),
      date: date,
      selectedWorkers: sel,
      emptyConfirmation: strings.confirmNoAbsences,
      arabic: arabic,
      strings: strings,
      supervisorName: supervisorName,
    );
  }

  factory AttendanceSummary.siteAttendance({
    required EntityOption team,
    required String date,
    required Iterable<WorkerOption> workers,
    required Set<String> presentIds,
    required bool arabic,
    required AttendanceMessageStrings strings,
    String? supervisorName,
  }) {
    final sel = AttendanceWorkerSelector.select(
      workers: workers,
      selectedIds: presentIds,
      arabic: arabic,
    );
    return AttendanceSummaryCreator.create(
      kind: WhatsappMessageKind.site,
      entityName: team.displayName(arabic: arabic),
      date: date,
      selectedWorkers: sel,
      emptyConfirmation: strings.confirmNoPresence,
      arabic: arabic,
      strings: strings,
      supervisorName: supervisorName,
    );
  }
}
