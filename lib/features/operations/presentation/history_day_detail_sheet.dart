import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/time/time_format.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';

/// Modal bottom sheet showing full worker list and WhatsApp copy for a recorded day (PRD §11).
class HistoryDayDetailSheet extends StatelessWidget {
  const HistoryDayDetailSheet({
    required this.card,
    required this.arabic,
    this.onEdit,
    super.key,
  });

  final HistoryDayCard card;
  final bool arabic;
  final VoidCallback? onEdit;

  static Future<void> show({
    required BuildContext context,
    required HistoryDayCard card,
    required bool arabic,
    VoidCallback? onEdit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          HistoryDayDetailSheet(card: card, arabic: arabic, onEdit: onEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entityName = card.entity.displayName(arabic: arabic);
    final actorName =
        card.lastActorName ?? HistoryStrings.historyUnknownActor(arabic);
    final timeSuffix = card.recordedAtUtc == null
        ? ''
        : ' • ${RiyadhTimeFormat.hhMm(card.recordedAtUtc!)}';
    final countText = card.kind == HistoryEntryKind.site
        ? HistoryStrings.historyPresentCount(arabic, card.count)
        : HistoryStrings.historyAbsentCount(arabic, card.count);

    return Padding(
      padding: const EdgeInsets.all(AppTokens.space16),
      child: SizedBox(
        height: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$entityName — ${card.businessDate}',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              '${HistoryStrings.historyLastRecordedBy(arabic, actorName)}$timeSuffix',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppTokens.textSecondary),
            ),
            const SizedBox(height: AppTokens.space8),
            Text(
              countText,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Divider(height: AppTokens.space16),
            Expanded(
              child: card.workers.isEmpty
                  ? Center(
                      child: Text(
                        OperationsStrings.noSearchResults(arabic),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: card.workers.length,
                      itemBuilder: (context, index) {
                        final w = card.workers[index];
                        return ListTile(
                          dense: true,
                          leading: Text('${index + 1}.'),
                          title: Text(w.displayName(arabic: arabic)),
                          trailing: Text(w.code),
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppTokens.space12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppTokens.minTouchTarget,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: card.whatsappMessage),
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.copy_outlined),
                      label: Text(OperationsStrings.copyTextAction(arabic)),
                    ),
                  ),
                ),
                if (card.canEdit && onEdit != null) ...[
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: SizedBox(
                      height: AppTokens.minTouchTarget,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onEdit!();
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(HistoryStrings.historyEdit(arabic)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
