import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/l10n/reports_and_alerts_strings.dart';

final class DailyReportDialog {
  static Future<void> show({
    required BuildContext context,
    required String reportText,
    required bool arabic,
  }) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ReportsAndAlertsStrings.dailyReportDialogTitle(arabic)),
      content: SelectableText(reportText),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: reportText));
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: Text(OperationsStrings.copyTextAction(arabic)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(OperationsStrings.closeAction(arabic)),
        ),
      ],
    ),
  );
}
