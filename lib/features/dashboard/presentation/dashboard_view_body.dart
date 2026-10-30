import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/dashboard/presentation/daily_report_button.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_conflict_section.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_date_selector.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_friday_banner.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_integrity_section.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_status_cards.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_unknown_section.dart';
import 'package:radar_labor/features/dashboard/presentation/iqama_expiry_alert_card.dart';

final class DashboardViewBody extends StatelessWidget {
  const DashboardViewBody({
    required this.snapshot, required this.businessDate, required this.arabic,
    required this.onPickDate, required this.onResolve, required this.onJustify,
    super.key,
  });

  final StatusSnapshot snapshot; final String businessDate; final bool arabic;
  final VoidCallback onPickDate;
  final ValueChanged<WorkerStatusResult>? onResolve, onJustify;

  @override
  Widget build(BuildContext context) {
    final el = snapshot.workers.where((r) => r.isEligible);
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space16),
      children: [
        IqamaExpiryAlertCard(arabic: arabic),
        if (isFridayBusinessDate(businessDate)) DashboardFridayBanner(arabic: arabic),
        DashboardDateSelector(date: businessDate, arabic: arabic, onPressed: onPickDate),
        const SizedBox(height: AppTokens.space12),
        DashboardStatusCards(snapshot: snapshot, businessDate: businessDate, arabic: arabic),
        DailyReportButton(snapshot: snapshot, date: businessDate, arabic: arabic),
        const SizedBox(height: AppTokens.space12),
        DashboardConflictSection(
          rows: [for (final r in el) if (r.flags.contains(StatusFlag.housingSiteConflict) || r.flags.contains(StatusFlag.multipleSiteTeams)) r],
          arabic: arabic, onResolve: onResolve,
        ),
        DashboardUnknownSection(
          rows: [for (final r in el) if (r.status == WorkerStatus.unknown) r],
          arabic: arabic, onJustify: onJustify,
        ),
        DashboardIntegritySection(
          rows: [
            for (final r in snapshot.workers)
              if (r.flags.contains(StatusFlag.inactiveWorkerEvent) ||
                  r.flags.contains(StatusFlag.eventOutsideEmployment) ||
                  r.flags.contains(StatusFlag.lateEvent) ||
                  r.flags.contains(StatusFlag.rejectedEvent))
                r,
          ],
          arabic: arabic,
        ),
      ],
    );
  }
}
