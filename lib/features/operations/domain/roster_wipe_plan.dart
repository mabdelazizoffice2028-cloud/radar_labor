import 'package:radar_labor/features/operations/domain/operation_failure.dart';

/// Input row for audited workforce import and reactivation by employee code (PRD §23.4, D-29).
final class RosterImportEntry {
  const RosterImportEntry({
    required this.code,
    required this.name,
    this.designation = 'Worker',
    this.supplier = '',
  });

  final String code;
  final String name;
  final String designation;
  final String supplier;
}

final class RosterImportResult {
  const RosterImportResult({required this.added, required this.updated});
  final int added;
  final int updated;
}

/// Pure, testable plan for executing an administrative workforce roster wipe (PRD §17.4, §23.4, D-24, D-25).
final class RosterWipePlan {
  const RosterWipePlan({
    required this.previousEpoch,
    required this.nextEpoch,
    required this.employeeUidsToArchive,
    required this.employeeUidsToUnassignTeam,
  });

  final int previousEpoch;
  final int nextEpoch;
  final List<String> employeeUidsToArchive;
  final List<String> employeeUidsToUnassignTeam;

  static const Set<String> validConfirmWords = {'wipe', 'مسح'};

  /// Validates mandatory backup export and double confirmation, then computes the wipe plan.
  static RosterWipePlan compute({
    required bool backupExported,
    required String confirmationText,
    required int currentEpoch,
    required Iterable<
      ({String employeeUid, bool isActive, String? currentTeamId})
    >
    employees,
  }) {
    final normalizedConfirm = confirmationText.trim().toLowerCase();
    if (!backupExported || !validConfirmWords.contains(normalizedConfirm)) {
      throw const OperationException(RosterWipeNotConfirmed());
    }

    final toArchive = <String>[];
    final toUnassign = <String>[];
    for (final emp in employees) {
      if (emp.isActive) {
        toArchive.add(emp.employeeUid);
      }
      if (emp.currentTeamId != null) {
        toUnassign.add(emp.employeeUid);
      }
    }

    return RosterWipePlan(
      previousEpoch: currentEpoch,
      nextEpoch: currentEpoch + 1,
      employeeUidsToArchive: List.unmodifiable(toArchive),
      employeeUidsToUnassignTeam: List.unmodifiable(toUnassign),
    );
  }
}
