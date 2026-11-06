import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/preferences_shift_tile.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/database/shift_settings_extension.dart';
import 'package:radar_labor/core/l10n/shift_settings_strings.dart';

final class PreferencesShiftSection extends StatefulWidget {
  const PreferencesShiftSection({
    required this.database,
    required this.arabic,
    super.key,
  });

  final AppDatabase database;
  final bool arabic;

  @override
  State<PreferencesShiftSection> createState() =>
      _PreferencesShiftSectionState();
}

final class _PreferencesShiftSectionState
    extends State<PreferencesShiftSection> {
  int _startMinute = ShiftSettingsExtension.defaultShiftStartMinute;
  int _endMinute = ShiftSettingsExtension.defaultShiftEndMinute;
  LocalSettingsRepository get _settings =>
      LocalSettingsRepository(widget.database);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final start = await _settings.readShiftStartMinute();
    final end = await _settings.readShiftEndMinute();
    if (mounted) setState(() => (_startMinute = start, _endMinute = end));
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShiftTimeTile(
            title: ShiftSettingsStrings.shiftStartLabel(widget.arabic),
            minuteValue: _startMinute,
            arabic: widget.arabic,
            onChanged: (v) async {
              setState(() => _startMinute = v);
              await _settings.writeShiftStartMinute(v);
            },
          ),
          ShiftTimeTile(
            title: ShiftSettingsStrings.shiftEndLabel(widget.arabic),
            minuteValue: _endMinute,
            arabic: widget.arabic,
            onChanged: (v) async {
              setState(() => _endMinute = v);
              await _settings.writeShiftEndMinute(v);
            },
          ),
        ],
      );
}
