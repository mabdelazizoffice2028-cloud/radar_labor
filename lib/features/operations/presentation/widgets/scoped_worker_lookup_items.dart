import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/l10n/supervisor_task_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/worker_search_filter.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';

typedef ScopedLookupItem = ({
  WorkerOption worker,
  String statusText,
  Color statusColor,
  IconData statusIcon,
});

abstract final class ScopedWorkerLookupItems {
  static List<ScopedLookupItem> build({
    required HousingCheckState housingState,
    required SiteAttendanceState siteState,
    required String query,
    required bool arabic,
  }) {
    final workers = <ScopedLookupItem>[];

    for (final row in housingState.rows) {
      final isPresent = row.reviewState == HousingReviewState.reviewedPresent;
      final isAbsent = row.reviewState == HousingReviewState.absent;
      final text = isPresent
          ? HousingReviewStrings.reviewStateReviewed(arabic)
          : (isAbsent
                ? HousingReviewStrings.reviewStateAbsent(arabic)
                : HousingReviewStrings.reviewStateUnreviewed(arabic));
      final color = isPresent
          ? AppTokens.statusOnSite
          : (isAbsent ? AppTokens.statusHousingOnly : AppTokens.statusNotRecorded);
      final icon = isPresent
          ? Icons.check_circle
          : (isAbsent ? Icons.cancel : Icons.help_outline);
      workers.add((
        worker: row.worker, statusText: text, statusColor: color, statusIcon: icon,
      ));
    }

    for (final row in siteState.rows) {
      final text = row.isPresent
          ? SupervisorTaskStrings.workerStatusReviewCompleted(arabic)
          : SupervisorTaskStrings.workerStatusReviewNotStarted(arabic);
      final color = row.isPresent ? AppTokens.statusOnSite : AppTokens.statusNotRecorded;
      final icon = row.isPresent ? Icons.check_circle : Icons.radio_button_unchecked;
      workers.add((
        worker: row.worker, statusText: text, statusColor: color, statusIcon: icon,
      ));
    }

    if (query.trim().isEmpty) return workers;
    return workers
        .where((item) => WorkerSearchFilter.matches(
              query: query,
              code: item.worker.code,
              nameAr: item.worker.nameAr,
              nameEn: item.worker.nameEn,
              id: item.worker.id,
            ))
        .toList(growable: false);
  }
}
