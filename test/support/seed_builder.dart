import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';

/// Deterministic synthetic test fixture builder (no real PII, PRD §15, §17.1).
final class SeedBuilder {
  SeedBuilder({required this.database, required this.events});

  final AppDatabase database;
  final EventRepository events;

  Future<void> seedTeam({
    required String id,
    required String nameAr,
    String? nameEn,
    String? supervisorUserId,
    bool isActive = true,
  }) async {
    await database
        .into(database.teams)
        .insert(
          TeamsCompanion.insert(
            teamId: id,
            nameAr: nameAr,
            nameEn: Value(nameEn),
            supervisorUserId: Value(supervisorUserId),
            isActive: Value(isActive),
          ),
        );
  }

  Future<void> seedHousing({
    required String id,
    required String nameAr,
    String? nameEn,
    bool isActive = true,
  }) async {
    // Housings table removed in V2 architecture (single campus).
  }

  Future<void> seedWorker({
    required String uid,
    required String code,
    required String nameAr,
    String? nameEn,
    String? teamId,
    String? housingId,
    bool isActive = true,
  }) async {
    await database
        .into(database.employees)
        .insert(
          EmployeesCompanion.insert(
            iqamaNo: uid,
            fullNameAr: nameAr,
            fullNameEn: Value(nameEn),
            currentTeamId: Value(teamId),
            archivedAt: Value(isActive ? null : DateTime.now().toUtc()),
          ),
        );
  }

  Future<void> seedUser({
    required String id,
    required String employeeUid,
    required String displayName,
    required AuthRole role,
    bool active = true,
    List<String> teamIds = const [],
    List<String> housingIds = const [],
  }) async {
    await database
        .into(database.appUsers)
        .insert(
          AppUsersCompanion.insert(
            id: id,
            employeeUid: Value(employeeUid),
            displayName: displayName,
            role: role.name,
            pwHash: 'synthetic-hash',
            pwSalt: 'synthetic-salt',
            kdfParams: '{"m":19456,"t":2,"p":1}',
            active: Value(active),
            createdAt: DateTime.utc(2026, 10, 23, 8),
          ),
        );
    var index = 0;
    for (final tid in teamIds) {
      index++;
      await database
          .into(database.userScopes)
          .insert(
            UserScopesCompanion.insert(
              id: '$id-team-$index',
              userId: id,
              scopeType: 'team',
              scopeId: tid,
            ),
          );
    }
    for (final hid in housingIds) {
      index++;
      await database
          .into(database.userScopes)
          .insert(
            UserScopesCompanion.insert(
              id: '$id-housing-$index',
              userId: id,
              scopeType: 'housing',
              scopeId: hid,
            ),
          );
    }
  }

  Future<List<LocalEvent>> seedSiteAttendance({
    required String businessDate,
    required String teamId,
    required Iterable<String> presentWorkerUids,
    String? actorUserId,
  }) {
    final uids = presentWorkerUids.toList();
    return events.appendBatch([
      for (final uid in uids)
        EventDraft(
          type: EventType.sitePresent,
          action: EventAction.set,
          businessDate: businessDate,
          employeeUid: uid,
          teamId: teamId,
          userId: actorUserId,
        ),
      EventDraft(
        type: EventType.siteSubmitted,
        action: EventAction.set,
        businessDate: businessDate,
        teamId: teamId,
        userId: actorUserId,
        payload: {'presentCount': uids.length},
      ),
    ]);
  }
}
