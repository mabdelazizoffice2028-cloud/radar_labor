import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

final class BatchSupervisorDialog extends StatefulWidget {
  const BatchSupervisorDialog({required this.employees, required this.arabic, required this.title, super.key});
  final List<Employee> employees; final bool arabic; final String title;

  static Future<List<Employee>?> show({
    required BuildContext context, required List<Employee> employees, required bool arabic, required String title,
  }) => showDialog<List<Employee>>(
    context: context, builder: (_) => BatchSupervisorDialog(employees: employees, arabic: arabic, title: title),
  );

  @override
  State<BatchSupervisorDialog> createState() => _BatchSupervisorDialogState();
}

final class _BatchSupervisorDialogState extends State<BatchSupervisorDialog> {
  final _selected = <String, Employee>{};
  String _query = '';

  List<Employee> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.employees;
    return widget.employees.where((e) {
      final name = '${e.fullNameAr} ${e.fullNameEn ?? ''}'.toLowerCase();
      return name.contains(q) || e.iqamaNo.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360, height: 420,
        child: Column(children: [
          TextField(
            decoration: InputDecoration(
              hintText: AdminStrings.searchSupervisorHint(widget.arabic),
              prefixIcon: const Icon(Icons.search), isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text(AdminStrings.noWorkersFound(widget.arabic)))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final emp = list[i];
                      final subtitle = emp.jobTitle ?? emp.jobCategory;
                      return CheckboxListTile(
                        dense: true,
                        value: _selected.containsKey(emp.iqamaNo),
                        title: Text(widget.arabic ? emp.fullNameAr : (emp.fullNameEn ?? emp.fullNameAr)),
                        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                        onChanged: (sel) => setState(() => sel == true ? _selected[emp.iqamaNo] = emp : _selected.remove(emp.iqamaNo)),
                      );
                    },
                  ),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.cancel(widget.arabic))),
        FilledButton(onPressed: () => Navigator.pop(context, _selected.values.toList()), child: Text(AdminStrings.confirmSelection(widget.arabic))),
      ],
    );
  }
}
