import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/attendance_worker_selector.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_template_engine.dart';

final class AttendanceSummaryCreator {
  static AttendanceSummary create({
    required WhatsappMessageKind kind,
    required String entityName,
    required String date,
    required List<SelectedWorkerItem> selectedWorkers,
    required String emptyConfirmation,
    required bool arabic,
    required AttendanceMessageStrings strings,
    String? supervisorName,
  }) {
    final workerLabels = selectedWorkers.map((w) => w.label).toList();
    final confirmation =
        workerLabels.isEmpty ? emptyConfirmation : workerLabels.join('\n');
    final message = WhatsappTemplateEngine.format(
      kind: kind,
      date: date,
      entityName: entityName,
      workers: [
        for (final w in selectedWorkers)
          WhatsappWorkerItem(
            code: w.code,
            name: w.name,
            employmentType: w.employmentType,
            jobCategory: w.jobCategory,
          ),
      ],
      arabic: arabic,
      strings: strings,
      supervisorName: supervisorName,
    );
    return AttendanceSummary(
      workerCount: workerLabels.length,
      workerIds: Set.unmodifiable(selectedWorkers.map((w) => w.id)),
      confirmationText: confirmation,
      messageText: message,
    );
  }
}
