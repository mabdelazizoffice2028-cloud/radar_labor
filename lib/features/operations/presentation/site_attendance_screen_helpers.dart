import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';
import 'package:radar_labor/features/operations/presentation/site_attendance_save_handler.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_edit_screen.dart';
import 'package:radar_labor/features/operations/presentation/team_setup/team_wizard_screen.dart';

abstract final class SiteAttendanceScreenHelpers {
  static List<EntityOption> buildTeams(List<EntityOption>? raw) {
    final rawTeams = raw ?? const <EntityOption>[];
    return [
      ...rawTeams,
      EntityOption(
        id: OperationsConstants.noTeamId,
        nameAr: OperationsStrings.directWorkersNoTeam(true),
        nameEn: OperationsStrings.directWorkersNoTeam(false),
      ),
    ];
  }

  static void ensureSelected(SiteAttendanceNotifier n, SiteAttendanceState s, List<EntityOption> t, String? initId) {
    if (initId != null && s.selectedTeam == null) {
      unawaited(n.selectTeam(t.firstWhere((x) => x.id == initId, orElse: () => t.first)));
    } else {
      unawaited(n.ensureInitialTeam(t));
    }
  }

  static EntityOption? resolveSelected(SiteAttendanceState s, List<EntityOption> t, String? initId) =>
      s.selectedTeam ?? (initId != null ? t.firstWhere((x) => x.id == initId, orElse: () => t.first) : t.firstOrNull);

  static bool canEdit(ActorContext? a, TeamSetupStore? store, EntityOption? sel) {
    final caps = a?.capabilities;
    final allowed = caps?.canEditOwnTeamMembers ?? caps?.canSetupTeam ?? false;
    return store != null && allowed && sel != null && sel.id != OperationsConstants.noTeamId;
  }

  static Future<void> openEdit(BuildContext ctx, WidgetRef ref, TeamSetupStore? s, ActorContext? a, ScopeSnapshot? sc, EntityOption team, bool ar) async {
    if (s == null || a == null || sc == null) return;
    final ok = await Navigator.push<bool>(ctx, MaterialPageRoute(
      builder: (_) => TeamEditScreen(store: s, actor: a, scope: sc, team: team, arabic: ar),
    ));
    if (ok == true && ctx.mounted) await ref.read(siteAttendanceNotifierProvider.notifier).reload();
  }

  static Future<void> openCreate(BuildContext ctx, WidgetRef ref, TeamSetupStore? s, ActorContext? a, bool ar) async {
    if (s == null || a == null) return;
    await Navigator.push(ctx, MaterialPageRoute(builder: (_) => TeamWizardScreen(store: s, actor: a, arabic: ar)));
    if (ctx.mounted) await ref.read(siteAttendanceNotifierProvider.notifier).reload();
  }

  static void save(BuildContext ctx, WidgetRef ref, bool ar, ActorContext? a, ScopeSnapshot? sc) =>
      SiteAttendanceSaveHandler.handleSave(context: ctx, ref: ref, arabic: ar, actor: a, scope: sc);
}
