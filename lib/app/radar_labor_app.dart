import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/app/auth_gate.dart';
import 'package:radar_labor/app/home_scaffold.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/database_opener.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Root widget of the application, managing lifecycle, providers, and unified theme.
final class RadarLaborApp extends StatefulWidget {
  const RadarLaborApp({super.key});

  @override
  State<RadarLaborApp> createState() => _RadarLaborAppState();
}

final class _RadarLaborAppState extends State<RadarLaborApp> {
  late Future<_AppStartupState> _startup;
  AppDatabase? _database;

  @override
  void initState() {
    super.initState();
    _startup = _open();
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  Future<_AppStartupState> _open() async {
    const secure = FlutterSecureStorage();
    var key = await secure.read(key: DatabaseConstants.keyStorageName);
    if (key == null) {
      final bytes = Uint8List.fromList(
        List.generate(32, (_) => Random.secure().nextInt(256)),
      );
      key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await secure.write(key: DatabaseConstants.keyStorageName, value: key);
    }
    final directory = await getApplicationSupportDirectory();
    final database = await openEncryptedDatabase(
      File(p.join(directory.path, DatabaseConstants.fileName)),
      key,
    );
    _database = database;
    final settings = LocalSettingsRepository(database);
    await settings.seedDefaults(locale: 'en');
    final deviceId = await settings.ensureDeviceId();
    final events = EventRepository(
      database: database,
      deviceId: deviceId,
      clock: const SystemClock(),
    );
    return _AppStartupState(database, events);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_AppStartupState>(
    future: _startup,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: AppTokens.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTokens.statusUnknown,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.couldNotStart(false),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() => _startup = _open()),
                      child: Text(AppStrings.retry(false)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      if (!snapshot.hasData) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: AppTokens.background,
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      final startup = snapshot.data!;
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(startup.database),
          eventRepositoryProvider.overrideWithValue(startup.events),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final locale = ref.watch(appLocaleProvider);

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: Locale(locale),
              supportedLocales: const [Locale('en'), Locale('ar')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: ThemeData(
                useMaterial3: true,
                fontFamily: 'Cairo',
                colorScheme: ColorScheme.fromSeed(seedColor: AppTokens.primary),
                scaffoldBackgroundColor: AppTokens.background,
                appBarTheme: const AppBarTheme(
                  backgroundColor: AppTokens.primary,
                  foregroundColor: AppTokens.onPrimary,
                ),
              ),
              home: AuthGate(
                database: startup.database,
                builder: (account, onLogout) => HomeScaffold(
                  database: startup.database,
                  events: startup.events,
                  account: account,
                  onLogout: onLogout,
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

final class _AppStartupState {
  const _AppStartupState(this.database, this.events);
  final AppDatabase database;
  final EventRepository events;
}
