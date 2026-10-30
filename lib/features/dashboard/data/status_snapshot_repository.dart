import 'dart:async';
import 'dart:convert';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/leaves/worker_leave.dart';
import 'package:radar_labor/core/status/status_engine.dart';
import 'package:radar_labor/core/status/status_models.dart' as model;
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/dashboard/data/status_snapshot_worker_builder.dart';

final class StatusSnapshotRepository {
  const StatusSnapshotRepository({
    required this.database,
    required this.events,
    required this.clock,
    this.engine = const StatusEngine(),
  });

  final AppDatabase database;
  final EventRepository events;
  final Clock clock;
  final StatusEngine engine;

  Stream<model.StatusSnapshot> watch({required bool arabic, String? businessDate}) {
    late StreamController<model.StatusSnapshot> controller;
    StreamSubscription? subEmp, subPer, subEvt, subSet;
    Timer? refreshTimer;
    List<Employee>? employees;
    List<EmploymentPeriod>? periods;
    List<model.LocalEvent>? events;
    List<Setting>? settings;

    void emit() {
      if (employees == null || periods == null || events == null) return;
      final now = clock.nowUtc();
      final targetDate = businessDate ?? businessDateFor(now);
      final onLeave = _parseOnLeave(settings, targetDate);
      final workers = StatusSnapshotWorkerBuilder.buildProfiles(
        employees: employees!, periods: periods!, arabic: arabic, onLeaveIds: onLeave,
      );
      final rawSla = settings?.where((s) => s.key == AppSettingKeys.slaMinutes).firstOrNull?.value;
      final slaMinutes = int.tryParse(rawSla ?? '') ?? 120;
      controller.add(engine.evaluate(
        workers: workers, events: events!, businessDate: targetDate, nowUtc: now, slaMinutes: slaMinutes,
      ));
    }

    controller = StreamController<model.StatusSnapshot>(
      onListen: () {
        subEmp = database.select(database.employees).watch().listen((v) { employees = v; emit(); }, onError: controller.addError);
        subPer = database.select(database.employmentPeriods).watch().listen((v) { periods = v; emit(); }, onError: controller.addError);
        subEvt = this.events.watchAll().listen((v) { events = v; emit(); }, onError: controller.addError);
        subSet = database.select(database.settings).watch().listen((v) { settings = v; emit(); }, onError: controller.addError);
        refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) => emit());
      },
      onCancel: () async {
        refreshTimer?.cancel();
        await Future.wait([subEmp?.cancel() ?? Future.value(), subPer?.cancel() ?? Future.value(), subEvt?.cancel() ?? Future.value(), subSet?.cancel() ?? Future.value()]);
      },
    );
    return controller.stream;
  }

  static Set<String> _parseOnLeave(List<Setting>? settings, String date) {
    final raw = settings?.where((s) => s.key == AppSettingKeys.workerLeaves).firstOrNull?.value;
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => WorkerLeave.fromJson(e as Map<String, dynamic>)).where((l) => l.coversDate(date)).map((l) => l.employeeUid).toSet();
    } on Exception {
      return const {};
    }
  }
}
