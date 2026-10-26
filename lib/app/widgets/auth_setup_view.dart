import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Interactive initial setup widget for roster import and manager/HR initialization.
final class AuthSetupView extends StatelessWidget {
  const AuthSetupView({
    required this.employees,
    required this.selectedManagerUid,
    required this.selectedHrUid,
    required this.onManagerChanged,
    required this.onHrChanged,
    required this.onPickRoster,
    required this.onCreateAdmins,
    required this.busy,
    required this.errorMessage,
    required this.arabic,
    super.key,
  });

  final List<Employee> employees;
  final String? selectedManagerUid;
  final String? selectedHrUid;
  final ValueChanged<String?> onManagerChanged;
  final ValueChanged<String?> onHrChanged;
  final VoidCallback onPickRoster;
  final VoidCallback onCreateAdmins;
  final bool busy;
  final String? errorMessage;
  final bool arabic;

  String _name(Employee e) =>
      arabic ? e.fullNameAr : (e.fullNameEn ?? e.fullNameAr);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppTokens.space24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.people_alt_outlined,
          size: 54,
          color: AppTokens.primary,
        ),
        const SizedBox(height: AppTokens.space16),
        Text(
          AppStrings.initialSetup(arabic),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppTokens.space8),
        Text(
          arabic
              ? 'ابدأ باستيراد ملف القوى العاملة (XLSX / CSV). لن يُحفظ رقم الهوية الوطنية.'
              : 'Start by importing the workforce file. National ID numbers are never saved.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTokens.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: AppTokens.space24),
        if (employees.isEmpty)
          SizedBox(
            height: AppTokens.minTouchTarget,
            child: FilledButton.icon(
              onPressed: busy ? null : onPickRoster,
              icon: const Icon(Icons.upload_file),
              label: Text(
                arabic ? 'اختيار ملف Excel أو CSV' : 'Choose Excel or CSV file',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          )
        else ...[
          DropdownButtonFormField<String>(
            initialValue: selectedManagerUid,
            decoration: InputDecoration(
              labelText: arabic ? 'مدير المشروع' : 'Project Manager',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: const OutlineInputBorder(),
            ),
            items: employees
                .map(
                  (e) => DropdownMenuItem(
                    value: e.employeeUid,
                    child: Text(_name(e)),
                  ),
                )
                .toList(),
            onChanged: busy ? null : onManagerChanged,
          ),
          const SizedBox(height: AppTokens.space16),
          DropdownButtonFormField<String>(
            initialValue: selectedHrUid,
            decoration: InputDecoration(
              labelText: arabic ? 'مسؤول HR' : 'HR Administrator',
              prefixIcon: const Icon(Icons.manage_accounts_outlined),
              border: const OutlineInputBorder(),
            ),
            items: employees
                .map(
                  (e) => DropdownMenuItem(
                    value: e.employeeUid,
                    child: Text(_name(e)),
                  ),
                )
                .toList(),
            onChanged: busy ? null : onHrChanged,
          ),
          const SizedBox(height: AppTokens.space24),
          SizedBox(
            height: AppTokens.minTouchTarget,
            child: FilledButton(
              onPressed:
                  busy ||
                      selectedManagerUid == null ||
                      selectedHrUid == null ||
                      selectedManagerUid == selectedHrUid
                  ? null
                  : onCreateAdmins,
              child: busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppTokens.onPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      arabic ? 'إنشاء حسابي الإدارة' : 'Create Admin Accounts',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: AppTokens.space16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTokens.statusUnknown,
              fontSize: 13,
            ),
          ),
        ],
      ],
    ),
  );
}
