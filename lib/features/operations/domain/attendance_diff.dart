import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

/// Source kind for the pre-save comparison baseline (PRD §8.1, §10).
enum BaselineKind { lastSave, previousDay, none }

/// Immutable baseline against which current selection changes are measured.
final class AttendanceBaseline {
  const AttendanceBaseline({
    required this.kind,
    this.date,
    this.workerIds = const <String>{},
  });

  final BaselineKind kind;
  final String? date;
  final Set<String> workerIds;
}

/// Pure result of comparing the current selection against an [AttendanceBaseline] (PRD §10).
final class AttendanceDiffResult {
  const AttendanceDiffResult({
    required this.baseline,
    required this.totalPresent,
    required this.addedWorkers,
    required this.removedWorkers,
  });

  final AttendanceBaseline baseline;
  final int totalPresent;
  final List<WorkerOption> addedWorkers;
  final List<WorkerOption> removedWorkers;

  bool get hasChanges => addedWorkers.isNotEmpty || removedWorkers.isNotEmpty;

  String baselineLabel(bool ar) => switch (baseline.kind) {
    BaselineKind.lastSave => OperationsStrings.diffBaselineLastSave(ar),
    BaselineKind.previousDay => OperationsStrings.diffBaselineDate(
      ar,
      baseline.date ?? '',
    ),
    BaselineKind.none => OperationsStrings.diffNoBaseline(ar),
  };

  String totalLine(bool ar) => OperationsStrings.preSaveDiffTotal(
    ar,
    totalPresent,
    addedWorkers.length,
    removedWorkers.length,
  );
}

/// Pure calculator for pre-save attendance differences (PRD §10).
abstract final class AttendanceDiff {
  static AttendanceDiffResult compute({
    required AttendanceBaseline baseline,
    required Set<String> selectedIds,
    required Map<String, WorkerOption> workersById,
    required bool arabic,
  }) {
    if (baseline.kind == BaselineKind.none) {
      return AttendanceDiffResult(
        baseline: baseline,
        totalPresent: selectedIds.length,
        addedWorkers: const <WorkerOption>[],
        removedWorkers: const <WorkerOption>[],
      );
    }

    final addedIds = selectedIds.difference(baseline.workerIds);
    final removedIds = baseline.workerIds.difference(selectedIds);

    final added = _sortedWorkers(addedIds, workersById, arabic);
    final removed = _sortedWorkers(removedIds, workersById, arabic);

    return AttendanceDiffResult(
      baseline: baseline,
      totalPresent: selectedIds.length,
      addedWorkers: List.unmodifiable(added),
      removedWorkers: List.unmodifiable(removed),
    );
  }

  static List<WorkerOption> _sortedWorkers(
    Set<String> ids,
    Map<String, WorkerOption> workersById,
    bool arabic,
  ) {
    final list = <WorkerOption>[
      for (final id in ids)
        if (workersById[id] != null) workersById[id]!,
    ];
    list.sort(
      (a, b) => NameCollation.compareWorkers(
        nameA: a.displayName(arabic: arabic),
        codeA: a.code,
        idA: a.id,
        nameB: b.displayName(arabic: arabic),
        codeB: b.code,
        idB: b.id,
      ),
    );
    return list;
  }
}
