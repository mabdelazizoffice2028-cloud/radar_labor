import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/history_housing_section_builder.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/history_site_section_builder.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

abstract final class HistoryBuilder {
  static HistoryPage build({
    required Iterable<LocalEvent> rangeEvents,
    required ActorContext actor, required ScopeSnapshot scope,
    required Map<String, EntityOption> teamsById, required Map<String, EntityOption> housingsById,
    required Map<String, WorkerOption> workersById, required Map<String, String> userNamesById,
    required String todayBusinessDate, required String fromDate, required String toDate,
    required bool hasMore, required bool arabic,
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
      List<WorkerOption> sortWorkers(Set<String> ids) => _sortedWorkers(ids, workersById, arabic);

      if (includeSite) {
        HistorySiteSectionBuilder.buildCards(
          date: date, ledger: ledger, actor: actor, scope: scope,
          teamsById: teamsById, workersById: workersById, userNamesById: userNamesById,
          todayBusinessDate: todayBusinessDate, arabic: arabic, strings: strings,
          cards: cards, sortWorkers: sortWorkers,
        );
      }
      if (includeHousing) {
        HistoryHousingSectionBuilder.buildCards(
          date: date, ledger: ledger, actor: actor, scope: scope,
          housingsById: housingsById, workersById: workersById, userNamesById: userNamesById,
          todayBusinessDate: todayBusinessDate, arabic: arabic, strings: strings,
          cards: cards, sortWorkers: sortWorkers,
        );
      }
    }

    final bySite = <String, List<HistoryDayCard>>{};
    final bySupervisor = <String, List<HistoryDayCard>>{};
    for (final card in cards) {
      final siteKey = card.entity.displayName(arabic: arabic);
      bySite.putIfAbsent(siteKey, () => <HistoryDayCard>[]).add(card);
      final supKey = card.lastActorName ?? HistoryStrings.historyUnknownActor(arabic);
      bySupervisor.putIfAbsent(supKey, () => <HistoryDayCard>[]).add(card);
    }

    return HistoryPage(
      cards: List.unmodifiable(cards), fromDate: fromDate, toDate: toDate, hasMore: hasMore,
      bySite: Map.unmodifiable(bySite), bySupervisor: Map.unmodifiable(bySupervisor),
    );
  }

  static List<WorkerOption> _sortedWorkers(Set<String> ids, Map<String, WorkerOption> workersById, bool arabic) {
    final list = [for (final id in ids) if (workersById[id] != null) workersById[id]!];
    list.sort((a, b) => NameCollation.compareWorkers(
      nameA: a.displayName(arabic: arabic), codeA: a.code, idA: a.id,
      nameB: b.displayName(arabic: arabic), codeB: b.code, idB: b.id,
    ));
    return List.unmodifiable(list);
  }
}
