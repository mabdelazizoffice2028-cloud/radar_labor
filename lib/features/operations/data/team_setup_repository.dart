import 'dart:async';

import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:uuid/uuid.dart';

/// Atomic repository for supervisor team setup wizard and member editing (PRD §7.3, §7.4).
final class TeamSetupRepository implements TeamSetupStore {
  const TeamSetupRepository({required this.database, this.uuid = const Uuid()});

  final AppDatabase database;
  final Uuid uuid;

  static final RegExp _whitespace = RegExp(r'\s+');

  @override
  Stream<List<SelectableWorker>> watchActiveWorkersWithTeams() {
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
        empSub =
            (database.select(
              database.employees,
            )..where((e) => e.isActive.equals(true))).watch().listen((rows) {
              employees = rows;
              emit();
            }, onError: controller.addError);
        teamSub = database.select(database.teams).watch().listen((rows) {
          teams = rows;
          emit();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await empSub?.cancel();
        await teamSub?.cancel();
      },
    );
    return controller.stream;
  }

  /// Validates [nameAr] and [nameEn] against length and duplicate rules (PRD §7.2).
  Future<({String nameAr, String? nameEn})> validateTeamName({
    required String nameAr,
    String? nameEn,
  }) async {
    final normAr = nameAr.trim().replaceAll(_whitespace, ' ');
    final normEn = nameEn?.trim().replaceAll(_whitespace, ' ');
    if (normAr.isEmpty ||
        normAr.length > OperationsConstants.teamNameMaxLength) {
      throw const OperationException(TeamNameInvalid());
    }
    if (normEn != null &&
        normEn.length > OperationsConstants.teamNameMaxLength) {
      throw const OperationException(TeamNameInvalid());
    }

    final existingTeams = await database.select(database.teams).get();
    final keyAr = NameCollation.sortKey(normAr);
    final keyEn = (normEn != null && normEn.isNotEmpty)
        ? NameCollation.sortKey(normEn)
        : null;

    for (final existing in existingTeams) {
      if (NameCollation.sortKey(existing.nameAr) == keyAr) {
        throw const OperationException(TeamNameExists());
      }
      if (keyEn != null &&
          existing.nameEn != null &&
          NameCollation.sortKey(existing.nameEn!) == keyEn) {
        throw const OperationException(TeamNameExists());
      }
    }
    return (
      nameAr: normAr,
      nameEn: (normEn == null || normEn.isEmpty) ? null : normEn,
    );
  }

  @override
  Future<EntityOption> createTeam({
    required ActorContext actor,
    required String nameAr,
    String? nameEn,
    required Set<String> workerIds,
  }) async {
    ScopeGuard.guardTeamSetup(actor);
    final validated = await validateTeamName(nameAr: nameAr, nameEn: nameEn);
    final teamId = uuid.v4();

    return database.transaction(() async {
      // Re-check duplicate name inside transaction
      final existingTeams = await database.select(database.teams).get();
      final keyAr = NameCollation.sortKey(validated.nameAr);
      for (final existing in existingTeams) {
        if (NameCollation.sortKey(existing.nameAr) == keyAr) {
          throw const OperationException(TeamNameExists());
        }
      }

      await database
          .into(database.teams)
          .insert(
            TeamsCompanion.insert(
              teamId: teamId,
              nameAr: validated.nameAr,
              nameEn: Value(validated.nameEn),
              supervisorUserId: Value(actor.userId),
              isActive: const Value(true),
            ),
          );

      // Programmatic guard against duplicate user_scopes row (PRD §2, §7.3)
      final existingScope =
          await (database.select(database.userScopes)..where(
                (s) =>
                    s.userId.equals(actor.userId) &
                    s.scopeType.equals('team') &
                    s.scopeId.equals(teamId),
              ))
              .getSingleOrNull();
      if (existingScope == null) {
        await database
            .into(database.userScopes)
            .insert(
              UserScopesCompanion.insert(
                id: uuid.v4(),
                userId: actor.userId,
                scopeType: 'team',
                scopeId: teamId,
              ),
            );
      }

      if (workerIds.isNotEmpty) {
        final rows = await (database.select(
          database.employees,
        )..where((e) => e.employeeUid.isIn(workerIds.toList()))).get();
        final byId = <String, Employee>{for (final r in rows) r.employeeUid: r};
        final unavailable = <String>{};
        for (final wid in workerIds) {
          final emp = byId[wid];
          if (emp == null || !emp.isActive || emp.currentTeamId != null) {
            unavailable.add(wid);
          }
        }
        if (unavailable.isNotEmpty) {
          throw OperationException(
            WorkersUnavailable(Set.unmodifiable(unavailable)),
          );
        }

        for (final emp in rows) {
          await (database.update(
            database.employees,
          )..where((e) => e.employeeUid.equals(emp.employeeUid))).write(
            EmployeesCompanion(
              currentTeamId: Value(teamId),
              rowVersion: Value(emp.rowVersion + 1),
            ),
          );
        }
      }

      return EntityOption(
        id: teamId,
        nameAr: validated.nameAr,
        nameEn: validated.nameEn,
      );
    });
  }

  @override
  Future<void> updateTeamMembers({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
    required Set<String> workerIds,
  }) async {
    ScopeGuard.guardTeamEdit(actor: actor, scope: scope, teamId: teamId);

    await database.transaction(() async {
      final scopeRow =
          await (database.select(database.userScopes)..where(
                (s) =>
                    s.userId.equals(actor.userId) &
                    s.scopeType.equals('team') &
                    s.scopeId.equals(teamId),
              ))
              .getSingleOrNull();
      if (scopeRow == null) {
        throw const OperationException(ScopeChanged());
      }

      final currentMembers = await (database.select(
        database.employees,
      )..where((e) => e.currentTeamId.equals(teamId))).get();
      final currentMemberIds = {for (final m in currentMembers) m.employeeUid};

      final toRemove = currentMemberIds.difference(workerIds);
      final toAdd = workerIds.difference(currentMemberIds);

      if (toAdd.isNotEmpty) {
        final candidates = await (database.select(
          database.employees,
        )..where((e) => e.employeeUid.isIn(toAdd.toList()))).get();
        final byId = <String, Employee>{
          for (final c in candidates) c.employeeUid: c,
        };
        final unavailable = <String>{};
        for (final wid in toAdd) {
          final emp = byId[wid];
          if (emp == null ||
              !emp.isActive ||
              (emp.currentTeamId != null && emp.currentTeamId != teamId)) {
            unavailable.add(wid);
          }
        }
        if (unavailable.isNotEmpty) {
          throw OperationException(
            WorkersUnavailable(Set.unmodifiable(unavailable)),
          );
        }
        for (final emp in candidates) {
          await (database.update(
            database.employees,
          )..where((e) => e.employeeUid.equals(emp.employeeUid))).write(
            EmployeesCompanion(
              currentTeamId: Value(teamId),
              rowVersion: Value(emp.rowVersion + 1),
            ),
          );
        }
      }

      for (final emp in currentMembers) {
        if (toRemove.contains(emp.employeeUid)) {
          await (database.update(
            database.employees,
          )..where((e) => e.employeeUid.equals(emp.employeeUid))).write(
            EmployeesCompanion(
              currentTeamId: const Value(null),
              rowVersion: Value(emp.rowVersion + 1),
            ),
          );
        }
      }
    });
  }
}
