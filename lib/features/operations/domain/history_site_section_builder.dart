import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_template_engine.dart';

final class HistorySiteSectionBuilder {
  static void buildCards({
    required String date, required AttendanceLedger ledger, required ActorContext actor,
    required ScopeSnapshot scope, required Map<String, EntityOption> teamsById,
    required Map<String, WorkerOption> workersById, required Map<String, String> userNamesById,
    required String todayBusinessDate, required bool arabic,
    required AttendanceMessageStrings strings, required List<HistoryDayCard> cards,
    required List<WorkerOption> Function(Set<String> ids) sortWorkers,
  }) {
    final viewAll = actor.capabilities.canViewAllHistory;
    final teamIds = viewAll ? teamsById.keys.toList() : scope.teamIds.where(teamsById.containsKey).toList();
    teamIds.sort((a, b) => NameCollation.sortKey(teamsById[a]!.displayName(arabic: arabic))
        .compareTo(NameCollation.sortKey(teamsById[b]!.displayName(arabic: arabic))));

    for (final teamId in teamIds) {
      if (!ledger.isSiteSubmitted(teamId)) continue;
      final team = teamsById[teamId]!;
      final workers = sortWorkers(ledger.presentWorkerIdsForTeam(teamId));
      final lastEvent = ledger.lastTeamRecordingEvent(teamId);
      final actorId = lastEvent?.userId;
      final isPast = date != todayBusinessDate;
      final canEdit = (isPast
              ? (actor.capabilities.canEditPastDays && (viewAll || scope.allowsTeam(teamId)))
              : (actor.capabilities.canRecordSite && scope.allowsTeam(teamId))) &&
          _isWithinEditWindow(date, todayBusinessDate);

      final msg = WhatsappTemplateEngine.format(
        kind: WhatsappMessageKind.site, date: date, entityName: team.displayName(arabic: arabic),
        workers: [
          for (final w in workers)
            WhatsappWorkerItem(
              code: w.code, name: w.displayName(arabic: arabic),
              employmentType: w.employmentType, jobCategory: w.jobCategory,
            ),
        ],
        arabic: arabic, strings: strings,
      );

      cards.add(HistoryDayCard(
        kind: HistoryEntryKind.site, entity: team, businessDate: date, workers: workers,
        recordedAtUtc: lastEvent?.deviceTimeUtc, lastActorUserId: actorId,
        lastActorName: actorId == null ? null : userNamesById[actorId],
        canEdit: canEdit, whatsappMessage: msg,
      ));
    }
  }

  static bool _isWithinEditWindow(String date, String today) {
    final target = DateTime.tryParse(date);
    final current = DateTime.tryParse(today);
    if (target == null || current == null) return false;
    final diff = current.difference(target).inDays;
    return diff >= 0 && diff <= OperationsConstants.maxBackdateDays;
  }
}
