import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';

final class TeamSetupUpdater {
  const TeamSetupUpdater(this.database);
  final AppDatabase database;

  Future<void> updateMembers({
    required ActorContext actor, required ScopeSnapshot scope,
    required String teamId, required Set<String> workerIds,
  }) async {
    ScopeGuard.guardTeamEdit(actor: actor, scope: scope, teamId: teamId);
    await database.transaction(() async {
      final scopeRow = await (database.select(database.userScopes)
            ..where((s) => s.userId.equals(actor.userId) & s.scopeType.equals('team') & s.scopeId.equals(teamId)))
          .getSingleOrNull();
      if (scopeRow == null) throw const OperationException(ScopeChanged());

      final current = await (database.select(database.employees)..where((e) => e.currentTeamId.equals(teamId))).get();
      final currentIds = {for (final m in current) m.employeeUid};
      final toRemove = currentIds.difference(workerIds);
      final toAdd = workerIds.difference(currentIds);

      if (toAdd.isNotEmpty) {
        final candidates = await (database.select(database.employees)..where((e) => e.iqamaNo.isIn(toAdd.toList()))).get();
        final byId = <String, Employee>{for (final c in candidates) c.employeeUid: c};
        final unavail = <String>{};
        for (final wid in toAdd) {
          final emp = byId[wid];
          if (emp == null || !emp.isActive || (emp.currentTeamId != null && emp.currentTeamId != teamId)) {
            unavail.add(wid);
          }
        }
        if (unavail.isNotEmpty) throw OperationException(WorkersUnavailable(Set.unmodifiable(unavail)));

        for (final emp in candidates) {
          await (database.update(database.employees)..where((e) => e.iqamaNo.equals(emp.employeeUid))).write(
            EmployeesCompanion(currentTeamId: Value(teamId), rowVersion: Value(emp.rowVersion + 1)),
          );
        }
      }

      for (final emp in current) {
        if (toRemove.contains(emp.employeeUid)) {
          await (database.update(database.employees)..where((e) => e.iqamaNo.equals(emp.employeeUid))).write(
            EmployeesCompanion(currentTeamId: const Value(null), rowVersion: Value(emp.rowVersion + 1)),
          );
        }
      }
    });
  }
}
