import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Minimalist header badge showing the current operational business date.
final class HomeDateBadge extends StatelessWidget {
  const HomeDateBadge({this.clock = const SystemClock(), super.key});

  final Clock clock;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppTokens.space8,
        end: AppTokens.space16,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space8,
            vertical: AppTokens.space4,
          ),
          decoration: BoxDecoration(
            color: AppTokens.primarySoft,
            borderRadius: BorderRadius.circular(AppTokens.radius12),
          ),
          child: Text(
            businessDateFor(clock.nowUtc()),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTokens.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
