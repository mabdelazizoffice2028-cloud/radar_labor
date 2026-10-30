import 'dart:async';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';

final class TeamSetupWatcher {
  const TeamSetupWatcher(this.database);
  final AppDatabase database;

  Stream<List<SelectableWorker>> watch() {
    late StreamController<List<SelectableWorker>> controller;
    StreamSubscription<List<Employee>>? empSub;
    StreamSubscription<List<Team>>? teamSub;
    List<Employee>? employees;
    List<Team>? teams;

    void emit() {
      if (employees == null || teams == null) return;
      final teamMap = <String, Team>{for (final t in teams!) t.teamId: t};
      final items = <SelectableWorker>[
        for (final emp in employees!)
          SelectableWorker(
            id: emp.employeeUid,
            code: emp.employeeCode,
            nameAr: emp.fullNameAr,
            nameEn: emp.fullNameEn,
            currentTeamId: emp.currentTeamId,
            currentTeamNameAr: teamMap[emp.currentTeamId]?.nameAr,
            currentTeamNameEn: teamMap[emp.currentTeamId]?.nameEn,
          ),
      ];
      controller.add(List.unmodifiable(items));
    }

    controller = StreamController<List<SelectableWorker>>(
      onListen: () {
        empSub = (database.select(database.employees)..where((e) => e.archivedAt.isNull()))
            .watch()
            .listen((rows) { employees = rows; emit(); }, onError: controller.addError);
        teamSub = database.select(database.teams).watch().listen(
          (rows) { teams = rows; emit(); }, onError: controller.addError,
        );
      },
      onCancel: () async {
        await empSub?.cancel();
        await teamSub?.cancel();
      },
    );
    return controller.stream;
  }
}
