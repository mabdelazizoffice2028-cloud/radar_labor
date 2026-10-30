import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/auth/local_auth_repository.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/time/clock.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden at startup');
});

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final settingsRepositoryProvider = Provider<LocalSettingsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalSettingsRepository(db);
});

final localAuthRepositoryProvider = Provider<LocalAuthRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalAuthRepository(db);
});

final userScopesProvider = StreamProvider.family<ScopeSnapshot, String>((ref, accountId) {
  final auth = ref.watch(localAuthRepositoryProvider);
  return auth.watchScopes(accountId);
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  throw UnimplementedError('eventRepositoryProvider must be overridden at startup');
});

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
      if (saved != null && (saved == 'en' || saved == 'ar')) state = saved;
    } on Exception catch (error) {
      debugPrint('Locale read failed (${error.runtimeType}).');
    }
  }

  Future<void> setLocale(String locale) async {
    if (state == locale) return;
    state = locale;
    try {
      await ref.read(settingsRepositoryProvider).write('locale', locale);
    } on Exception catch (error) {
      debugPrint('Locale save failed (${error.runtimeType}).');
    }
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, String>(AppLocaleNotifier.new);

final class CurrentSessionNotifier extends Notifier<LocalAccount?> {
  @override
  LocalAccount? build() => null;
  void setSession(LocalAccount? session) => state = session;
}

final currentSessionProvider = NotifierProvider<CurrentSessionNotifier, LocalAccount?>(CurrentSessionNotifier.new);
