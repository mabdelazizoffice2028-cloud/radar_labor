import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_template_engine.dart';

final class HistoryHousingSectionBuilder {
  static void buildCards({
    required String date,
    required AttendanceLedger ledger,
    required ActorContext actor,
    required ScopeSnapshot scope,
    required Map<String, EntityOption> housingsById,
    required Map<String, WorkerOption> workersById,
    required Map<String, String> userNamesById,
    required String todayBusinessDate,
    required bool arabic,
    required AttendanceMessageStrings strings,
    required List<HistoryDayCard> cards,
    required List<WorkerOption> Function(Set<String> ids) sortWorkers,
  }) {
    final viewAll = actor.capabilities.canViewAllHistory;
    final housingIds = viewAll
        ? housingsById.keys.toList()
        : scope.housingIds.where(housingsById.containsKey).toList();
    housingIds.sort((a, b) {
      final ha = housingsById[a]!;
      final hb = housingsById[b]!;
      return NameCollation.sortKey(ha.displayName(arabic: arabic))
          .compareTo(NameCollation.sortKey(hb.displayName(arabic: arabic)));
    });

    for (final housingId in housingIds) {
      if (!ledger.isHousingChecked(housingId)) continue;
      final housing = housingsById[housingId]!;
      final absentIds = ledger.absentWorkerIdsForHousing(housingId);
      final workers = sortWorkers(absentIds);
      final lastEvent = ledger.lastHousingRecordingEvent(housingId);
      final actorId = lastEvent?.userId;
      final actorName = actorId == null ? null : userNamesById[actorId];
      final isPast = date != todayBusinessDate;
      final canEdit = isPast && actor.capabilities.canEditPastDays;

      final msg = WhatsappTemplateEngine.format(
        kind: WhatsappMessageKind.housing,
        date: date,
        entityName: housing.displayName(arabic: arabic),
        workers: [
          for (final w in workers)
            WhatsappWorkerItem(code: w.code, name: w.displayName(arabic: arabic)),
        ],
        arabic: arabic,
        strings: strings,
      );

      cards.add(
        HistoryDayCard(
          kind: HistoryEntryKind.housing,
          entity: housing,
          businessDate: date,
          workers: workers,
          recordedAtUtc: lastEvent?.deviceTimeUtc,
          lastActorUserId: actorId,
          lastActorName: actorName,
          canEdit: canEdit,
          whatsappMessage: msg,
        ),
      );
    }
  }
}
