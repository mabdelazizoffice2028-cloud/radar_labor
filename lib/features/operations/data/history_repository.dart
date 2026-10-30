import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/history_date_helper.dart';
import 'package:radar_labor/features/operations/domain/history_builder.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';

final class HistoryRepository implements HistoryStore {
  const HistoryRepository({required this.database, required this.events, required this.clock});
  final AppDatabase database;
  final EventRepository events;
  final Clock clock;

  @override
  String currentBusinessDate() => businessDateFor(clock.nowUtc());

  @override
  Future<HistoryPage> loadHistory({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required int daysWindow,
    required bool arabic,
  }) async {
    ScopeGuard.requireCapability(actor.capabilities.canViewAllHistory || actor.capabilities.canViewOwnHistory);
    final today = currentBusinessDate();
    final (fromDate, olderFrom, olderTo) = HistoryDateHelper.computeRange(today: today, daysWindow: daysWindow);

    final rangeEvents = await events.readBusinessDateRange(fromDate: fromDate, toDate: today);
    final olderEvents = await events.readBusinessDateRange(fromDate: olderFrom, toDate: olderTo);

    final allTeams = await database.select(database.teams).get();
    final allEmployees = await database.select(database.employees).get();
    final allUsers = await database.select(database.appUsers).get();

    final teamsById = {for (final t in allTeams) t.teamId: EntityOption(id: t.teamId, nameAr: t.nameAr, nameEn: t.nameEn)};
    const housingsById = {
      HousingConstants.defaultHousingId: EntityOption(
        id: HousingConstants.defaultHousingId,
        nameAr: HousingConstants.defaultHousingNameAr,
        nameEn: HousingConstants.defaultHousingName,
      ),
    };
    final workersById = {
      for (final e in allEmployees)
        e.employeeUid: WorkerOption(
          id: e.employeeUid, code: e.employeeCode, nameAr: e.fullNameAr, nameEn: e.fullNameEn,
          employmentType: e.employmentType, jobCategory: e.jobCategory,
        ),
    };
    final userNamesById = {for (final u in allUsers) u.id: u.displayName};

    return HistoryBuilder.build(
      rangeEvents: rangeEvents,
      actor: actor,
      scope: scope,
      teamsById: teamsById,
      housingsById: housingsById,
      workersById: workersById,
      userNamesById: userNamesById,
      todayBusinessDate: today,
      fromDate: fromDate,
      toDate: today,
      hasMore: olderEvents.isNotEmpty,
      arabic: arabic,
    );
  }
}
