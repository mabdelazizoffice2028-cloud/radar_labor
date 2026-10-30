import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class DashboardFridayBanner extends StatelessWidget {
  const DashboardFridayBanner({required this.arabic, super.key});
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTokens.space12),
      padding: const EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: AppTokens.statusOnSiteSoft,
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        border: Border.all(color: AppTokens.statusOnSite),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTokens.statusOnSite),
          const SizedBox(width: AppTokens.space8),
          Expanded(
            child: Text(
              DashboardStrings.fridayBannerTitle(arabic),
              style: const TextStyle(
                color: AppTokens.statusOnSite,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
