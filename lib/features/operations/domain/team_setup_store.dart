import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

/// Worker row with team assignment metadata for the team setup wizard and team member editor (PRD §7).
final class SelectableWorker {
  const SelectableWorker({
    required this.id,
    required this.code,
    required this.nameAr,
    this.nameEn,
    this.currentTeamId,
    this.currentTeamNameAr,
    this.currentTeamNameEn,
  });

  final String id;
  final String code;
  final String nameAr;
  final String? nameEn;
  final String? currentTeamId;
  final String? currentTeamNameAr;
  final String? currentTeamNameEn;

  String displayName({required bool arabic}) =>
      (nameEn != null && nameEn!.trim().isNotEmpty) ? nameEn! : nameAr;

  String? assignedTeamName({required bool arabic}) {
    if (currentTeamId == null) return null;
    return (currentTeamNameEn != null && currentTeamNameEn!.trim().isNotEmpty)
        ? currentTeamNameEn
        : (currentTeamNameAr ?? currentTeamId);
  }
}

/// Persistence contract for supervisor team creation wizard and member editing (PRD §7).
abstract interface class TeamSetupStore {
  Stream<List<SelectableWorker>> watchActiveWorkersWithTeams();

  Future<EntityOption> createTeam({
    required ActorContext actor,
    required String nameAr,
    String? nameEn,
    required Set<String> workerIds,
  });

  Future<void> updateTeamMembers({
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
    required Set<String> workerIds,
  });
}
