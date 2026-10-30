import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/local_accounts_screen.dart';
import 'package:radar_labor/app/screens/preferences_dev_tool_card.dart';
import 'package:radar_labor/app/widgets/settings_section_header.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/database/lockout_settings_extension.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/lockout_strings.dart';

final class PreferencesAdminSection extends StatefulWidget {
  const PreferencesAdminSection({required this.database, required this.arabic, super.key});
  final AppDatabase database;
  final bool arabic;

  @override
  State<PreferencesAdminSection> createState() => _PreferencesAdminSectionState();
}

final class _PreferencesAdminSectionState extends State<PreferencesAdminSection> {
  int _housingHour = 20;
  int _siteHour = 23;
  LocalSettingsRepository get _settings => LocalSettingsRepository(widget.database);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await _settings.readHousingLockoutHour();
    final s = await _settings.readSiteLockoutHour();
    if (mounted) setState(() => (_housingHour = h, _siteHour = s));
  }

  Widget _tile(String title, int val, ValueChanged<int> onChanged) => Card(
    child: ListTile(
      leading: const Icon(Icons.timer_outlined),
      title: Text(title),
      trailing: DropdownButton<int>(
        value: val,
        items: [for (var i = 0; i < 24; i++) DropdownMenuItem(value: i, child: Text(LockoutStrings.hourFormat(i, widget.arabic)))],
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SettingsSectionHeader(title: AppStrings.settingsAdministration(widget.arabic)),
      Card(
        child: ListTile(
          leading: const Icon(Icons.manage_accounts_outlined),
          title: Text(AppStrings.manageUsers(widget.arabic)),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LocalAccountsScreen(database: widget.database, arabic: widget.arabic))),
        ),
      ),
      _tile(LockoutStrings.housingLockout(widget.arabic), _housingHour, (v) async {
        setState(() => _housingHour = v);
        await _settings.writeHousingLockoutHour(v);
      }),
      _tile(LockoutStrings.siteLockout(widget.arabic), _siteHour, (v) async {
        setState(() => _siteHour = v);
        await _settings.writeSiteLockoutHour(v);
      }),
      const SizedBox(height: 8),
      PreferencesDevToolCard(database: widget.database, arabic: widget.arabic),
    ],
  );
}
