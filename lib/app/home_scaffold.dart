import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/app/screens/entities_screen.dart';
import 'package:radar_labor/app/screens/preferences_screen.dart';
import 'package:radar_labor/app/screens/workers_screen.dart';
import 'package:radar_labor/app/widgets/home_date_badge.dart';
import 'package:radar_labor/app/widgets/sync_status_badge.dart';
import 'package:radar_labor/app/widgets/user_password_change_dialog.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_screen.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/history_screen.dart';
import 'package:radar_labor/features/operations/presentation/operations_screen.dart';
import 'package:radar_labor/features/operations/presentation/state/history_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';

/// Main scaffold hosting the bottom navigation bar and primary feature views (BC-1, PRD §5.2, §5.4).
final class HomeScaffold extends ConsumerStatefulWidget {
  const HomeScaffold({
    required this.database,
    required this.events,
    required this.account,
    required this.onLogout,
    super.key,
  });

  final AppDatabase database;
  final EventRepository events;
  final LocalAccount account;
  final VoidCallback onLogout;

  @override
  ConsumerState<HomeScaffold> createState() => _HomeScaffoldState();
}

final class _HomeScaffoldState extends ConsumerState<HomeScaffold> {
  int _tab = 0;

  void _openEditSiteDay(
    List<AppSection> sections,
    EntityOption team,
    String date,
  ) {
    final idx = sections.indexOf(AppSection.checkIn);
    if (idx >= 0) setState(() => _tab = idx);
    unawaited(
      ref
          .read(siteAttendanceNotifierProvider.notifier)
          .openTeamAndDate(team: team, date: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final ar = locale == 'ar';
    final capabilities = widget.account.role.capabilities;
    final actor = ActorContext(
      userId: widget.account.id,
      role: widget.account.role,
    );
    final scope =
        ref.watch(userScopesProvider(widget.account.id)).asData?.value ??
        ScopeSnapshot(
          teamIds: widget.account.teamIds.toSet(),
          housingIds: widget.account.housingIds.toSet(),
        );
    final operationsController = OperationsController(
      store: ref.watch(operationsRepositoryProvider),
      clock: const SystemClock(),
      actorUserId: widget.account.id,
      capabilities: capabilities,
      allowedHousingIds: scope.housingIds.toList(growable: false),
      allowedTeamIds: scope.teamIds.toList(growable: false),
    );

    final sections = capabilities.sections;
    final pages = [
      for (final section in sections)
        _pageForSection(
          section,
          sections,
          ar,
          locale,
          capabilities,
          actor,
          scope,
          operationsController,
        ),
    ];

    final selectedIndex = _tab.clamp(0, pages.length - 1);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appTitle(ar)),
        actions: [
          SyncStatusBadge(arabic: ar),
          const HomeDateBadge(),
        ],
      ),
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() => _tab = value);
          if (sections[value] == AppSection.history) {
            unawaited(ref.read(historyNotifierProvider.notifier).refresh());
          }
        },
        destinations: [
          for (final s in sections)
            NavigationDestination(
              icon: Icon(_iconForSection(s)),
              label: _labelForSection(s, ar),
            ),
        ],
      ),
    );
  }

  Widget _pageForSection(
    AppSection section,
    List<AppSection> sections,
    bool ar,
    String locale,
    RoleCapabilities capabilities,
    ActorContext actor,
    ScopeSnapshot scope,
    OperationsController operationsController,
  ) => switch (section) {
    AppSection.dashboard => DashboardScreen(
      statusRepository: ref.watch(statusSnapshotRepositoryProvider),
      coverageRepository: ref.watch(dashboardCoverageRepositoryProvider),
      actionsRepository: ref.watch(dashboardActionsRepositoryProvider),
      arabic: ar,
      actorUserId: widget.account.id,
      canEdit:
          capabilities.canResolveConflicts || capabilities.canJustifyAbsence,
    ),
    AppSection.workers => WorkersScreen(
      database: widget.database,
      events: widget.events,
      arabic: ar,
    ),
    AppSection.teams => EntitiesScreen(
      database: widget.database,
      arabic: ar,
      teams: true,
    ),
    AppSection.housing => EntitiesScreen(
      database: widget.database,
      arabic: ar,
      teams: false,
    ),
    AppSection.checkIn => OperationsScreen(
      controller: operationsController,
      arabic: ar,
      role: widget.account.role,
      teamSetupStore: ref.watch(teamSetupStoreProvider),
      actor: actor,
      scope: scope,
    ),
    AppSection.history => HistoryScreen(
      arabic: ar,
      actor: actor,
      scope: scope,
      onEditSiteDay: (t, d) => _openEditSiteDay(sections, t, d),
    ),
    AppSection.settings => PreferencesScreen(
      arabic: ar,
      locale: locale,
      onLocale: (val) => ref.read(appLocaleProvider.notifier).setLocale(val),
      database: widget.database,
      account: widget.account,
      onLogout: widget.onLogout,
      onChangePassword: () => _changePassword(ar),
    ),
  };

  String _labelForSection(AppSection section, bool ar) => switch (section) {
    AppSection.dashboard => AppStrings.homeTab(ar),
    AppSection.workers => AppStrings.workersTab(ar),
    AppSection.teams => AppStrings.teamsTab(ar),
    AppSection.housing => AppStrings.housingTab(ar),
    AppSection.checkIn => AppStrings.checkInTab(ar),
    AppSection.history => HistoryStrings.historyTab(ar),
    AppSection.settings => AppStrings.settingsTab(ar),
  };

  IconData _iconForSection(AppSection section) => switch (section) {
    AppSection.dashboard => Icons.dashboard_outlined,
    AppSection.workers => Icons.people_alt_outlined,
    AppSection.teams => Icons.groups_2_outlined,
    AppSection.housing => Icons.apartment_outlined,
    AppSection.checkIn => Icons.fact_check_outlined,
    AppSection.history => Icons.history_outlined,
    AppSection.settings => Icons.settings_outlined,
  };

  Future<void> _changePassword(bool ar) async {
    final values = await showDialog<(String, String, String)>(
      context: context,
      builder: (ctx) => UserPasswordChangeDialog(arabic: ar),
    );
    if (values == null || !mounted) return;
    if (values.$2.length < 8 || values.$2 != values.$3) {
      _toast(AppStrings.passwordMismatch(ar));
      return;
    }
    try {
      final auth = LocalAuthRepository(
        LocalSettingsRepository(widget.database),
      );
      final verified = await auth.signIn(
        role: widget.account.role,
        accountId: widget.account.id,
        password: values.$1,
      );
      if (verified == null) return _toast(AppStrings.passwordIncorrect(ar));
      await auth.changePassword(verified, values.$2);
      _toast(AppStrings.passwordChanged(ar));
    } on Exception {
      _toast(AppStrings.passwordIncorrect(ar));
    }
  }

  void _toast(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}
