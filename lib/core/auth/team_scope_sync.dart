import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/user_scope_storage.dart';
import 'package:radar_labor/core/database/app_database.dart';

/// Atomically syncs user team scopes with the teams table supervisor assignments.
final class TeamScopeSync {
  const TeamScopeSync(this._database);
  final AppDatabase _database;

  Future<void> syncScopes({
    required String userId,
    required List<String> teamIds,
    required List<String> housingIds,
  }) async {
    await (_database.update(_database.teams)
          ..where((t) => t.supervisorUserId.equals(userId)))
        .write(const TeamsCompanion(supervisorUserId: Value(null)));

    if (teamIds.isNotEmpty) {
      await (_database.delete(_database.userScopes)
            ..where((s) =>
                s.scopeType.equals('team') &
                s.scopeId.isIn(teamIds) &
                s.userId.equals(userId).not()))
          .go();
      await (_database.update(_database.teams)
            ..where((t) => t.teamId.isIn(teamIds)))
          .write(TeamsCompanion(supervisorUserId: Value(userId)));
    }

    await (_database.delete(_database.userScopes)
          ..where((s) => s.userId.equals(userId)))
        .go();
    await insertUserScopes(_database, userId, teamIds, housingIds);
  }

  Future<void> clearSupervisor(String userId) => (_database.update(_database.teams)
        ..where((t) => t.supervisorUserId.equals(userId)))
      .write(const TeamsCompanion(supervisorUserId: Value(null)));
}
