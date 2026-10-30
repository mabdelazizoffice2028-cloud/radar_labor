import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/app/local_accounts_screen.dart';
import 'package:radar_labor/app/screens/preferences_screen.dart';
import 'package:radar_labor/app/screens/workers_screen.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_screen.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/history_screen.dart';
import 'package:radar_labor/features/operations/presentation/operations_screen.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

final class HomeScaffoldPageRouter {
  static Widget buildPage({
    required AppSection section, required WidgetRef ref, required bool ar,
    required String locale, required RoleCapabilities capabilities, required ActorContext actor,
    required ScopeSnapshot scope, required OperationsController controller,
    required AppDatabase database, required EventRepository events, required LocalAccount account,
    required VoidCallback onLogout, required VoidCallback onChangePassword,
    required void Function(EntityOption, String) onEditSiteDay,
  }) => switch (section) {
    AppSection.dashboard => DashboardScreen(
      statusRepository: ref.watch(statusSnapshotRepositoryProvider),
      coverageRepository: ref.watch(dashboardCoverageRepositoryProvider),
      actionsRepository: ref.watch(dashboardActionsRepositoryProvider),
      arabic: ar, actorUserId: account.id,
      canEdit: capabilities.canResolveConflicts || capabilities.canJustifyAbsence,
    ),
    AppSection.workers => WorkersScreen(database: database, events: events, arabic: ar),
    AppSection.users => LocalAccountsScreen(database: database, arabic: ar),
    AppSection.checkIn => OperationsScreen(
      controller: controller, arabic: ar, role: account.role,
      teamSetupStore: ref.watch(teamSetupStoreProvider), actor: actor, scope: scope,
    ),
    AppSection.history => HistoryScreen(
      arabic: ar, actor: actor, scope: scope,
      onEditSiteDay: (t, d) => onEditSiteDay(t, d),
    ),
    AppSection.settings => PreferencesScreen(
      arabic: ar, locale: locale,
      onLocale: (val) => ref.read(appLocaleProvider.notifier).setLocale(val),
      database: database, account: account, onLogout: onLogout,
      onChangePassword: onChangePassword,
    ),
  };
}
