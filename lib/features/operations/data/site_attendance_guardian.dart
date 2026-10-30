import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/database/lockout_settings_extension.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';

final class SiteAttendanceGuardian {
  static Stream<List<EntityOption>> watchScopedTeams(AppDatabase database, Set<String> allowedTeamIds) =>
      (database.select(database.teams)..where((r) => r.isActive)).watch().map(
        (rows) => List.unmodifiable([for (final r in rows) if (allowedTeamIds.contains(r.teamId)) EntityOption(id: r.teamId, nameAr: r.nameAr, nameEn: r.nameEn)]),
      );

  static Future<void> guard({
    required AppDatabase database,
    required Clock clock,
    required ActorContext actor,
    required ScopeSnapshot scope,
    required String teamId,
    required String date,
    required String todayBusinessDate,
  }) async {
    final lockout = await LocalSettingsRepository(database).readSiteLockoutHour();
    ScopeGuard.guardSiteRecord(
      actor: actor, scope: scope, teamId: teamId, date: date,
      todayBusinessDate: todayBusinessDate, nowUtc: clock.nowUtc(), lockoutHour: lockout,
    );
  }
}
