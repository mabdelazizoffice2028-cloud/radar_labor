import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/l10n/supervisor_task_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';

/// Modal sheet for field supervisors to search any worker in their scope (Phase 5).
final class ScopedWorkerLookupSheet extends ConsumerStatefulWidget {
  const ScopedWorkerLookupSheet({
    required this.arabic,
    required this.controller,
    super.key,
  });

  final bool arabic;
  final OperationsController controller;

  static Future<void> show({
    required BuildContext context,
    required bool arabic,
    required OperationsController controller,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTokens.radius12),
      ),
    ),
    builder: (_) =>
        ScopedWorkerLookupSheet(arabic: arabic, controller: controller),
  );

  @override
  ConsumerState<ScopedWorkerLookupSheet> createState() =>
      _ScopedWorkerLookupSheetState();
}

final class _ScopedWorkerLookupSheetState
    extends ConsumerState<ScopedWorkerLookupSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final housingState = ref.watch(housingCheckNotifierProvider);
    final siteState = ref.watch(siteAttendanceNotifierProvider);

    // Collect all workers from active housing and site states
    final List<
      ({
        WorkerOption worker,
        String statusText,
        Color statusColor,
        IconData statusIcon,
      })
    >
    workers = [];

    for (final row in housingState.rows) {
      final isPresent = row.reviewState == HousingReviewState.reviewedPresent;
      final isAbsent = row.reviewState == HousingReviewState.absent;
      final text = isPresent
          ? HousingReviewStrings.reviewStateReviewed(ar)
          : (isAbsent
                ? HousingReviewStrings.reviewStateAbsent(ar)
                : HousingReviewStrings.reviewStateUnreviewed(ar));
      final color = isPresent
          ? AppTokens.statusOnSite
          : (isAbsent
                ? AppTokens.statusHousingOnly
                : AppTokens.statusNotRecorded);
      final icon = isPresent
          ? Icons.check_circle
          : (isAbsent ? Icons.cancel : Icons.help_outline);

      workers.add((
        worker: row.worker,
        statusText: text,
        statusColor: color,
        statusIcon: icon,
      ));
    }

    for (final row in siteState.rows) {
      final text = row.isPresent
          ? SupervisorTaskStrings.workerStatusReviewCompleted(ar)
          : SupervisorTaskStrings.workerStatusReviewNotStarted(ar);
      final color = row.isPresent
          ? AppTokens.statusOnSite
          : AppTokens.statusNotRecorded;
      final icon = row.isPresent
          ? Icons.check_circle
          : Icons.radio_button_unchecked;

      workers.add((
        worker: row.worker,
        statusText: text,
        statusColor: color,
        statusIcon: icon,
      ));
    }

    final filtered = _query.trim().isEmpty
        ? workers
        : workers
              .where((item) {
                final q = _query.trim().toLowerCase();
                final nameAr = item.worker.nameAr.toLowerCase();
                final nameEn = (item.worker.nameEn ?? '').toLowerCase();
                final code = item.worker.code.toLowerCase();
                return nameAr.contains(q) ||
                    nameEn.contains(q) ||
                    code.contains(q);
              })
              .toList(growable: false);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTokens.space16,
        AppTokens.space16,
        AppTokens.space16,
        MediaQuery.viewInsetsOf(context).bottom + AppTokens.space16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: AppTokens.primary),
              const SizedBox(width: AppTokens.space8),
              Expanded(
                child: Text(
                  SupervisorTaskStrings.scopedWorkerLookupTitle(ar),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space12),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: SupervisorTaskStrings.scopedWorkerSearchHint(ar),
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radius12),
              ),
            ),
            onChanged: (val) => setState(() => _query = val),
          ),
          const SizedBox(height: AppTokens.space12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppTokens.space24),
                    child: Center(
                      child: Text(
                        SupervisorTaskStrings.noScopedWorkersFound(ar),
                        style: const TextStyle(color: AppTokens.textSecondary),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      return ListTile(
                        leading: Icon(item.statusIcon, color: item.statusColor),
                        title: Text(item.worker.displayName(arabic: ar)),
                        subtitle: Text(
                          '${OperationsStrings.codeLabel(ar)}: ${item.worker.code}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTokens.space8,
                            vertical: AppTokens.space4,
                          ),
                          decoration: BoxDecoration(
                            color: item.statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppTokens.radius12,
                            ),
                          ),
                          child: Text(
                            item.statusText,
                            style: TextStyle(
                              color: item.statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
