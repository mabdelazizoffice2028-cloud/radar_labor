import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/time/time_format.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/history_day_detail_sheet.dart';

class HistoryCardTile extends StatelessWidget {
  const HistoryCardTile({
    required this.card,
    required this.arabic,
    this.onEditSiteDay,
    super.key,
  });

  final HistoryDayCard card;
  final bool arabic;
  final void Function(EntityOption team, String date)? onEditSiteDay;

  @override
  Widget build(BuildContext context) {
    final entityName = card.entity.displayName(arabic: arabic);
    final countText = card.kind == HistoryEntryKind.site
        ? HistoryStrings.historyPresentCount(arabic, card.count)
        : HistoryStrings.historyAbsentCount(arabic, card.count);
    final actorName =
        card.lastActorName ?? HistoryStrings.historyUnknownActor(arabic);
    final timeSuffix = card.recordedAtUtc == null
        ? ''
        : ' • ${RiyadhTimeFormat.hhMm(card.recordedAtUtc!)}';
    final editCallback = card.canEdit && onEditSiteDay != null
        ? () => onEditSiteDay!(card.entity, card.businessDate)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.space8),
      child: ListTile(
        onTap: () => HistoryDayDetailSheet.show(
          context: context,
          card: card,
          arabic: arabic,
          onEdit: editCallback,
        ),
        title: Text('$entityName — ${card.businessDate}'),
        subtitle: Text(
          '$countText\n${HistoryStrings.historyLastRecordedBy(arabic, actorName)}$timeSuffix',
        ),
        isThreeLine: true,
        trailing: editCallback != null
            ? TextButton.icon(
                onPressed: editCallback,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(HistoryStrings.historyEdit(arabic)),
              )
            : Text(
                HistoryStrings.historyLocked(arabic),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppTokens.textSecondary),
              ),
      ),
    );
  }
}
