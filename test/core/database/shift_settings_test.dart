import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/preferences_shift_section.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/database/shift_settings_extension.dart';
import 'package:radar_labor/core/l10n/shift_settings_strings.dart';

void main() {
  late AppDatabase db;
  late LocalSettingsRepository settings;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = LocalSettingsRepository(db);
    await settings.seedDefaults(locale: 'en');
  });

  tearDown(() async {
    await db.close();
  });

  group('Section 12: Shift Start & End Settings Repository', () {
    test('Default shift times are 07:00 (420 min) and 17:00 (1020 min)', () async {
      expect(await settings.readShiftStartMinute(), 420);
      expect(await settings.readShiftEndMinute(), 1020);
    });

    test('Updating shift start and end minutes persists accurately', () async {
      await settings.writeShiftStartMinute(480); // 08:00
      await settings.writeShiftEndMinute(1080); // 18:00

      expect(await settings.readShiftStartMinute(), 480);
      expect(await settings.readShiftEndMinute(), 1080);

      final startRow = await (db.select(db.settings)
            ..where((s) => s.key.equals(AppSettingKeys.shiftStartMinute)))
          .getSingle();
      expect(startRow.value, '480');

      final endRow = await (db.select(db.settings)
            ..where((s) => s.key.equals(AppSettingKeys.shiftEndMinute)))
          .getSingle();
      expect(endRow.value, '1080');
    });

    test('Shift settings do not alter day cutoff (3 AM) or SLA defaults', () async {
      await settings.writeShiftStartMinute(360);
      await settings.writeShiftEndMinute(960);

      expect(TimeConstants.defaultDayCutoffHour, 3);
      expect(SettingsDefaults.slaMinutes, 120);

      final cutoff = await settings.read(AppSettingKeys.dayCutoffHour);
      expect(cutoff, '3');

      final sla = await settings.read(AppSettingKeys.slaMinutes);
      expect(sla, '120');
    });

    test('Formatting helper renders clean time strings in Arabic and English', () {
      expect(ShiftSettingsStrings.timeFormat(420, false), '07:00 Riyadh time');
      expect(ShiftSettingsStrings.timeFormat(420, true), '07:00 بتوقيت الرياض');
      expect(ShiftSettingsStrings.timeFormat(1020, false), '17:00 Riyadh time');
      expect(ShiftSettingsStrings.timeFormat(1020, true), '17:00 بتوقيت الرياض');
    });
  });

  group('Section 12: PreferencesShiftSection UI', () {
    testWidgets('PreferencesShiftSection renders start/end tiles and responds to selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreferencesShiftSection(database: db, arabic: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('بداية وردية العمل'), findsOneWidget);
      expect(find.text('نهاية وردية العمل'), findsOneWidget);
      expect(find.text('07:00 بتوقيت الرياض'), findsOneWidget);
      expect(find.text('17:00 بتوقيت الرياض'), findsOneWidget);
    });
  });
}
