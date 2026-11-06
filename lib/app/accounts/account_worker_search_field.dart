import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/account_form_dialog.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/features/operations/domain/worker_search_filter.dart';

final class AccountWorkerSearchField extends StatelessWidget {
  const AccountWorkerSearchField({
    required this.arabic,
    required this.employees,
    required this.onSelectEmployee,
    super.key,
  });

  final bool arabic;
  final List<ScopeOption> employees;
  final void Function(String uid, String name) onSelectEmployee;

  @override
  Widget build(BuildContext context) => Autocomplete<ScopeOption>(
    displayStringForOption: (o) => o.$2,
    optionsBuilder: (v) {
      if (v.text.trim().isEmpty) return employees;
      return employees.where(
        (e) => WorkerSearchFilter.matches(
          query: v.text,
          code: e.$1,
          nameAr: e.$2,
          nameEn: e.$2,
          id: e.$1,
        ),
      );
    },
    onSelected: (o) => onSelectEmployee(o.$1, o.$2),
    fieldViewBuilder: (ctx, ctrl, focus, onSub) => TextField(
      controller: ctrl,
      focusNode: focus,
      decoration: InputDecoration(
        labelText: AdminStrings.employeeLabel(arabic),
        prefixIcon: const Icon(Icons.search),
      ),
    ),
  );
}
