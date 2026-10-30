import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/site_attendance_screen.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';

abstract final class HomeSiteEditor {
  static void open({
    required BuildContext context,
    required WidgetRef ref,
    required EntityOption team,
    required String date,
    required OperationsController controller,
    required bool arabic,
    required ActorContext actor,
    required ScopeSnapshot scope,
  }) {
    unawaited(ref.read(siteAttendanceNotifierProvider.notifier).openTeamAndDate(team: team, date: date));
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SiteAttendanceScreen(
        controller: controller,
        arabic: arabic,
        teamSetupStore: ref.read(teamSetupStoreProvider),
        actor: actor,
        scope: scope,
      ),
    ));
  }
}
