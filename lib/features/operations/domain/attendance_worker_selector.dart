import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

final class SelectedWorkerItem {
  const SelectedWorkerItem({
    required this.id,
    required this.code,
    required this.name,
    required this.label,
    required this.employmentType,
    required this.jobCategory,
  });

  final String id;
  final String code;
  final String name;
  final String label;
  final String employmentType;
  final String jobCategory;
}

final class AttendanceWorkerSelector {
  static List<SelectedWorkerItem> select({
    required Iterable<WorkerOption> workers,
    required Set<String> selectedIds,
    required bool arabic,
  }) {
    final items = [
      for (final worker in workers)
        if (selectedIds.contains(worker.id))
          SelectedWorkerItem(
            id: worker.id,
            code: worker.code,
            name: worker.displayName(arabic: arabic),
            label: '${worker.displayName(arabic: arabic)} (${worker.code})',
            employmentType: worker.employmentType,
            jobCategory: worker.jobCategory,
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
