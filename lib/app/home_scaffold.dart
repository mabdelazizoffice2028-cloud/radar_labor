import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/app/home_password_changer.dart';
import 'package:radar_labor/app/home_scaffold_page_router.dart';
import 'package:radar_labor/app/home_scaffold_section_meta.dart';
import 'package:radar_labor/app/home_site_editor.dart';
import 'package:radar_labor/app/widgets/home_date_badge.dart';
import 'package:radar_labor/app/widgets/notification_badge.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/sync/auto_sync_listener.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/presentation/state/history_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

final class HomeScaffold extends ConsumerStatefulWidget {
  const HomeScaffold({
    required this.database, required this.events, required this.account, required this.onLogout, super.key,
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

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    ref.watch(autoSyncListenerProvider);
    final ar = locale == 'ar';
    final caps = widget.account.role.capabilities;
    final actor = ActorContext(userId: widget.account.id, role: widget.account.role);
    final scope = ref.watch(userScopesProvider(widget.account.id)).asData?.value ??
        ScopeSnapshot(teamIds: widget.account.teamIds.toSet(), housingIds: widget.account.housingIds.toSet());
    final ctrl = OperationsController(
      store: ref.watch(operationsRepositoryProvider), clock: const SystemClock(), actorUserId: widget.account.id,
      capabilities: caps, allowedHousingIds: scope.housingIds.toList(growable: false), allowedTeamIds: scope.teamIds.toList(growable: false),
    );
    final sections = caps.sections;
    final pages = [for (final s in sections) HomeScaffoldPageRouter.buildPage(
      section: s, ref: ref, ar: ar, locale: locale, capabilities: caps, actor: actor, scope: scope, controller: ctrl,
      database: widget.database, events: widget.events, account: widget.account, onLogout: widget.onLogout,
      onChangePassword: () => HomePasswordChanger.changePassword(context: context, database: widget.database, account: widget.account, ar: ar),
      onEditSiteDay: (t, d) => HomeSiteEditor.open(
        context: context, ref: ref, team: t, date: d, controller: ctrl, arabic: ar, actor: actor, scope: scope,
      ),
    )];
    final selectedIdx = _tab.clamp(0, pages.length - 1);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.appTitle(ar)), actions: [NotificationBadge(arabic: ar), const HomeDateBadge()]),
      body: IndexedStack(index: selectedIdx, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIdx,
        onDestinationSelected: (v) {
          setState(() => _tab = v);
          if (sections[v] == AppSection.history) unawaited(ref.read(historyNotifierProvider.notifier).refresh());
        },
        destinations: [for (final s in sections) NavigationDestination(
          icon: Icon(HomeScaffoldSectionMeta.iconForSection(s)), label: HomeScaffoldSectionMeta.labelForSection(s, ar),
        )],
      ),
    );
  }
}
