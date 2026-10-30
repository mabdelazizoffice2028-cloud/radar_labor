import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/data/team_setup_validator.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';
import 'package:uuid/uuid.dart';

final class TeamSetupCreator {
  const TeamSetupCreator({required this.database, this.uuid = const Uuid()});
  final AppDatabase database;
  final Uuid uuid;

  Future<EntityOption> create({
    required ActorContext actor, required String nameAr, String? nameEn, required Set<String> workerIds,
  }) async {
    ScopeGuard.guardTeamSetup(actor);
    final val = await TeamSetupValidator.validate(database: database, nameAr: nameAr, nameEn: nameEn);
    final teamId = uuid.v4();

    return database.transaction(() async {
      final existingTeams = await database.select(database.teams).get();
      final keyAr = NameCollation.sortKey(val.nameAr);
      for (final existing in existingTeams) {
        if (NameCollation.sortKey(existing.nameAr) == keyAr) throw const OperationException(TeamNameExists());
      }

      await database.into(database.teams).insert(TeamsCompanion.insert(
        teamId: teamId, nameAr: val.nameAr, nameEn: Value(val.nameEn),
        supervisorUserId: Value(actor.userId), isActive: const Value(true),
      ));

      final existingScope = await (database.select(database.userScopes)
            ..where((s) => s.userId.equals(actor.userId) & s.scopeType.equals('team') & s.scopeId.equals(teamId)))
          .getSingleOrNull();
      if (existingScope == null) {
        await database.into(database.userScopes).insert(
          UserScopesCompanion.insert(id: uuid.v4(), userId: actor.userId, scopeType: 'team', scopeId: teamId),
        );
      }

      if (workerIds.isNotEmpty) {
        final rows = await (database.select(database.employees)..where((e) => e.iqamaNo.isIn(workerIds.toList()))).get();
        final byId = <String, Employee>{for (final r in rows) r.employeeUid: r};
        final unavail = <String>{};
        for (final wid in workerIds) {
          final emp = byId[wid];
          if (emp == null || !emp.isActive || emp.currentTeamId != null) unavail.add(wid);
        }
        if (unavail.isNotEmpty) throw OperationException(WorkersUnavailable(Set.unmodifiable(unavail)));

        for (final emp in rows) {
          await (database.update(database.employees)..where((e) => e.iqamaNo.equals(emp.employeeUid))).write(
            EmployeesCompanion(currentTeamId: Value(teamId), rowVersion: Value(emp.rowVersion + 1)),
          );
        }
      }
      return EntityOption(id: teamId, nameAr: val.nameAr, nameEn: val.nameEn);
    });
  }
}
