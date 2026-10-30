import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/about_app_screen.dart';
import 'package:radar_labor/app/screens/preferences_admin_section.dart';
import 'package:radar_labor/app/widgets/settings_section_header.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

final class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({
    required this.arabic, required this.locale, required this.onLocale,
    required this.database, required this.account, required this.onLogout,
    required this.onChangePassword, super.key,
  });

  final bool arabic;
  final String locale;
  final ValueChanged<String> onLocale;
  final AppDatabase database;
  final LocalAccount account;
  final VoidCallback onLogout;
  final VoidCallback onChangePassword;

  bool get _canManage => account.role == AuthRole.projectManager || account.role == AuthRole.hr;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(AppStrings.settingsTab(arabic), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      SettingsSectionHeader(title: AppStrings.settingsGeneral(arabic)),
      Card(
        child: ListTile(
          leading: const Icon(Icons.translate),
          title: Text(AppStrings.language(arabic)),
          trailing: DropdownButton<String>(
            value: locale,
            items: [
              DropdownMenuItem(value: 'ar', child: Text(AppStrings.arabic(arabic))),
              DropdownMenuItem(value: 'en', child: Text(AppStrings.english(arabic))),
            ],
            onChanged: (v) { if (v != null) onLocale(v); },
          ),
        ),
      ),
      SettingsSectionHeader(title: AppStrings.settingsAccount(arabic)),
      Card(child: ListTile(leading: const Icon(Icons.key_outlined), title: Text(AppStrings.changePassword(arabic)), onTap: onChangePassword)),
      Card(child: ListTile(leading: const Icon(Icons.logout), title: Text(AppStrings.signOut(arabic)), onTap: onLogout)),
      if (_canManage) PreferencesAdminSection(database: database, arabic: arabic),
      SettingsSectionHeader(title: AppStrings.aboutApp(arabic)),
      Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(AppStrings.aboutApp(arabic)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AboutAppScreen()),
          ),
        ),
      ),
    ],
  );
}
