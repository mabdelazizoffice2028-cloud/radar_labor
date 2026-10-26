import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_template_engine.dart';

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
      kind: WhatsappMessageKind.housing,
      entityName: housing.displayName(arabic: arabic),
      date: date,
      selectedWorkers: selectedWorkers,
      emptyConfirmation: strings.confirmNoAbsences,
      arabic: arabic,
      strings: strings,
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
      kind: WhatsappMessageKind.site,
      entityName: team.displayName(arabic: arabic),
      date: date,
      selectedWorkers: selectedWorkers,
      emptyConfirmation: strings.confirmNoPresence,
      arabic: arabic,
      strings: strings,
    );
  }

  static AttendanceSummary _create({
    required WhatsappMessageKind kind,
    required String entityName,
    required String date,
    required List<({String id, String code, String name, String label})>
    selectedWorkers,
    required String emptyConfirmation,
    required bool arabic,
    required AttendanceMessageStrings strings,
  }) {
    final workerLabels = selectedWorkers.map((worker) => worker.label).toList();
    final confirmation = workerLabels.isEmpty
        ? emptyConfirmation
        : workerLabels.join('\n');
    final message = WhatsappTemplateEngine.format(
      kind: kind,
      date: date,
      entityName: entityName,
      workers: [
        for (final worker in selectedWorkers)
          WhatsappWorkerItem(code: worker.code, name: worker.name),
      ],
      arabic: arabic,
      strings: strings,
    );
    return AttendanceSummary(
      workerCount: workerLabels.length,
      workerIds: Set.unmodifiable(selectedWorkers.map((worker) => worker.id)),
      confirmationText: confirmation,
      messageText: message,
    );
  }

  static List<({String id, String code, String name, String label})>
  _selectedWorkers(
    Iterable<WorkerOption> workers,
    Set<String> selectedIds,
    bool arabic,
  ) {
    final items = [
      for (final worker in workers)
        if (selectedIds.contains(worker.id))
          (
            id: worker.id,
            code: worker.code,
            name: worker.displayName(arabic: arabic),
            label: '${worker.displayName(arabic: arabic)} (${worker.code})',
          ),
    ];
    items.sort(
      (a, b) => NameCollation.compareWorkers(
        nameA: a.name,
        codeA: a.code,
        idA: a.id,
        nameB: b.name,
        codeB: b.code,
        idB: b.id,
      ),
    );
    return items;
  }
}
