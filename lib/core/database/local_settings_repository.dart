import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:uuid/uuid.dart';

final class LocalSettingsRepository {
  const LocalSettingsRepository(this._database);

  final AppDatabase _database;
  AppDatabase get database => _database;

  Future<String?> read(String key) async {
    final row = await (_database.select(
      _database.settings,
    )..where((setting) => setting.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watch(String key) =>
      (_database.select(_database.settings)
            ..where((setting) => setting.key.equals(key)))
          .watch()
          .map((rows) => rows.firstOrNull?.value);

  Future<void> write(String key, String value) async {
    await _database
        .into(_database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<String> ensureDeviceId() async {
    final existing = await read(AppSettingKeys.deviceId);
    if (existing != null && existing.isNotEmpty) return existing;

    final created = const Uuid().v4();
    await _database.transaction(() async {
      final current = await read(AppSettingKeys.deviceId);
      if (current == null || current.isEmpty) {
        await write(AppSettingKeys.deviceId, created);
      }
    });
    return await read(AppSettingKeys.deviceId) ?? created;
  }

  Future<void> seedDefaults({required String locale}) async {
    final defaults = <String, String>{
      AppSettingKeys.dayCutoffHour: '3',
      AppSettingKeys.locale: locale,
      AppSettingKeys.slaMinutes: '120',
    };
    for (final entry in defaults.entries) {
      if (await read(entry.key) == null) {
        await write(entry.key, entry.value);
      }
    }
  }
}
