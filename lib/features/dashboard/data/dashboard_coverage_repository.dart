import 'dart:async';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/models/housing_option.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_coverage_resolver.dart';
import 'package:radar_labor/features/dashboard/domain/dashboard_coverage_models.dart';

export 'package:radar_labor/features/dashboard/domain/dashboard_coverage_models.dart';

final class DashboardCoverageRepository {
  const DashboardCoverageRepository({required this.database, required this.events});
  final AppDatabase database;
  final EventRepository events;
  static const _resolver = DashboardCoverageResolver();

  Stream<DashboardCoverage> watch(String businessDate) {
    late StreamController<DashboardCoverage> controller;
    StreamSubscription? subTeams, subUsers, subScopes, subEvents;
    List<Team>? teams;
    List<AppUser>? activeUsers;
    List<UserScope>? scopes;
    List<LocalEvent>? dayEvents;
    const housings = [
      HousingOption(
        housingId: HousingConstants.defaultHousingId,
        nameAr: HousingConstants.defaultHousingNameAr,
        nameEn: HousingConstants.defaultHousingName,
      ),
    ];

    void emit() {
      if (teams == null || activeUsers == null || scopes == null || dayEvents == null) return;
      final activeNames = {for (final u in activeUsers!) if (u.active) u.id: u.displayName};
      final checkedHousings = _resolver.latestKeys(dayEvents!.where((e) => e.type == EventType.housingCheck), (e) => e.housingId);
      final submittedTeams = _resolver.latestKeys(dayEvents!.where((e) => e.type == EventType.siteSubmitted), (e) => e.teamId);

      controller.add(DashboardCoverage(
        businessDate: businessDate,
        missingHousings: [
          for (final h in housings)
            if (!checkedHousings.contains(h.housingId))
              CoverageWarning(
                kind: CoverageKind.housing,
                id: h.housingId,
                nameAr: h.nameAr,
                nameEn: h.nameEn,
                supervisorNames: _resolver.housingSupervisors(housingId: h.housingId, scopes: scopes!, activeNameById: activeNames),
              ),
        ],
        missingTeams: [
          for (final t in teams!)
            if (!submittedTeams.contains(t.teamId))
              CoverageWarning(
                kind: CoverageKind.team,
                id: t.teamId,
                nameAr: t.nameAr,
                nameEn: t.nameEn,
                supervisorNames: _resolver.teamSupervisors(team: t, scopes: scopes!, activeNameById: activeNames),
              ),
        ],
      ));
    }

    controller = StreamController<DashboardCoverage>(
      onListen: () {
        subTeams = (database.select(database.teams)..where((r) => r.isActive)).watch().listen((v) { teams = v; emit(); }, onError: controller.addError);
        subUsers = (database.select(database.appUsers)..where((r) => r.active.equals(true))).watch().listen((v) { activeUsers = v; emit(); }, onError: controller.addError);
        subScopes = database.select(database.userScopes).watch().listen((v) { scopes = v; emit(); }, onError: controller.addError);
        subEvents = events.watchBusinessDate(businessDate).listen((v) { dayEvents = v; emit(); }, onError: controller.addError);
      },
      onCancel: () async {
        await subTeams?.cancel(); await subUsers?.cancel(); await subScopes?.cancel(); await subEvents?.cancel();
      },
    );
    return controller.stream;
  }
}
