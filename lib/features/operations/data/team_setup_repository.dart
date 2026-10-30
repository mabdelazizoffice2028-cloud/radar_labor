import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/features/operations/data/team_setup_creator.dart';
import 'package:radar_labor/features/operations/data/team_setup_updater.dart';
import 'package:radar_labor/features/operations/data/team_setup_validator.dart';
import 'package:radar_labor/features/operations/data/team_setup_watcher.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:uuid/uuid.dart';

final class TeamSetupRepository implements TeamSetupStore {
  const TeamSetupRepository({required this.database, this.uuid = const Uuid()});
  final AppDatabase database;
  final Uuid uuid;

  @override
  Stream<List<SelectableWorker>> watchActiveWorkersWithTeams() =>
      TeamSetupWatcher(database).watch();

  Future<({String nameAr, String? nameEn})> validateTeamName({
    required String nameAr,
    String? nameEn,
  }) => TeamSetupValidator.validate(database: database, nameAr: nameAr, nameEn: nameEn);

  @override
  Future<EntityOption> createTeam({
    required ActorContext actor,
    required String nameAr,
    String? nameEn,
    required Set<String> workerIds,
  }) => TeamSetupCreator(database: database, uuid: uuid).create(
        actor: actor,
        nameAr: nameAr,
        nameEn: nameEn,
        workerIds: workerIds,
      );

  @override
  Future<void> updateTeamMembers({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
    required Set<String> workerIds,
  }) => TeamSetupUpdater(database).updateMembers(
        actor: actor,
        scope: scope,
        teamId: teamId,
        workerIds: workerIds,
      );
}
