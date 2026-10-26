import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/sync/outbox_repository.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/sync/sync_engine.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_actions_repository.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_coverage_repository.dart';
import 'package:radar_labor/features/dashboard/data/status_snapshot_repository.dart';
import 'package:radar_labor/features/operations/data/history_repository.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:radar_labor/features/operations/data/roster_admin_repository.dart';
import 'package:radar_labor/features/operations/data/settings_attendance_draft_store.dart';
import 'package:radar_labor/features/operations/data/site_attendance_repository.dart';
import 'package:radar_labor/features/operations/data/team_setup_repository.dart';
import 'package:radar_labor/features/operations/domain/attendance_draft_store.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';

/// Database provider, overridden at app startup.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden at startup');
});

/// Clock provider.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Settings repository provider.
final settingsRepositoryProvider = Provider<LocalSettingsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalSettingsRepository(db);
});

/// Local authentication repository provider.
final localAuthRepositoryProvider = Provider<LocalAuthRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalAuthRepository(db);
});

/// Live stream of assigned team/housing scopes for a user account (PRD §5.4).
final userScopesProvider = StreamProvider.family<ScopeSnapshot, String>((
  ref,
  accountId,
) {
  final auth = ref.watch(localAuthRepositoryProvider);
  return auth.watchScopes(accountId);
});

/// Event repository provider, overridden at startup with deviceId and clock.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  throw UnimplementedError(
    'eventRepositoryProvider must be overridden at startup',
  );
});

/// Manages application locale state and persistence.
final class AppLocaleNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return 'en';
  }

  Future<void> _load() async {
    try {
      final settings = ref.read(settingsRepositoryProvider);
      final saved = await settings.read('locale');
      if (saved != null && (saved == 'en' || saved == 'ar')) {
        state = saved;
      }
    } on Exception {
      // Fall back to default English locale if read fails.
    }
  }

  Future<void> setLocale(String locale) async {
    if (state == locale) return;
    state = locale;
    try {
      final settings = ref.read(settingsRepositoryProvider);
      await settings.write('locale', locale);
    } on Exception {
      // Keep in-memory locale if persistence fails.
    }
  }
}

/// Active app locale provider ('en' or 'ar').
final appLocaleProvider = NotifierProvider<AppLocaleNotifier, String>(
  AppLocaleNotifier.new,
);

/// Session state notifier for the active account.
final class CurrentSessionNotifier extends Notifier<LocalAccount?> {
  @override
  LocalAccount? build() => null;

  void setSession(LocalAccount? session) => state = session;
}

/// Currently active user session / account.
final currentSessionProvider =
    NotifierProvider<CurrentSessionNotifier, LocalAccount?>(
      CurrentSessionNotifier.new,
    );

/// Dashboard status snapshot repository provider.
final statusSnapshotRepositoryProvider = Provider<StatusSnapshotRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  final events = ref.watch(eventRepositoryProvider);
  final clock = ref.watch(clockProvider);
  return StatusSnapshotRepository(database: db, events: events, clock: clock);
});

/// Dashboard coverage repository provider.
final dashboardCoverageRepositoryProvider =
    Provider<DashboardCoverageRepository>((ref) {
      final db = ref.watch(appDatabaseProvider);
      final events = ref.watch(eventRepositoryProvider);
      return DashboardCoverageRepository(database: db, events: events);
    });

/// Dashboard actions repository provider.
final dashboardActionsRepositoryProvider = Provider<DashboardActionsRepository>(
  (ref) {
    final events = ref.watch(eventRepositoryProvider);
    return DashboardActionsRepository(events);
  },
);

/// Operations repository provider.
final operationsRepositoryProvider = Provider<OperationsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final events = ref.watch(eventRepositoryProvider);
  return OperationsRepository(database: db, events: events);
});

/// Team setup repository provider.
final teamSetupStoreProvider = Provider<TeamSetupStore>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TeamSetupRepository(database: db);
});

/// Attendance draft store provider (PRD §8.5).
final attendanceDraftStoreProvider = Provider<AttendanceDraftStore>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  final clock = ref.watch(clockProvider);
  return SettingsAttendanceDraftStore(settings: settings, clock: clock);
});

/// Smart daily site attendance store provider (PRD §8, §9, §10).
final siteAttendanceStoreProvider = Provider<SiteAttendanceStore>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final events = ref.watch(eventRepositoryProvider);
  final draftStore = ref.watch(attendanceDraftStoreProvider);
  final clock = ref.watch(clockProvider);
  return SiteAttendanceRepository(
    database: db,
    events: events,
    draftStore: draftStore,
    clock: clock,
  );
});

/// History store provider (PRD §11).
final historyStoreProvider = Provider<HistoryStore>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final events = ref.watch(eventRepositoryProvider);
  final clock = ref.watch(clockProvider);
  return HistoryRepository(database: db, events: events, clock: clock);
});

/// Append-only audit log repository provider (PRD §23.5, D-26).
final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final clock = ref.watch(clockProvider);
  return AuditLogRepository(database: db, clock: clock);
});

/// Audited roster admin repository provider (PRD §23.4, §23.5).
final rosterAdminRepositoryProvider = Provider<RosterAdminRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final audit = ref.watch(auditLogRepositoryProvider);
  final auth = ref.watch(localAuthRepositoryProvider);
  return RosterAdminRepository(database: db, audit: audit, auth: auth);
});

/// Outbox repository provider (PRD §23.6, D-27).
final outboxRepositoryProvider = Provider<OutboxRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final clock = ref.watch(clockProvider);
  return OutboxRepository(database: db, clock: clock);
});

/// Live stream of pending outbox items count for the quiet sync badge (PRD §23.6).
final pendingOutboxCountProvider = StreamProvider<int>((ref) {
  final outbox = ref.watch(outboxRepositoryProvider);
  return outbox.watchPendingCount();
});

/// Remote sync gateway provider (defaults to offline-first local gateway).
final remoteSyncGatewayProvider = Provider<RemoteSyncGateway>((ref) {
  return const OfflineRemoteSyncGateway();
});

/// Automatic offline-first sync engine provider (PRD §23.6).
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final outbox = ref.watch(outboxRepositoryProvider);
  final gateway = ref.watch(remoteSyncGatewayProvider);
  return SyncEngine(database: db, outbox: outbox, gateway: gateway);
});
