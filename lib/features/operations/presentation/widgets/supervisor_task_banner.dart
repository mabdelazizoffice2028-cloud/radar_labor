import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/l10n/supervisor_task_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';
import 'package:radar_labor/features/operations/presentation/widgets/scoped_worker_lookup_sheet.dart';

/// Concise, high-contrast task summary card for field supervisors (Phase 5).
final class SupervisorTaskBanner extends ConsumerWidget {
  const SupervisorTaskBanner({
    required this.arabic,
    required this.role,
    required this.controller,
    super.key,
  });

  final bool arabic;
  final AuthRole role;
  final OperationsController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housingState = ref.watch(housingCheckNotifierProvider);
    final siteState = ref.watch(siteAttendanceNotifierProvider);
    final isHousing = role == AuthRole.housingSupervisor;

    final String taskBadgeText;
    final IconData taskBadgeIcon;
    final Color taskBadgeColor;
    final Color taskBadgeBg;

    if (isHousing) {
      if (housingState.hasSavedRecordToday) {
        taskBadgeText = SupervisorTaskStrings.taskStatusSavedCompleted(arabic);
        taskBadgeIcon = Icons.check_circle;
        taskBadgeColor = AppTokens.statusOnSite;
        taskBadgeBg = AppTokens.statusOnSiteSoft;
      } else if (housingState.hasDraftSaved ||
          housingState.unreviewedCount < housingState.totalCount) {
        taskBadgeText = SupervisorTaskStrings.taskStatusDraftSaved(arabic);
        taskBadgeIcon = Icons.edit_note;
        taskBadgeColor = AppTokens.statusHousingOnly;
        taskBadgeBg = AppTokens.statusHousingOnlySoft;
      } else {
        taskBadgeText = SupervisorTaskStrings.taskStatusNotStarted(arabic);
        taskBadgeIcon = Icons.pending_actions;
        taskBadgeColor = AppTokens.statusNotRecorded;
        taskBadgeBg = AppTokens.statusNotRecordedSoft;
      }
    } else {
      if (siteState.initialSource == AttendanceInitialSource.savedDay) {
        taskBadgeText = SupervisorTaskStrings.taskStatusSavedCompleted(arabic);
        taskBadgeIcon = Icons.check_circle;
        taskBadgeColor = AppTokens.statusOnSite;
        taskBadgeBg = AppTokens.statusOnSiteSoft;
      } else if (siteState.initialSource == AttendanceInitialSource.draft ||
          siteState.skippedDraftCount > 0) {
        taskBadgeText = SupervisorTaskStrings.taskStatusDraftSaved(arabic);
        taskBadgeIcon = Icons.edit_note;
        taskBadgeColor = AppTokens.statusHousingOnly;
        taskBadgeBg = AppTokens.statusHousingOnlySoft;
      } else {
        taskBadgeText = SupervisorTaskStrings.taskStatusNotStarted(arabic);
        taskBadgeIcon = Icons.pending_actions;
        taskBadgeColor = AppTokens.statusNotRecorded;
        taskBadgeBg = AppTokens.statusNotRecordedSoft;
      }
    }

    final todayDate = businessDateFor(controller.clock.nowUtc());

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTokens.space12,
        AppTokens.space8,
        AppTokens.space12,
        AppTokens.space4,
      ),
      padding: const EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        border: Border.all(color: AppTokens.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  SupervisorTaskStrings.todayApprovedDate(arabic, todayDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTokens.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () => ScopedWorkerLookupSheet.show(
                  context: context,
                  arabic: arabic,
                  controller: controller,
                ),
                borderRadius: BorderRadius.circular(AppTokens.radius12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space8,
                    vertical: AppTokens.space4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.search,
                        size: 16,
                        color: AppTokens.primary,
                      ),
                      const SizedBox(width: AppTokens.space4),
                      Text(
                        SupervisorTaskStrings.openLookupAction(arabic),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTokens.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space8,
                  vertical: AppTokens.space4,
                ),
                decoration: BoxDecoration(
                  color: taskBadgeBg,
                  borderRadius: BorderRadius.circular(AppTokens.radius12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(taskBadgeIcon, color: taskBadgeColor, size: 16),
                    const SizedBox(width: AppTokens.space4),
                    Text(
                      taskBadgeText,
                      style: TextStyle(
                        color: taskBadgeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  isHousing
                      ? '${HousingReviewStrings.totalWorkersLabel(arabic, housingState.totalCount)}: '
                            '${housingState.reviewedCount} ✓ / ${housingState.absentCount} ✕ / ${housingState.unreviewedCount} ?'
                      : '${OperationsStrings.presentCountLabel(arabic, siteState.presentCount)} / ${siteState.rows.length}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
