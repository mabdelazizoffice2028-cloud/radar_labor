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
  });

  final CoverageKind kind;
  final String id;
  final String nameAr;
  final String? nameEn;
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

/// Watches active reference entities and their latest submission for one date.
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
    StreamSubscription<List<LocalEvent>>? eventSubscription;
    List<Housing>? housings;
    List<Team>? teams;
    List<LocalEvent>? dayEvents;

    void emit() {
      if (housings == null || teams == null || dayEvents == null) return;
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
        await eventSubscription?.cancel();
      },
    );
    return controller.stream;
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
