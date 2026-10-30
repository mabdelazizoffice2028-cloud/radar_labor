import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';
import 'package:radar_labor/features/operations/presentation/widgets/supervisor_task_badge_resolver.dart';
import 'package:radar_labor/features/operations/presentation/widgets/supervisor_task_top_bar.dart';

final class SupervisorTaskBanner extends ConsumerWidget {
  const SupervisorTaskBanner({
    required this.arabic, required this.role, required this.controller, super.key,
  });

  final bool arabic;
  final AuthRole role;
  final OperationsController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housingState = ref.watch(housingCheckNotifierProvider);
    final siteState = ref.watch(siteAttendanceNotifierProvider);
    final isHousing = role == AuthRole.housingSupervisor;
    final todayDate = businessDateFor(controller.clock.nowUtc());
    final badge = SupervisorTaskBadgeResolver.resolve(
      role: role, todayDate: todayDate, arabic: arabic,
      housingState: housingState, siteState: siteState,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(AppTokens.space12, AppTokens.space8, AppTokens.space12, AppTokens.space4),
      padding: const EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(color: AppTokens.surface, borderRadius: BorderRadius.circular(AppTokens.radius12), border: Border.all(color: AppTokens.outline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SupervisorTaskTopBar(arabic: arabic, todayDate: todayDate, controller: controller),
          const SizedBox(height: AppTokens.space8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8, vertical: AppTokens.space4),
                decoration: BoxDecoration(color: badge.bg, borderRadius: BorderRadius.circular(AppTokens.radius12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badge.icon, color: badge.color, size: 16),
                    const SizedBox(width: AppTokens.space4),
                    Text(badge.text, style: TextStyle(color: badge.color, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  isHousing
                      ? '${HousingReviewStrings.totalWorkersLabel(arabic, housingState.totalCount)}: ${housingState.reviewedCount} ✓ / ${housingState.absentCount} ✕ / ${housingState.unreviewedCount} ?'
                      : '${OperationsStrings.presentCountLabel(arabic, siteState.presentCount)} / ${siteState.rows.length}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTokens.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
