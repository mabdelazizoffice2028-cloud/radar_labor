import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/constants/supabase_config.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/database_opener.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class AppStartupState {
  const AppStartupState(this.database, this.events);
  final AppDatabase database;
  final EventRepository events;
}

abstract final class AppInitializer {
  static Future<AppStartupState> initialize() async {
    const secure = FlutterSecureStorage();
    var key = await secure.read(key: DatabaseConstants.keyStorageName);
    if (key == null) {
      final bytes = Uint8List.fromList(
        List.generate(32, (_) => Random.secure().nextInt(256)),
      );
      key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await secure.write(key: DatabaseConstants.keyStorageName, value: key);
    }
    final dir = await getApplicationSupportDirectory();
    final db = await openEncryptedDatabase(
      File(p.join(dir.path, DatabaseConstants.fileName)),
      key,
    );
    final settings = LocalSettingsRepository(db);
    await settings.seedDefaults(locale: 'en');
    final deviceId = await settings.ensureDeviceId();
    final events = EventRepository(
      database: db,
      deviceId: deviceId,
      clock: const SystemClock(),
    );
    await _initSupabase();
    return AppStartupState(db, events);
  }

  static Future<void> _initSupabase() async {
    if (SupabaseConfig.projectUrl.isEmpty ||
        SupabaseConfig.publishableKey.isEmpty ||
        SupabaseConfig.publishableKey.contains('YOUR_')) {
      return;
    }
    try {
      await Supabase.initialize(
        url: SupabaseConfig.projectUrl,
        publishableKey: SupabaseConfig.publishableKey,
      );
    } on Exception catch (e) {
      debugPrint('Optional Supabase setup failed (${e.runtimeType}).');
    }
  }
}
