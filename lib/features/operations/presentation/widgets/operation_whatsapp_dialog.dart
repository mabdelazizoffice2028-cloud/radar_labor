import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';

/// Shows the standard WhatsApp message summary dialog for copy and review.
Future<void> showOperationWhatsappDialog({
  required BuildContext context,
  required String messageText,
  required bool arabic,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(OperationsStrings.whatsappSummaryTitle(arabic)),
      content: SelectableText(messageText),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: messageText));
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(OperationsStrings.copyTextAction(arabic)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(OperationsStrings.closeAction(arabic)),
        ),
      ],
    ),
  );
}
