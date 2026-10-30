import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/reports_and_alerts_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_report_providers.dart';
import 'package:radar_labor/features/dashboard/presentation/iqama_expiry_sheet.dart';

final class IqamaExpiryAlertCard extends ConsumerWidget {
  const IqamaExpiryAlertCard({required this.arabic, super.key});
  final bool arabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = ref.watch(expiringWorkersProvider).value ?? const [];
    if (workers.isEmpty) return const SizedBox.shrink();

    final expiredCount = workers.where((w) => w.daysRemaining < 0).length;

    return Card(
      color: AppTokens.statusHousingOnlySoft,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppTokens.space12),
      child: ListTile(
        leading: const Icon(
          Icons.warning_amber_rounded,
          color: AppTokens.statusHousingOnly,
          size: AppTokens.space32,
        ),
        title: Text(
          ReportsAndAlertsStrings.iqamaAlertTitle(arabic),
          style: const TextStyle(
            color: AppTokens.statusHousingOnly,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          ReportsAndAlertsStrings.iqamaAlertSubtitle(
            arabic,
            workers.length,
            expiredCount,
          ),
          style: const TextStyle(
            color: AppTokens.statusHousingOnly,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: AppTokens.space16,
          color: AppTokens.statusHousingOnly,
        ),
        onTap: () => IqamaExpirySheet.show(context, workers, arabic),
      ),
    );
  }
}
