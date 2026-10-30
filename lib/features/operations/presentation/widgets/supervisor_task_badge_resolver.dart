import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/l10n/supervisor_task_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';

final class TaskBadgeInfo {
  const TaskBadgeInfo({
    required this.text, required this.icon, required this.color, required this.bg,
  });
  final String text;
  final IconData icon;
  final Color color;
  final Color bg;
}

final class SupervisorTaskBadgeResolver {
  static TaskBadgeInfo resolve({
    required AuthRole role, required String todayDate, required bool arabic,
    required HousingCheckState housingState, required SiteAttendanceState siteState,
  }) {
    final isFriday = isFridayBusinessDate(todayDate);
    final isHousing = role == AuthRole.housingSupervisor;

    if (isFriday) {
      if (isHousing) {
        return TaskBadgeInfo(
          text: OperationsStrings.fridayRestAbsenceClosed(arabic),
          icon: Icons.beach_access_outlined,
          color: AppTokens.statusNotRecorded,
          bg: AppTokens.statusNotRecordedSoft,
        );
      }
      return TaskBadgeInfo(
        text: OperationsStrings.fridayOvertimeMode(arabic),
        icon: Icons.more_time,
        color: AppTokens.statusOnSite,
        bg: AppTokens.statusOnSiteSoft,
      );
    }

    if (isHousing) {
      if (housingState.hasSavedRecordToday) {
        return TaskBadgeInfo(text: SupervisorTaskStrings.taskStatusSavedCompleted(arabic), icon: Icons.check_circle, color: AppTokens.statusOnSite, bg: AppTokens.statusOnSiteSoft);
      } else if (housingState.hasDraftSaved || housingState.unreviewedCount < housingState.totalCount) {
        return TaskBadgeInfo(text: SupervisorTaskStrings.taskStatusDraftSaved(arabic), icon: Icons.edit_note, color: AppTokens.statusHousingOnly, bg: AppTokens.statusHousingOnlySoft);
      }
      return TaskBadgeInfo(text: SupervisorTaskStrings.taskStatusNotStarted(arabic), icon: Icons.pending_actions, color: AppTokens.statusNotRecorded, bg: AppTokens.statusNotRecordedSoft);
    }

    if (siteState.initialSource == AttendanceInitialSource.savedDay) {
      return TaskBadgeInfo(text: SupervisorTaskStrings.taskStatusSavedCompleted(arabic), icon: Icons.check_circle, color: AppTokens.statusOnSite, bg: AppTokens.statusOnSiteSoft);
    } else if (siteState.initialSource == AttendanceInitialSource.draft || siteState.skippedDraftCount > 0) {
      return TaskBadgeInfo(text: SupervisorTaskStrings.taskStatusDraftSaved(arabic), icon: Icons.edit_note, color: AppTokens.statusHousingOnly, bg: AppTokens.statusHousingOnlySoft);
    }
    return TaskBadgeInfo(text: SupervisorTaskStrings.taskStatusNotStarted(arabic), icon: Icons.pending_actions, color: AppTokens.statusNotRecorded, bg: AppTokens.statusNotRecordedSoft);
  }
}
