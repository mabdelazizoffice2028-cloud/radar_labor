import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';

extension ShiftSettingsExtension on LocalSettingsRepository {
  static const int defaultShiftStartMinute = 420; // 07:00
  static const int defaultShiftEndMinute = 1020; // 17:00

  Future<int> readShiftStartMinute() async {
    final val = await read(AppSettingKeys.shiftStartMinute);
    return int.tryParse(val ?? '$defaultShiftStartMinute') ??
        defaultShiftStartMinute;
  }

  Future<void> writeShiftStartMinute(int minutes) =>
      write(AppSettingKeys.shiftStartMinute, minutes.toString());

  Future<int> readShiftEndMinute() async {
    final val = await read(AppSettingKeys.shiftEndMinute);
    return int.tryParse(val ?? '$defaultShiftEndMinute') ??
        defaultShiftEndMinute;
  }

  Future<void> writeShiftEndMinute(int minutes) =>
      write(AppSettingKeys.shiftEndMinute, minutes.toString());
}
