import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:uuid/uuid.dart';

final class DeviceIdResolver {
  const DeviceIdResolver(this.database, this.uuid);

  final AppDatabase database;
  final Uuid uuid;

  Future<String> resolve() async {
    final row = await (database.select(database.settings)
          ..where((s) => s.key.equals(AppSettingKeys.deviceId)))
        .getSingleOrNull();
    if (row != null && row.value.isNotEmpty) return row.value;
    final generated = uuid.v4();
    await database.into(database.settings).insert(
      SettingsCompanion.insert(key: AppSettingKeys.deviceId, value: generated),
      mode: InsertMode.insertOrIgnore,
    );
    return generated;
  }
}
