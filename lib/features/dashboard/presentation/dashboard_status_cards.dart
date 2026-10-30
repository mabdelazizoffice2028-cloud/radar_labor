import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_status_card_item.dart';

final class DashboardStatusCards extends StatelessWidget {
  const DashboardStatusCards({
    required this.snapshot, required this.businessDate, required this.arabic, super.key,
  });

  final StatusSnapshot snapshot;
  final String businessDate;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    if (isFridayBusinessDate(businessDate)) {
      final ot = snapshot.count(WorkerStatus.onSite);
      final rest = snapshot.eligibleCount - ot;
      return GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.75,
        children: [
          DashboardStatusCardItem(
            count: ot, label: DashboardStrings.fridayOvertimeCard(arabic),
            icon: Icons.more_time, color: AppTokens.statusOnSite,
          ),
          DashboardStatusCardItem(
            count: rest < 0 ? 0 : rest, label: DashboardStrings.fridayRestCard(arabic),
            icon: Icons.beach_access_outlined, color: AppTokens.statusNotRecorded,
          ),
        ],
      );
    }

    final absent = snapshot.count(WorkerStatus.unknown) + snapshot.count(WorkerStatus.housingOnly);
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.75,
      children: [
        DashboardStatusCardItem(
          count: snapshot.count(WorkerStatus.onSite), label: DashboardStrings.presentOnSiteCard(arabic),
          icon: Icons.check_circle_outline, color: AppTokens.statusOnSite,
        ),
        DashboardStatusCardItem(
          count: absent, label: DashboardStrings.absentCard(arabic),
          icon: Icons.warning_amber_rounded, color: AppTokens.statusUnknown,
        ),
        DashboardStatusCardItem(
          count: snapshot.count(WorkerStatus.justified), label: DashboardStrings.justifiedCard(arabic),
          icon: Icons.verified_outlined, color: AppTokens.statusJustified,
        ),
        DashboardStatusCardItem(
          count: snapshot.count(WorkerStatus.notRecorded), label: DashboardStrings.notRecordedCard(arabic),
          icon: Icons.schedule_outlined, color: AppTokens.statusNotRecorded,
        ),
      ],
    );
  }
}
