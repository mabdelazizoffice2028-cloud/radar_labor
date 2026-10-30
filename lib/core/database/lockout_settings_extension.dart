import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';

extension LockoutSettingsExtension on LocalSettingsRepository {
  Future<int> readHousingLockoutHour() async {
    final val = await read(AppSettingKeys.housingLockoutHour);
    return int.tryParse(val ?? '20') ?? 20;
  }

  Future<void> writeHousingLockoutHour(int hour) =>
      write(AppSettingKeys.housingLockoutHour, hour.toString());

  Future<int> readSiteLockoutHour() async {
    final val = await read(AppSettingKeys.siteLockoutHour);
    return int.tryParse(val ?? '23') ?? 23;
  }

  Future<void> writeSiteLockoutHour(int hour) =>
      write(AppSettingKeys.siteLockoutHour, hour.toString());
}
