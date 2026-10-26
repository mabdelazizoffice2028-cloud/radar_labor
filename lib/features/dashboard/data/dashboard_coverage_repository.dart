import 'dart:async';

import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';

enum CoverageKind { housing, team }

final class CoverageWarning {
  const CoverageWarning({
    required this.kind,
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.supervisorNames = const <String>[],
  });

  final CoverageKind kind;
  final String id;
  final String nameAr;
  final String? nameEn;
  final List<String> supervisorNames;
}

final class DashboardCoverage {
  const DashboardCoverage({
    required this.businessDate,
    required this.missingHousings,
    required this.missingTeams,
  });

  final String businessDate;
  final List<CoverageWarning> missingHousings;
  final List<CoverageWarning> missingTeams;
}

/// Watches active reference entities, assigned supervisors, and latest submission for one date.
final class DashboardCoverageRepository {
  const DashboardCoverageRepository({
    required this.database,
    required this.events,
  });

  final AppDatabase database;
  final EventRepository events;

  Stream<DashboardCoverage> watch(String businessDate) {
    late StreamController<DashboardCoverage> controller;
    StreamSubscription<List<Housing>>? housingSubscription;
    StreamSubscription<List<Team>>? teamSubscription;
    StreamSubscription<List<AppUser>>? userSubscription;
    StreamSubscription<List<UserScope>>? scopeSubscription;
    StreamSubscription<List<LocalEvent>>? eventSubscription;
    List<Housing>? housings;
    List<Team>? teams;
    List<AppUser>? activeUsers;
    List<UserScope>? scopes;
    List<LocalEvent>? dayEvents;

    void emit() {
      if (housings == null ||
          teams == null ||
          activeUsers == null ||
          scopes == null ||
          dayEvents == null) {
        return;
      }
      final activeNameById = {
        for (final user in activeUsers!)
          if (user.active) user.id: user.displayName,
      };
      final checkedHousings = _latestKeys(
        dayEvents!.where((event) => event.type == EventType.housingCheck),
        (event) => event.housingId,
      );
      final submittedTeams = _latestKeys(
        dayEvents!.where((event) => event.type == EventType.siteSubmitted),
        (event) => event.teamId,
      );
      controller.add(
        DashboardCoverage(
          businessDate: businessDate,
          missingHousings: List.unmodifiable([
            for (final housing in housings!)
              if (!checkedHousings.contains(housing.housingId))
                CoverageWarning(
                  kind: CoverageKind.housing,
                  id: housing.housingId,
                  nameAr: housing.nameAr,
                  nameEn: housing.nameEn,
                  supervisorNames: _housingSupervisors(
                    housingId: housing.housingId,
                    scopes: scopes!,
                    activeNameById: activeNameById,
                  ),
                ),
          ]),
          missingTeams: List.unmodifiable([
            for (final team in teams!)
              if (!submittedTeams.contains(team.teamId))
                CoverageWarning(
                  kind: CoverageKind.team,
                  id: team.teamId,
                  nameAr: team.nameAr,
                  nameEn: team.nameEn,
                  supervisorNames: _teamSupervisors(
                    team: team,
                    scopes: scopes!,
                    activeNameById: activeNameById,
                  ),
                ),
          ]),
        ),
      );
    }

    controller = StreamController<DashboardCoverage>(
      onListen: () {
        housingSubscription =
            (database.select(database.housings)
                  ..where((row) => row.isActive.equals(true))
                  ..orderBy([(row) => OrderingTerm.asc(row.nameAr)]))
                .watch()
                .listen((value) {
                  housings = value;
                  emit();
                }, onError: controller.addError);
        teamSubscription =
            (database.select(database.teams)
                  ..where((row) => row.isActive.equals(true))
                  ..orderBy([(row) => OrderingTerm.asc(row.nameAr)]))
                .watch()
                .listen((value) {
                  teams = value;
                  emit();
                }, onError: controller.addError);
        userSubscription =
            (database.select(
              database.appUsers,
            )..where((row) => row.active.equals(true))).watch().listen((value) {
              activeUsers = value;
              emit();
            }, onError: controller.addError);
        scopeSubscription = database.select(database.userScopes).watch().listen(
          (value) {
            scopes = value;
            emit();
          },
          onError: controller.addError,
        );
        eventSubscription = events.watchBusinessDate(businessDate).listen((
          value,
        ) {
          dayEvents = value;
          emit();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await housingSubscription?.cancel();
        await teamSubscription?.cancel();
        await userSubscription?.cancel();
        await scopeSubscription?.cancel();
        await eventSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  List<String> _housingSupervisors({
    required String housingId,
    required List<UserScope> scopes,
    required Map<String, String> activeNameById,
  }) {
    final names = <String>{};
    for (final s in scopes) {
      if (s.scopeType == 'housing' && s.scopeId == housingId) {
        final name = activeNameById[s.userId];
        if (name != null && name.isNotEmpty) names.add(name);
      }
    }
    return List.unmodifiable(names.toList()..sort());
  }

  List<String> _teamSupervisors({
    required Team team,
    required List<UserScope> scopes,
    required Map<String, String> activeNameById,
  }) {
    final names = <String>{};
    if (team.supervisorUserId != null) {
      final direct = activeNameById[team.supervisorUserId!];
      if (direct != null && direct.isNotEmpty) names.add(direct);
    }
    for (final s in scopes) {
      if (s.scopeType == 'team' && s.scopeId == team.teamId) {
        final name = activeNameById[s.userId];
        if (name != null && name.isNotEmpty) names.add(name);
      }
    }
    return List.unmodifiable(names.toList()..sort());
  }

  Set<String> _latestKeys(
    Iterable<LocalEvent> source,
    String? Function(LocalEvent) selectKey,
  ) {
    final latest = <String, LocalEvent>{};
    for (final event in source) {
      if (event.delivery == EventDelivery.rejected) continue;
      final key = selectKey(event);
      if (key == null) continue;
      final prior = latest[key];
      if (prior == null || event.deviceSeq > prior.deviceSeq) {
        latest[key] = event;
      }
    }
    return {
      for (final entry in latest.entries)
        if (entry.value.action == EventAction.set) entry.key,
    };
  }
}
