import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/local_accounts_screen.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

/// Screen for application settings and user preferences.
final class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({
    required this.arabic,
    required this.locale,
    required this.onLocale,
    required this.database,
    required this.account,
    required this.onLogout,
    required this.onChangePassword,
    super.key,
  });

  final bool arabic;
  final String locale;
  final ValueChanged<String> onLocale;
  final AppDatabase database;
  final LocalAccount account;
  final VoidCallback onLogout;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        AppStrings.settingsTab(arabic),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
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
            onChanged: (value) {
              if (value != null) onLocale(value);
            },
          ),
        ),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.key_outlined),
          title: Text(AppStrings.changePassword(arabic)),
          onTap: onChangePassword,
        ),
      ),
      if (account.role == AuthRole.projectManager ||
          account.role == AuthRole.hr)
        Card(
          child: ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: Text(AppStrings.manageUsers(arabic)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    LocalAccountsScreen(database: database, arabic: arabic),
              ),
            ),
          ),
        ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.logout),
          title: Text(AppStrings.signOut(arabic)),
          onTap: onLogout,
        ),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text(AppStrings.encryptedDatabase(arabic)),
        ),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.wifi_off),
          title: Text(AppStrings.worksOffline(arabic)),
        ),
      ),
    ],
  );
}
