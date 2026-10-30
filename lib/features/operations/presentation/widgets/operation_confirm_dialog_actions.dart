import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

class OperationConfirmDialogActions extends StatelessWidget {
  const OperationConfirmDialogActions({required this.arabic, super.key});
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(OperationsStrings.confirmAndSave(arabic)),
        ),
        const SizedBox(height: AppTokens.space8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(OperationsStrings.reviewAction(arabic)),
        ),
      ],
    );
  }
}
