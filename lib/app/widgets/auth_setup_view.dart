import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Interactive initial setup widget for roster import and manager/HR initialization.
final class AuthSetupView extends StatelessWidget {
  const AuthSetupView({
    required this.employees, required this.selectedManagerUid, required this.selectedHrUid,
    required this.onManagerChanged, required this.onHrChanged, required this.onPickRoster,
    required this.onCreateAdmins, required this.busy, required this.errorMessage,
    required this.arabic, super.key,
  });

  final List<Employee> employees;
  final String? selectedManagerUid, selectedHrUid, errorMessage;
  final ValueChanged<String?> onManagerChanged, onHrChanged;
  final VoidCallback onPickRoster, onCreateAdmins;
  final bool busy, arabic;

  String _name(Employee e) => arabic ? e.fullNameAr : (e.fullNameEn ?? e.fullNameAr);

  Widget _roleDropdown({
    required String? value, required String label, required IconData icon,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
    items: [for (final e in employees) DropdownMenuItem(value: e.employeeUid, child: Text(_name(e)))],
    onChanged: busy ? null : onChanged,
  );

  @override
  Widget build(BuildContext context) {
    final canCreate = !busy && selectedManagerUid != null && selectedHrUid != null && selectedManagerUid != selectedHrUid;
    return Padding(
      padding: const EdgeInsets.all(AppTokens.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.people_alt_outlined, size: 54, color: AppTokens.primary),
          const SizedBox(height: AppTokens.space16),
          Text(AppStrings.initialSetup(arabic), textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTokens.space8),
          Text(AuthFlowStrings.initialSetupDescription(arabic), textAlign: TextAlign.center, style: const TextStyle(color: AppTokens.textSecondary, fontSize: 14)),
          const SizedBox(height: AppTokens.space24),
          if (employees.isEmpty)
            SizedBox(
              height: AppTokens.minTouchTarget,
              child: FilledButton.icon(
                onPressed: busy ? null : onPickRoster, icon: const Icon(Icons.upload_file),
                label: Text(AuthFlowStrings.chooseRosterFile(arabic), style: const TextStyle(fontSize: 16)),
              ),
            )
          else ...[
            _roleDropdown(value: selectedManagerUid, label: AuthFlowStrings.projectManagerRole(arabic), icon: Icons.badge_outlined, onChanged: onManagerChanged),
            const SizedBox(height: AppTokens.space16),
            _roleDropdown(value: selectedHrUid, label: AuthFlowStrings.hrRole(arabic), icon: Icons.manage_accounts_outlined, onChanged: onHrChanged),
            const SizedBox(height: AppTokens.space24),
            SizedBox(
              height: AppTokens.minTouchTarget,
              child: FilledButton(
                onPressed: canCreate ? onCreateAdmins : null,
                child: busy
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppTokens.onPrimary, strokeWidth: 2.5))
                    : Text(AuthFlowStrings.createAdminAccountsAction(arabic), style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: AppTokens.space16),
            Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppTokens.statusUnknown, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
