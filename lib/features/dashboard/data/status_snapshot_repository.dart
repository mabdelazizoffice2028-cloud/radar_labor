// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_engine.dart';
import 'package:radar_labor/core/status/status_models.dart' as model;
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';

/// Adapts the local Drift ledger into immutable dashboard snapshots.
final class StatusSnapshotRepository {
  const StatusSnapshotRepository({
    required AppDatabase database,
    required EventRepository events,
    required Clock clock,
    StatusEngine engine = const StatusEngine(),
  }) : _database = database,
       _events = events,
       _clock = clock,
       _engine = engine;

  final AppDatabase _database;
  final EventRepository _events;
  final Clock _clock;
  final StatusEngine _engine;

  Stream<model.StatusSnapshot> watch({required bool arabic}) {
    late StreamController<model.StatusSnapshot> controller;
    StreamSubscription<List<Employee>>? employeeSubscription;
    StreamSubscription<List<EmploymentPeriod>>? periodSubscription;
    StreamSubscription<List<model.LocalEvent>>? eventSubscription;
    StreamSubscription<List<Setting>>? settingsSubscription;
    Timer? refreshTimer;
    List<Employee>? employees;
    List<EmploymentPeriod>? periods;
    List<model.LocalEvent>? events;
    List<Setting>? settings;

    void emit() {
      if (employees == null || periods == null || events == null) return;
      final periodGroups = <String, List<model.EmploymentPeriod>>{};
      for (final period in periods!) {
        periodGroups
            .putIfAbsent(period.employeeUid, () => [])
            .add(
              model.EmploymentPeriod(period.startDate, endDate: period.endDate),
            );
      }
      final workers = employees!.map((employee) {
        return model.WorkerProfile(
          employeeUid: employee.employeeUid,
          code: employee.employeeCode,
          fullName: arabic
              ? employee.fullNameAr
              : employee.fullNameEn ?? employee.fullNameAr,
          currentTeamId: employee.currentTeamId,
          housingId: employee.housingId,
          isActive: employee.isActive,
          employmentPeriods: List.unmodifiable(
            periodGroups[employee.employeeUid] ?? const [],
          ),
        );
      });
      final configuredSla = settings
          ?.where((setting) => setting.key == 'sla_minutes')
          .firstOrNull
          ?.value;
      final slaMinutes = int.tryParse(configuredSla ?? '') ?? 120;
      final now = _clock.nowUtc();
      controller.add(
        _engine.evaluate(
          workers: workers,
          events: events!,
          businessDate: businessDateFor(now),
          nowUtc: now,
          slaMinutes: slaMinutes,
        ),
      );
    }

    controller = StreamController<model.StatusSnapshot>(
      onListen: () {
        employeeSubscription = _database
            .select(_database.employees)
            .watch()
            .listen((value) {
              employees = value;
              emit();
            }, onError: controller.addError);
        periodSubscription = _database
            .select(_database.employmentPeriods)
            .watch()
            .listen((value) {
              periods = value;
              emit();
            }, onError: controller.addError);
        eventSubscription = _events.watchAll().listen((value) {
          events = value;
          emit();
        }, onError: controller.addError);
        settingsSubscription = _database
            .select(_database.settings)
            .watch()
            .listen((value) {
              settings = value;
              emit();
            }, onError: controller.addError);
        refreshTimer = Timer.periodic(
          const Duration(minutes: 1),
          (_) => emit(),
        );
      },
      onCancel: () async {
        refreshTimer?.cancel();
        await employeeSubscription?.cancel();
        await periodSubscription?.cancel();
        await eventSubscription?.cancel();
        await settingsSubscription?.cancel();
      },
    );
    return controller.stream;
  }
}
