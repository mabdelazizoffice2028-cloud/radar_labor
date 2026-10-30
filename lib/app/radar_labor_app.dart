import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_initializer.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/app/auth_gate.dart';
import 'package:radar_labor/app/home_scaffold.dart';
import 'package:radar_labor/app/widgets/startup_error_view.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/ui/app_theme.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class RadarLaborApp extends StatefulWidget {
  const RadarLaborApp({super.key});

  @override
  State<RadarLaborApp> createState() => _RadarLaborAppState();
}

final class _RadarLaborAppState extends State<RadarLaborApp> {
  late Future<AppStartupState> _startup;
  AppDatabase? _database;

  @override
  void initState() {
    super.initState();
    _startup = _init();
  }

  Future<AppStartupState> _init() async {
    final state = await AppInitializer.initialize();
    _database = state.database;
    return state;
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppStartupState>(
    future: _startup,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return StartupErrorView(error: snapshot.error, onRetry: () => setState(() => _startup = _init()));
      }
      if (!snapshot.hasData) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(backgroundColor: AppTokens.background, body: Center(child: CircularProgressIndicator())),
        );
      }
      final startup = snapshot.data!;
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(startup.database),
          eventRepositoryProvider.overrideWithValue(startup.events),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: Locale(ref.watch(appLocaleProvider)),
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: AppTheme.light,
            home: AuthGate(
              database: startup.database,
              builder: (account, onLogout) => HomeScaffold(
                database: startup.database, events: startup.events,
                account: account, onLogout: onLogout,
              ),
            ),
          ),
        ),
      );
    },
  );
}
