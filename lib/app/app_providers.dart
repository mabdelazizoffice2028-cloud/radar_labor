import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_actions_repository.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_coverage_repository.dart';
import 'package:radar_labor/features/dashboard/data/status_snapshot_repository.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';

/// Database provider, overridden at app startup.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden at startup');
});

/// Settings repository provider.
final settingsRepositoryProvider = Provider<LocalSettingsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalSettingsRepository(db);
});

/// Event repository provider, overridden at startup with deviceId and clock.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  throw UnimplementedError('eventRepositoryProvider must be overridden at startup');
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
    } catch (_) {}
  }

  Future<void> setLocale(String locale) async {
    if (state == locale) return;
    state = locale;
    try {
      final settings = ref.read(settingsRepositoryProvider);
      await settings.write('locale', locale);
    } catch (_) {}
  }
}

/// Active app locale provider ('en' or 'ar').
final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, String>(AppLocaleNotifier.new);

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
  return StatusSnapshotRepository(
    database: db,
    events: events,
    clock: const SystemClock(),
  );
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
