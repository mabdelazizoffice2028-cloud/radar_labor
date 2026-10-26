import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

/// Kind of recorded daily operation in History (PRD §11).
enum HistoryEntryKind { site, housing }

/// Single recorded day card for a team or housing in History (PRD §11.1, §11.3).
final class HistoryDayCard {
  const HistoryDayCard({
    required this.kind,
    required this.entity,
    required this.businessDate,
    required this.workers,
    required this.canEdit,
    required this.whatsappMessage,
    this.recordedAtUtc,
    this.lastActorUserId,
    this.lastActorName,
  });

  final HistoryEntryKind kind;
  final EntityOption entity;
  final String businessDate;
  final List<WorkerOption> workers;
  final DateTime? recordedAtUtc;
  final String? lastActorUserId;
  final String? lastActorName;
  final bool canEdit;
  final String whatsappMessage;

  int get count => workers.length;
}

/// Paginated history result with pre-grouped views for Admin and Supervisors (PRD §11).
final class HistoryPage {
  const HistoryPage({
    required this.cards,
    required this.fromDate,
    required this.toDate,
    required this.hasMore,
    required this.bySite,
    required this.bySupervisor,
  });

  final List<HistoryDayCard> cards;
  final String fromDate;
  final String toDate;
  final bool hasMore;
  final Map<String, List<HistoryDayCard>> bySite;
  final Map<String, List<HistoryDayCard>> bySupervisor;
}

/// Persistence contract for loading paginated history (PRD §11).
abstract interface class HistoryStore {
  String currentBusinessDate();

  Future<HistoryPage> loadHistory({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required int daysWindow,
    required bool arabic,
  });
}
