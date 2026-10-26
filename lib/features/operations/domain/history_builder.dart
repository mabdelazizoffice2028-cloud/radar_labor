import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_template_engine.dart';

/// Pure domain builder for supervisor and admin history views (PRD §11.1, §11.3).
abstract final class HistoryBuilder {
  static HistoryPage build({
    required Iterable<LocalEvent> rangeEvents,
    required ActorContext actor,
    required ScopeSnapshot scope,
    required Map<String, EntityOption> teamsById,
    required Map<String, EntityOption> housingsById,
    required Map<String, WorkerOption> workersById,
    required Map<String, String> userNamesById,
    required String todayBusinessDate,
    required String fromDate,
    required String toDate,
    required bool hasMore,
    required bool arabic,
  }) {
    final byDate = <String, List<LocalEvent>>{};
    for (final event in rangeEvents) {
      if (event.delivery == EventDelivery.rejected) continue;
      byDate.putIfAbsent(event.businessDate, () => <LocalEvent>[]).add(event);
    }

    final sortedDates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
    final strings = AttendanceMessageStrings.fromLanguage(arabic: arabic);
    final cards = <HistoryDayCard>[];

    final viewAll = actor.capabilities.canViewAllHistory;
    final includeSite = viewAll || actor.capabilities.canRecordSite;
    final includeHousing = viewAll || actor.capabilities.canRecordHousing;

    for (final date in sortedDates) {
      final ledger = AttendanceLedger(byDate[date]!);

      if (includeSite) {
        final teamIds = viewAll
            ? teamsById.keys.toList()
            : scope.teamIds.where(teamsById.containsKey).toList();
        teamIds.sort((a, b) {
          final ta = teamsById[a]!;
          final tb = teamsById[b]!;
          return NameCollation.sortKey(ta.displayName(arabic: arabic))
              .compareTo(NameCollation.sortKey(tb.displayName(arabic: arabic)));
        });

        for (final teamId in teamIds) {
          if (!ledger.isSiteSubmitted(teamId)) continue;
          final team = teamsById[teamId]!;
          final presentIds = ledger.presentWorkerIdsForTeam(teamId);
          final workers = _sortedWorkers(presentIds, workersById, arabic);
          final lastEvent = ledger.lastTeamRecordingEvent(teamId);
          final actorId = lastEvent?.userId;
          final actorName = actorId == null ? null : userNamesById[actorId];
          final canEdit =
              actor.capabilities.canRecordSite &&
              actor.capabilities.canEditPastDays &&
              scope.allowsTeam(teamId) &&
              _isWithinEditWindow(date, todayBusinessDate);

          final msg = WhatsappTemplateEngine.format(
            kind: WhatsappMessageKind.site,
            date: date,
            entityName: team.displayName(arabic: arabic),
            workers: [
              for (final w in workers)
                WhatsappWorkerItem(
                  code: w.code,
                  name: w.displayName(arabic: arabic),
                ),
            ],
            arabic: arabic,
            strings: strings,
          );

          cards.add(
            HistoryDayCard(
              kind: HistoryEntryKind.site,
              entity: team,
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

      if (includeHousing) {
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
          final workers = _sortedWorkers(absentIds, workersById, arabic);
          final lastEvent = ledger.lastHousingRecordingEvent(housingId);
          final actorId = lastEvent?.userId;
          final actorName = actorId == null ? null : userNamesById[actorId];

          final msg = WhatsappTemplateEngine.format(
            kind: WhatsappMessageKind.housing,
            date: date,
            entityName: housing.displayName(arabic: arabic),
            workers: [
              for (final w in workers)
                WhatsappWorkerItem(
                  code: w.code,
                  name: w.displayName(arabic: arabic),
                ),
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
              canEdit: false,
              whatsappMessage: msg,
            ),
          );
        }
      }
    }

    final bySite = <String, List<HistoryDayCard>>{};
    final bySupervisor = <String, List<HistoryDayCard>>{};
    for (final card in cards) {
      final siteKey = card.entity.displayName(arabic: arabic);
      bySite.putIfAbsent(siteKey, () => <HistoryDayCard>[]).add(card);

      final supKey =
          card.lastActorName ?? HistoryStrings.historyUnknownActor(arabic);
      bySupervisor.putIfAbsent(supKey, () => <HistoryDayCard>[]).add(card);
    }

    return HistoryPage(
      cards: List.unmodifiable(cards),
      fromDate: fromDate,
      toDate: toDate,
      hasMore: hasMore,
      bySite: Map.unmodifiable(bySite),
      bySupervisor: Map.unmodifiable(bySupervisor),
    );
  }

  static List<WorkerOption> _sortedWorkers(
    Set<String> ids,
    Map<String, WorkerOption> workersById,
    bool arabic,
  ) {
    final list = <WorkerOption>[
      for (final id in ids)
        if (workersById[id] != null) workersById[id]!,
    ];
    list.sort(
      (a, b) => NameCollation.compareWorkers(
        nameA: a.displayName(arabic: arabic),
        codeA: a.code,
        idA: a.id,
        nameB: b.displayName(arabic: arabic),
        codeB: b.code,
        idB: b.id,
      ),
    );
    return List.unmodifiable(list);
  }

  static bool _isWithinEditWindow(String date, String today) {
    final target = DateTime.tryParse(date);
    final current = DateTime.tryParse(today);
    if (target == null || current == null) return false;
    final diff = current.difference(target).inDays;
    return diff >= 0 && diff <= OperationsConstants.maxBackdateDays;
  }
}
