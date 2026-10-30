import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/l10n/reports_and_alerts_strings.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_report_providers.dart';
import 'package:radar_labor/features/dashboard/presentation/daily_report_dialog.dart';

final class DailyReportButton extends ConsumerWidget {
  const DailyReportButton({
    required this.snapshot,
    required this.date,
    required this.arabic,
    super.key,
  });
  final StatusSnapshot snapshot;
  final String date;
  final bool arabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockoutHour = ref.watch(siteLockoutHourProvider).value ?? 23;
    final now = ref.watch(clockProvider).nowUtc();
    final riyadhHour = now.toRiyadh().hour;
    final isUnlocked = riyadhHour >= lockoutHour;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.share_outlined),
            label: Text(ReportsAndAlertsStrings.generateDailyReport(arabic)),
            onPressed: !isUnlocked
                ? null
                : () async {
                    final text = await ref
                        .read(dailyReportCompilerProvider)
                        .compile(
                          snapshot: snapshot,
                          date: date,
                          arabic: arabic,
                        );
                    if (context.mounted) {
                      await DailyReportDialog.show(
                        context: context,
                        reportText: text,
                        arabic: arabic,
                      );
                    }
                  },
          ),
          if (!isUnlocked)
            Padding(
              padding: const EdgeInsets.only(top: AppTokens.space4),
              child: Text(
                ReportsAndAlertsStrings.availableAfterHour(arabic, lockoutHour),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                  fontSize: AppTokens.space12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
