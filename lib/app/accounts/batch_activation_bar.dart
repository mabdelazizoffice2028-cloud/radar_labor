import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/batch_supervisor_dialog.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class BatchActivationBar extends StatelessWidget {
  const BatchActivationBar({
    required this.employees, required this.arabic, required this.busy,
    required this.onActivate, super.key,
  });

  final List<Employee> employees;
  final bool arabic;
  final bool busy;
  final Future<void> Function(List<Employee> selected, AuthRole role) onActivate;

  Future<void> _pick(BuildContext context, AuthRole role) async {
    final title = role == AuthRole.siteSupervisor
        ? AdminStrings.selectSiteSupervisors(arabic)
        : AdminStrings.selectCampusSupervisors(arabic);
    final res = await BatchSupervisorDialog.show(
      context: context, employees: employees, arabic: arabic, title: title,
    );
    if (res != null && res.isNotEmpty && context.mounted) {
      await onActivate(res, role);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space12),
      child: Wrap(
        spacing: AppTokens.space8, runSpacing: AppTokens.space8,
        children: [
          OutlinedButton.icon(
            onPressed: busy ? null : () => _pick(context, AuthRole.siteSupervisor),
            icon: const Icon(Icons.engineering_outlined),
            label: Text(AdminStrings.selectSiteSupervisors(arabic)),
          ),
          OutlinedButton.icon(
            onPressed: busy ? null : () => _pick(context, AuthRole.housingSupervisor),
            icon: const Icon(Icons.holiday_village_outlined),
            label: Text(AdminStrings.selectCampusSupervisors(arabic)),
          ),
        ],
      ),
    );
  }
}
