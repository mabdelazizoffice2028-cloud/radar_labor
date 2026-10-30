import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Amber high-contrast banner displayed on Friday for overtime mode.
final class SiteFridayBanner extends StatelessWidget {
  const SiteFridayBanner({required this.arabic, super.key});
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: AppTokens.statusHousingOnlySoft,
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        border: Border.all(color: AppTokens.statusHousingOnly),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTokens.statusHousingOnly),
          const SizedBox(width: AppTokens.space8),
          Expanded(
            child: Text(
              OperationsStrings.fridayBannerTitle(arabic),
              style: const TextStyle(
                color: AppTokens.statusHousingOnly,
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
