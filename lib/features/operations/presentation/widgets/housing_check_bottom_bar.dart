import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class HousingCheckBottomBar extends StatelessWidget {
  const HousingCheckBottomBar({
    required this.arabic,
    required this.absentCount,
    required this.isSaving,
    required this.onSavePressed,
    this.isFriday = false,
    super.key,
  });

  final bool arabic;
  final int absentCount;
  final bool isSaving;
  final VoidCallback onSavePressed;
  final bool isFriday;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              OperationsStrings.markedAbsentCount(arabic, absentCount),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTokens.space8),
            FilledButton(
              onPressed: isSaving || isFriday ? null : onSavePressed,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              child: Text(OperationsStrings.nextConfirmAction(arabic)),
            ),
          ],
        ),
      ),
    );
  }
}
