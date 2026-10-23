import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/app/screens/entities_screen.dart';
import 'package:radar_labor/app/screens/preferences_screen.dart';
import 'package:radar_labor/app/screens/workers_screen.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_screen.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:radar_labor/features/operations/presentation/operations_screen.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

/// Main scaffold hosting the bottom navigation bar and primary feature views.
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

  bool get _isAdmin =>
      widget.account.role == AuthRole.projectManager ||
      widget.account.role == AuthRole.hr;

  late final _operations = OperationsRepository(
    database: widget.database,
    events: widget.events,
  );

  late final _operationsController = OperationsController(
    store: _operations,
    clock: const SystemClock(),
    role: widget.account.role,
    allowedHousingIds: widget.account.housingIds,
    allowedTeamIds: widget.account.teamIds,
  );

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final ar = locale == 'ar';

    final dashboard = ref.watch(statusSnapshotRepositoryProvider);
    final coverage = ref.watch(dashboardCoverageRepositoryProvider);
    final dashboardActions = ref.watch(dashboardActionsRepositoryProvider);

    final allPages = [
      DashboardScreen(
        statusRepository: dashboard,
        coverageRepository: coverage,
        actionsRepository: dashboardActions,
        arabic: ar,
        canEdit: _isAdmin,
      ),
      WorkersScreen(database: widget.database, events: widget.events, arabic: ar),
      EntitiesScreen(database: widget.database, arabic: ar, teams: true),
      EntitiesScreen(database: widget.database, arabic: ar, teams: false),
      OperationsScreen(
        controller: _operationsController,
        arabic: ar,
        role: widget.account.role,
      ),
      PreferencesScreen(
        arabic: ar,
        locale: locale,
        onLocale: (val) => ref.read(appLocaleProvider.notifier).setLocale(val),
        database: widget.database,
        account: widget.account,
        onLogout: widget.onLogout,
        onChangePassword: () => _changePassword(ar),
      ),
    ];

    final allLabels = [
      AppStrings.homeTab(ar),
      AppStrings.workersTab(ar),
      AppStrings.teamsTab(ar),
      AppStrings.housingTab(ar),
      AppStrings.checkInTab(ar),
      AppStrings.settingsTab(ar),
    ];

    const allIcons = [
      Icons.dashboard_outlined,
      Icons.people_alt_outlined,
      Icons.groups_2_outlined,
      Icons.apartment_outlined,
      Icons.fact_check_outlined,
      Icons.settings_outlined,
    ];

    final visibleTabs = _isAdmin
        ? [0, 1, 2, 3, 4, 5]
        : widget.account.role == AuthRole.viewer
        ? [0, 5]
        : [4, 5];

    final pages = visibleTabs.map((i) => allPages[i]).toList();
    final labels = visibleTabs.map((i) => allLabels[i]).toList();
    final icons = visibleTabs.map((i) => allIcons[i]).toList();
    final selectedIndex = _tab.clamp(0, pages.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appTitle(ar)),
        actions: [
          IconButton(
            tooltip: AppStrings.signOut(ar),
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(businessDateFor(const SystemClock().nowUtc())),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: List.generate(
          labels.length,
          (i) => NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
        ),
      ),
    );
  }

  Future<void> _changePassword(bool ar) async {
    final current = TextEditingController();
    final replacement = TextEditingController();
    final confirmation = TextEditingController();

    final values = await showDialog<(String, String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.changePassword(ar)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppStrings.currentPassword(ar),
              ),
            ),
            TextField(
              controller: replacement,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppStrings.newPassword(ar),
              ),
            ),
            TextField(
              controller: confirmation,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppStrings.confirmPassword(ar),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel(ar)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (
              current.text,
              replacement.text,
              confirmation.text,
            )),
            child: Text(AppStrings.save(ar)),
          ),
        ],
      ),
    );

    current.dispose();
    replacement.dispose();
    confirmation.dispose();

    if (values == null || !mounted) return;
    if (values.$2.length < 8 || values.$2 != values.$3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.passwordMismatch(ar))),
      );
      return;
    }

    try {
      final settings = LocalSettingsRepository(widget.database);
      final auth = LocalAuthRepository(settings);
      final verified = await auth.signIn(
        role: widget.account.role,
        accountId: widget.account.id,
        password: values.$1,
      );
      if (verified == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.passwordIncorrect(ar))),
          );
        }
        return;
      }
      await auth.changePassword(verified, values.$2);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.passwordChanged(ar))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.passwordIncorrect(ar))),
        );
      }
    }
  }
}
